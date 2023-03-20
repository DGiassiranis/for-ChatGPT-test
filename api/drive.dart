/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'dart:convert';
import 'dart:developer';

import 'package:aneya_core/core.dart';
import 'package:collection/collection.dart';
import 'package:encrypt/encrypt.dart';
import 'package:get/get_connect/http/src/exceptions/exceptions.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:notebars/classes/book.dart';
import 'package:notebars/classes/book_library.dart';
import 'package:notebars/classes/modifications_archive.dart';
import 'package:uuid/uuid.dart';

import '../global.dart';

class GoogleDrive extends http.BaseClient {
  static const librariesFileName = 'libraries.json';
  static const notebarsFolderName = 'notebars';
  static const jsonMimeType = 'application/json';

  static const encryptionPrefix = '23806720F&(*fasf(a&*sg^as&^asf^&a*sga(*s&573769184510%&%%124)(**@**41241512512377021341023-1LKSDFHLJLKklalfkhFAFALSDA125;LAFAHJGLHWEAS';

  GoogleDrive(this._headers);

  // region Properties
  final Map<String, String> _headers;
  final http.Client _client = http.Client();
  // endregion

  String notebarsFolderId = '';

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }

  // region Universal methods
  /// Fetches and returns Notebars folder Id on Google Drive.
  /// (automatically sets [notebarsFolderId] in the instance).
  Future<String> fetchNotebarsFolderId() async {
    const mimeType = "application/vnd.google-apps.folder";

    final authHeaders = await app.googleSignInAccount?.authHeaders ?? app.authHeaders;
    if(authHeaders == null) return '';
    final authenticateClient = GoogleDrive(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);

    final found = await driveApi.files.list(
      q: "mimeType = '$mimeType' and name = '$notebarsFolderName'",
      $fields: "files(id, name)",
    );
    final files = found.files;
    if (files == null) {
      throw Exception('Error retrieving Google Drive main folder information');
    }

    // The folder already exists
    if (files.isNotEmpty) return notebarsFolderId = files.first.id!;

    // Create a folder
    drive.File folder = drive.File();
    folder.name = notebarsFolderName;
    folder.mimeType = mimeType;
    final newFolder = await driveApi.files.create(folder);

    return notebarsFolderId = newFolder.id!;
  }
  // endregion

  // region Library methods
  /// Fetches and returns libraries Google Drive file Id
  Future<String> getLibraryFileId() async {
    final authHeaders = await app.googleSignInAccount?.authHeaders ?? app.authHeaders;
    if(authHeaders == null) return '';
    final authenticateClient = GoogleDrive(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);

    if (notebarsFolderId.isEmpty) return '';

    try {
      final files = await driveApi.files.list(q: "'$notebarsFolderId' in parents and mimeType = '$jsonMimeType' and name='$librariesFileName'");
      return (files.files?.firstOrNull)?.id ?? '';
    } catch (e) {
      return '';
    }
  }

  /// Saves given libraries to Google Drive's corresponding libraries JSON file
  Future<Status> saveLibraries(List<BookLibrary> libraries) async {
    final authHeaders = await app.googleSignInAccount?.authHeaders ?? app.authHeaders;
    if(authHeaders == null) return const Status(false, message: 'Unauthorized');
    final authenticateClient = GoogleDrive(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);
    final librariesFileId = await getLibraryFileId();

    var json = jsonEncode(libraries.map((e) => e.toJson()).toList());
    final encoded = utf8.encode(json);
    final stream = Stream<List<int>>.fromIterable([encoded]);

    try {
      var driveFile = drive.File();
      if (librariesFileId.isEmpty) {
        ///the [librariesFileName] (libraries.jsn) was created;
        // driveFile
        //   ..name = librariesFileName
        //   ..parents = [notebarsFolderId];
        // await driveApi.files.create(driveFile, uploadMedia: drive.Media(stream, encoded.length));
      } else {
        await driveApi.files.update(driveFile, librariesFileId, uploadMedia: drive.Media(stream, encoded.length));
      }
      return const Status(true);
    } catch (e) {
      return Status(false, message: '$e');
    }
  }

  /// Fetches and returns all book libraries found on Google Drive's corresponding libraries JSON file
  Future<List<BookLibrary>> fetchLibraries() async {
    final authHeaders = await app.googleSignInAccount?.authHeaders ?? app.authHeaders;
    if(authHeaders == null) {
      throw UnauthorizedException();
    }
    final authenticateClient = GoogleDrive(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);

    try {
      final found = await driveApi.files.list(
        q: "'$notebarsFolderId' in parents",
      );
      final files = found.files;
      if (files == null) return [];
      if (files.isEmpty) return [];

      for (var file in files) {
        if (file.name != librariesFileName) continue;

        try {
          bool ok = false;
          var media = await driveApi.files.get(file.id!, downloadOptions: drive.DownloadOptions.fullMedia);

          String content = '';
          ((media as drive.Media).stream as ByteStream).toStringStream().listen((data) {
            content += data;
          }, onDone: () {
            ok = true;
          }, onError: (error) => throw error);

          while (!ok) {
            await Future.delayed(const Duration(milliseconds: 200));
          }

          List<dynamic> list = jsonDecode(content);
          return list.map((e) => BookLibrary.fromJson(e)).toList();
        } catch (_) {}

        break;
      }
    } catch (_) {

    }

    return [];
  }
  // endregion

  // region Book methods
  /// Fetches a book from Google Drive
  Future<Book?> fetchBook(String uuid, {bool shouldSave = false, bool saveInDeleted = false}) async {
    final authHeaders = await app.googleSignInAccount?.authHeaders ?? app.authHeaders;
    if(authHeaders == null) return null;
    final authenticateClient = GoogleDrive(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);

    try {
      final files = await driveApi.files.list(
        q: "'$notebarsFolderId' in parents and name = '$uuid.json'",
      );
      final file = files.files?.firstOrNull;
      if (file == null) return null;

      bool ok = false;
      var media = await driveApi.files.get(file.id!, downloadOptions: drive.DownloadOptions.fullMedia);

      String content = '';
      ((media as drive.Media).stream as ByteStream).toStringStream().listen((data) {
        content += data;
      }, onDone: () {
        ok = true;
      }, onError: (error) {});

      while (!ok) {
        await Future.delayed(const Duration(milliseconds: 200));
      }

      if(isEncrypted(content)){
        content = decryptBookToJson(content.split(encryptionPrefix)[1]);
      }
      final book = Book.fromJson(jsonDecode(content));

      // Ensure the book has the Google Drive file Id set
      book.driveId = file.id!;

      if(shouldSave && !saveInDeleted){
        await app.saveBook(book, applyJson: false);
      }

      if(saveInDeleted){
        await app.deleteBookTemporarily(book);
      }

      return book;
    } catch (e) {
      return null;
    }
  }

  Future<ModificationsArchive?> fetchArchive() async {

    if(app.googleSignInAccount == null && app.authHeaders == null){
      app.googleSignInAccount = await app.googleSignIn.signInSilently(reAuthenticate: true);
    }


    final authHeaders = (await app.googleSignInAccount?.authHeaders) ?? app.authHeaders;
    if(authHeaders == null) return null;
    final authenticateClient = GoogleDrive(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);

    if(notebarsFolderId.isEmpty){
      await fetchNotebarsFolderId();
    }

    try {
      final files = await driveApi.files.list(
        q: "'$notebarsFolderId' in parents and name = '${ModificationsArchive.archiveBox}.json'",
      );
      final file = files.files?.firstOrNull;
      if (file == null) return null;

      bool ok = false;
      var media = await driveApi.files.get(file.id!, downloadOptions: drive.DownloadOptions.fullMedia);

      String content = '';
      ((media as drive.Media).stream as ByteStream).toStringStream().listen((data) {
        content += data;
      }, onDone: () {
        ok = true;
      }, onError: (error) {});

      while (!ok) {
        await Future.delayed(Duration.zero);
      }

      final archive = ModificationsArchive.fromJson(jsonDecode(content));

      // Ensure the book has the Google Drive file Id set
      archive.googleDriveId = file.id!;


      return archive;
    } catch (e) {
      return null;
    }
  }


  /// Saves a book in Google Drive
  Future<String> saveBook(Book book) async {
    final authHeaders = (await app.googleSignInAccount?.authHeaders) ?? app.authHeaders;
    if(authHeaders == null) return '';
    final authenticateClient = GoogleDrive(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);
    var driveFile = drive.File(name: "${book.uuid}.json", modifiedTime: book.modified ?? book.created);
    drive.File? result;

    if (notebarsFolderId.isEmpty) return '';

    final String encryptedBook = encryptBookJson(jsonEncode(book.toJson()));
    final encoded = utf8.encode(encryptedBook);
    var stream = Stream<List<int>>.fromIterable([encoded]);
    if (book.driveId.isEmpty) {
      // Set Drive file's properties
      driveFile.parents = [notebarsFolderId];
      result = await driveApi.files.create(driveFile, uploadMedia: drive.Media(stream, encoded.length));
    } else {
      try {
        result = await driveApi.files.update(driveFile, book.driveId, uploadMedia: drive.Media(stream, encoded.length));
      } catch (e) {
        // File was probably deleted on Google Drive manually, so recreate it
        if (e is drive.DetailedApiRequestError) {
          if (e.status == 404) {
            // Set Drive file's properties
            driveFile.parents = [notebarsFolderId];

            // Recreate stream
            stream = Stream<List<int>>.fromIterable([encoded]);
            result = await driveApi.files.create(driveFile, uploadMedia: drive.Media(stream, encoded.length));
          }
        }
      }
    }

    return result?.id ?? '';
  }

  String encryptBookJson(String bookJson){
    if(app.googleSignInAccount == null && app.windowsUser?.email == null) return '';

    String email = app.googleSignInAccount?.email ?? app.windowsUser!.email!;

    return '$encryptionPrefix${createEncrypter(createEncryptionKey(email)).encrypt(bookJson, iv: getIV()).base64}';
  }
  
  bool isEncrypted(String bookText) => bookText.startsWith(encryptionPrefix, 0);
  
  String decryptBookToJson(String encryptedBook) {
    if(app.googleSignInAccount == null && app.windowsUser?.email == null) return '';

    String email = app.googleSignInAccount?.email ?? app.windowsUser!.email!;
    return createEncrypter(createEncryptionKey(email)).decrypt64(encryptedBook, iv: getIV());
  }

  String fixStringKey(String key) {
    if(key.length != 32){
      if(key.length > 32){
        key = key.substring(0,32);
      }else{
        int missingCharacters = 32 - key.length;
        for(int i = 0; i < missingCharacters; i++){
          key = '$key+';
        }
      }
    }
    return key;
  }


  Key createEncryptionKey(String email) => Key.fromUtf8(fixStringKey(email),);

  Encrypter createEncrypter(Key key) => Encrypter(AES(key,));

  IV getIV () => IV.fromLength(16);


  Future<void> createRemoteArchive() async {
    List<BookLibraryV2> archiveLibraries = [];
    for (BookLibrary library in app.libraries){

      List<Book> booksModified = app.books.where((element) => element.libraryUuid == library.uuid).toList();
      archiveLibraries.add(BookLibraryV2.fromBookLibrary(library, booksModified.map((e) => ModifiedFile(uuid: e.uuid, lastModified: DateTime.now(), requiredAction: RequiredActionEnum.upload,), ).toList(),),);
    }

    ModificationsArchive archive = ModificationsArchive(uuid: const Uuid().v4(), libraries: archiveLibraries);

    await postActions(archive);
    await saveRemoteArchive(archive);
  }

  Future<void> updateAndPushArchive() async {

    ModificationsArchive? remoteArchive = await fetchArchive();

    if(remoteArchive == null){
      await createRemoteArchive();
      return;
    }

    for(Book book in app.books){
      BookLibraryV2? libraryV2 = remoteArchive.libraries.firstWhereOrNull((element) => element.uuid == book.libraryUuid);

      if(libraryV2 != null){
        updateABookInArchive(remoteArchive, libraryV2, book);
      }else{
        try{
          BookLibrary localLibrary = app.libraries.firstWhere((element) => element.uuid == book.libraryUuid);
          ModifiedFile modifiedBook = ModifiedFile(uuid: book.uuid, lastModified: DateTime.now(),);
          modifiedBook.requiredAction = RequiredActionEnum.upload;
          remoteArchive.libraries.add(BookLibraryV2.fromBookLibrary(localLibrary, [ModifiedFile(uuid: book.uuid, lastModified: DateTime.now(),)].toList(),),);
        }catch(e){
          log(e.toString());
        }
      }

    }

    await postActions(remoteArchive);
    await saveRemoteArchive(remoteArchive);

  }

  void updateABookInArchive(ModificationsArchive archive, BookLibraryV2 libraryV2, Book book){

    int libraryIndex = archive.libraries.indexOf(libraryV2);

    ModifiedFile? modifiedBook = libraryV2.modifiedBooks.firstWhereOrNull((element) => element.uuid == book.uuid);
    ///if modified book is not null, that means that the book should be updated;
    if(modifiedBook != null){
      modifiedBook.requiredAction = RequiredActionEnum.upload;
      archive.libraries[libraryIndex].modifiedBooks[libraryV2.modifiedBooks.indexOf(modifiedBook)].requiredAction = RequiredActionEnum.upload;
      archive.libraries[libraryIndex].modifiedBooks[libraryV2.modifiedBooks.indexOf(modifiedBook)].lastModified = DateTime.now();
    }else{

      archive.libraries[libraryIndex].modifiedBooks.add(ModifiedFile(uuid: book.uuid, lastModified: DateTime.now(), requiredAction: RequiredActionEnum.upload,),);
    }

  }

  Future<void> postActions(ModificationsArchive archive) async{

    for(BookLibraryV2 libraryV2 in archive.libraries){
      await postUnpostedBooks(libraryV2.modifiedBooks);
    }

  }

  Future<void> postUnpostedBooks(List<ModifiedFile> modifiedBooks)async {
    for(int index = 0; index <  modifiedBooks.length; index++){
      if(modifiedBooks[index].requiredAction == RequiredActionEnum.upload){
        saveBookSynchronously(modifiedBooks, index);
      }
      if(modifiedBooks[index].requiredAction == RequiredActionEnum.download){
        fetchBook(modifiedBooks[index].uuid);
      }
    }

    await checkBooksStatus(modifiedBooks);

    log('FINISHED');
  }

  Future<void> checkBooksStatus(List<ModifiedFile> modifiedBooks) async {
    while(modifiedBooks.where((element) => element.requiredAction == RequiredActionEnum.download || element.requiredAction == RequiredActionEnum.upload).toList().isNotEmpty){
      await Future.delayed(Duration.zero);
    }
  }

  void fetchBookSynchronously(List<ModifiedFile> modifiedBooks, int index) async {
    await fetchBook(modifiedBooks[index].uuid);
    modifiedBooks[index].requiredAction = RequiredActionEnum.synchronized;
  }

  void saveBookSynchronously(List<ModifiedFile> modifiedBooks, int index) async {
    try{
      await saveBook(app.books.firstWhere((element) => element.uuid == modifiedBooks[index].uuid));
      modifiedBooks[index].requiredAction = RequiredActionEnum.synchronized;
    }catch(e){
      modifiedBooks[index].requiredAction = RequiredActionEnum.synchronized;
      log(e.toString());
    }
  }

  /// Saves ModificationsArchive into the Google Drive
  Future<String> saveModificationsArchive() async {




    if (notebarsFolderId.isEmpty) return '';

    ModificationsArchive? remoteArchive = await fetchArchive();

    ModificationsArchive archive = await app.fetchLocalModifications();

    if(remoteArchive == null){
      remoteArchive = ModificationsArchive(uuid: archive.uuid, libraries: []);
      if(archive.libraries.isEmpty){
        for (BookLibrary bookLibrary in app.libraries) {
          BookLibraryV2 libraryV2 = BookLibraryV2.fromBookLibrary(bookLibrary, [...app.books.where((element) => element.libraryUuid == bookLibrary.uuid && element.uuid.isNotEmpty).toList().map((e) => ModifiedFile(uuid: e.uuid, lastModified: DateTime.now(),),),]);
          remoteArchive.libraries.add(libraryV2);
        }
      }
    }

    remoteArchive.compareArchives(archive, RequiredActionEnum.download);




    return await saveRemoteArchive(remoteArchive);
  }

  Future<String> saveRemoteArchive(ModificationsArchive remoteArchive) async{

    if(notebarsFolderId.isEmpty){
      await fetchNotebarsFolderId();
    }
    final authHeaders = await app.googleSignInAccount?.authHeaders ?? app.authHeaders;
    if(authHeaders == null) return '';
    final authenticateClient = GoogleDrive(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);
    var driveFile = drive.File(name: "${ModificationsArchive.archiveBox}.json", modifiedTime: DateTime.now());
    drive.File? result;


    final encoded = utf8.encode(jsonEncode(remoteArchive.toJson()));
    var stream = Stream<List<int>>.fromIterable([encoded]);
    if (remoteArchive.googleDriveId.isEmpty) {
      // Set Drive file's properties
      driveFile.parents = [notebarsFolderId];
      result = await driveApi.files.create(driveFile, uploadMedia: drive.Media(stream, encoded.length));
    } else {
      try {
        result = await driveApi.files.update(driveFile, remoteArchive.googleDriveId, uploadMedia: drive.Media(stream, encoded.length));
      } catch (e) {
        // File was probably deleted on Google Drive manually, so recreate it
        if (e is drive.DetailedApiRequestError) {
          if (e.status == 404) {
            // Set Drive file's properties
            driveFile.parents = [notebarsFolderId];

            // Recreate stream
            stream = Stream<List<int>>.fromIterable([encoded]);
            result = await driveApi.files.create(driveFile, uploadMedia: drive.Media(stream, encoded.length));
          }
        }
      }
    }

    return result?.id ?? '';
  }


  /// Deletes a book from Google Drive
  Future<bool> deleteBook(String fileId) async {
    try {
      final authHeaders = await app.googleSignInAccount?.authHeaders ?? app.authHeaders;
      if(authHeaders == null) return false;
      final authenticateClient = GoogleDrive(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);
      await driveApi.files.delete(fileId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Fetches all book files stored in Google Drive
  Future<List<drive.File>> fetchBooksList() async {
    final authHeaders = await app.googleSignInAccount?.authHeaders ?? app.authHeaders;
    if(authHeaders == null) throw UnimplementedError('UNAUTHENTICATED');
    final authenticateClient = GoogleDrive(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);

    try {
      final files = await driveApi.files.list(
        q: "'$notebarsFolderId' in parents and mimeType = '$jsonMimeType'",
        $fields: "files(id, name, size, modifiedTime)",
      );
      return (files.files ?? []).where((file) => file.name != librariesFileName).toList();
    } catch (e) {
      return [];
    }
  }
  // endregion
}
