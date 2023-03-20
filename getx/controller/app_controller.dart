import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import 'package:get/instance_manager.dart';
import 'package:get/route_manager.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:notebars/classes/book.dart';
import 'package:notebars/classes/book_library.dart';
import 'package:notebars/classes/modifications_archive.dart';
import 'package:notebars/common/setting_constant.dart';
import 'package:notebars/getx/controller/sync_controller.dart';
import 'package:notebars/global.dart';
import 'package:uuid/uuid.dart';

class AppController extends GetxController {
  static AppController get find => Get.find();

  RxList<BookLibrary> libraries = <BookLibrary>[].obs;

  RxList<Book> books = <Book>[].obs;

  ModificationsArchive? localArchive;

  ModificationsArchive? remoteArchive;

  Rx<bool> needsSync = false.obs;

  Rx<bool> googleSyncEnabled = false.obs;

  DateTime startTime = DateTime.now();

  Future<void> updateRemoteArchive() async {
    await app.drive.saveModificationsArchive();
  }

  List<BookLibraryV2> localLibraries = [];

  synchronizeFirstTime() {
    getArchives(firstTime: true);
  }

  ///[createListWithLocalLibraries] -> Step 1
    ///[fillLocalLibrariesListWithTheirBooks] -> Step 1.1
  ///
  ///[fetchRemoteFile] -> Step 2
    ///[assureUserAuthentication] -> Step 2.1
  ///
  ///[decideActionMethod] -> Step 3: Decide
    ///[synchronizeFirstTimeRemoteFileExists] -> Step 3.1
      ///[createLibrariesFromRemoteArchive] -> Step 3.1.1:
      ///[decideActionMethodOnRemoteArchive] -> Step 3.1.2
      ///[postLocalLibraries] -> Step 3.1.3
    ///[synchronizeFirstTimeRemoteFileDoesNotExist] -> Step 3.2

  void synchronizeFirstTimeV2() async {

    ///Start the timer
    startTime = DateTime.now();

    ///Step 1: Create list with local libraries;[]
      ///Step 1.1 fill the list with the local books;
    createListWithLocalLibraries();

    ///Step 2: Fetch Remote file;
      ///Step 2.1: assure that user is logged in orElse log the user in;
    Get.defaultDialog(
      title: 'Fetching Remote Archive',
      content: const CircularProgressIndicator(),
      barrierDismissible: false,
    );
    await fetchRemoteFile();

    Get.back();
    ///Step 3: Start step 3.1 or 3.2
      ///Step 3.1: Remote File exists;
      ///Step 3.2: Remote File does not exist;
    remoteArchive != null ? await synchronizeFirstTimeRemoteFileExists() : await synchronizeFirstTimeRemoteFileDoesNotExist();
      ///Steps 3.1.*
        ///Step 3.1.1: createLibraries from the remote file;
        ///Step 3.1.2: Calculate and fetch/post books from remoteArchive;
    ///
    log('TOTAL TIME WITH REMOTE ARCHIVE: ${DateTime.now().difference(startTime)}');
    SyncController.find.needsSync.value = false;
    SyncController.find.modifiedBooks.clear();
  }

  ///[synchronizeFirstTimeRemoteFileExists] -> Step 3.1: Remote File exists;
  Future<void> synchronizeFirstTimeRemoteFileExists() async {

    ///Step 3.1.1: createLibraries from the remote file;
    ///
    Get.defaultDialog(
      title: 'Creating Libraries',
      content: const CircularProgressIndicator(),
      barrierDismissible: false,
    );
    await createLibrariesFromRemoteArchive();
    Get.back();

    ///Step 3.1.2: Calculate and fetch/post books from remoteArchive;
    ///
    Get.defaultDialog(
      title: 'Fetching Books',
      content: const CircularProgressIndicator(),
      barrierDismissible: false,
    );
    await fetchRemoteBooks();
    Get.back();

    ///

    Get.defaultDialog(
      title: 'Synchronizing Local Books',
      content: const CircularProgressIndicator(),
      barrierDismissible: false,
    );
    await postLocalLibraries();
    Get.back();

    await app.drive.saveRemoteArchive(remoteArchive!);

    await app.saveLocalArchive(remoteArchive!);

  }

  ///[createLibrariesFromRemoteArchive] -> Step 3.1.1: Create libraries from remote archive;
  Future<void> createLibrariesFromRemoteArchive() async {

    /* Because we are in 3.1.* case, the remoteArchive cannot be null, so we use (!)*/
    for (var remoteArchiveLibrary in remoteArchive!.libraries) {
      ///we need to ensure that the library does not already exists
      if(app.libraries.containsLibrary(remoteArchiveLibrary.uuid)) continue;
      BookLibrary bookLibrary = BookLibrary.fromBookLibraryV2(remoteArchiveLibrary);
      app.saveLibrary(bookLibrary);
    }

  }

  ///Step 3.1.2: Calculate and fetch/post books from remoteArchive;
  Future<void> fetchRemoteBooks() async{
    calculateRemoteActionOnRemote();

    decideActionMethodOnRemote();

    await checkBooksSyncStatus(remoteArchive!.libraries);

  }

  ///[postLocalLibraries] -> Step 3.1.3: Post Local libraries with existed remote file;
  ///Required methods
  ///[calculateRequiredAction] -> It will check if the book already exists or not
  ///if it exists, it will check which modification take place later and decide if it is about to be uploaded
  ///or downloaded
  ///[decideActionMethod] -> will decide which action should be done fetch/post
  ///
  ///[postBooksSynchronously] -> It will start the posting of a book without waiting;
  ///
  ///[fetchBooksSynchronously] -> It will start the fetching of a book without waiting;
  ///
  ///[checkBooksSyncStatus] -> It will wait till the posts and the fetches will end;
  ///
  Future<void> postLocalLibraries() async {

    calculateRequiredAction();

    decideActionMethod();

    await checkBooksSyncStatus(localLibraries);

  }

  void decideActionMethodOnRemote() async {
    for(int libIndex = 0; libIndex < remoteArchive!.libraries.length; libIndex ++){
      for(int bookIndex = 0; bookIndex < remoteArchive!.libraries[libIndex].modifiedBooks.length; bookIndex ++){
        switch(remoteArchive!.libraries[libIndex].modifiedBooks[bookIndex].requiredAction){
          case RequiredActionEnum.download:
            await fetchBooksSynchronouslyFromRemote(libIndex, bookIndex);
            break;
          case RequiredActionEnum.upload:
            remoteArchive!.libraries[libIndex].modifiedBooks[bookIndex].lastModified = DateTime.now();
            await postBooksSynchronouslyFromRemote(libIndex, bookIndex);
            break;
          default:
          //Do nothing;
        }
        remoteArchive!.libraries[libIndex].modifiedBooks[bookIndex].requiredAction = RequiredActionEnum.synchronized;
      }
    }
  }


  void decideActionMethod() async {
    for(int libIndex = 0; libIndex < localLibraries.length; libIndex ++){
      for(int bookIndex = 0; bookIndex < localLibraries[libIndex].modifiedBooks.length; bookIndex ++){
        switch(localLibraries[libIndex].modifiedBooks[bookIndex].requiredAction){
          case RequiredActionEnum.download:
            await fetchBooksSynchronously(libIndex, bookIndex);
            break;
          case RequiredActionEnum.upload:
            localLibraries[libIndex].modifiedBooks[bookIndex].lastModified = DateTime.now();
            await postBooksSynchronously(libIndex, bookIndex);
            break;
          default:
            //Do nothing;
        }
        localLibraries[libIndex].modifiedBooks[bookIndex].requiredAction = RequiredActionEnum.synchronized;
      }
    }
  }

  Future<void> postBooksSynchronouslyFromRemote (int libIndex, int bookIndex) async{

    if(remoteArchive!.libraries[libIndex].modifiedBooks[bookIndex].status == BookDeletionStatus.permDeleted) return;

    await app.drive.saveBook(app.books.firstWhere((element) => element.uuid == remoteArchive!.libraries[libIndex].modifiedBooks[bookIndex].uuid));

  }


  Future<void> postBooksSynchronously (int libIndex, int bookIndex) async{

    if(localLibraries[libIndex].modifiedBooks[bookIndex].status == BookDeletionStatus.permDeleted) return;

    await app.drive.saveBook(app.books.firstWhere((element) => element.uuid == localLibraries[libIndex].modifiedBooks[bookIndex].uuid));

  }

  Future<void> fetchBooksSynchronouslyFromRemote (int libIndex, int bookIndex) async{

    if(remoteArchive!.libraries[libIndex].modifiedBooks[bookIndex].status == BookDeletionStatus.permDeleted) return;

    await app.drive.fetchBook(remoteArchive!.libraries[libIndex].modifiedBooks[bookIndex].uuid, shouldSave: true, saveInDeleted: remoteArchive!.libraries[libIndex].modifiedBooks[bookIndex].status == BookDeletionStatus.tempDeleted);

  }


  Future<void> fetchBooksSynchronously (int libIndex, int bookIndex) async{

    if(localLibraries[libIndex].modifiedBooks[bookIndex].status == BookDeletionStatus.permDeleted) return;

    await app.drive.fetchBook(app.books.firstWhere((element) => element.uuid == localLibraries[libIndex].modifiedBooks[bookIndex].uuid).uuid, shouldSave: true);

  }

  Future<void> checkBooksSyncStatus (List<BookLibraryV2> libraries) async {
    while(doesExistBookDownloadingOrUploading(libraries)){
      await Future.delayed(Duration.zero);
    }
  }

  bool doesExistBookDownloadingOrUploading(List<BookLibraryV2> libraries) {

    for (var element in libraries) {
      for (var modifiedBook in element.modifiedBooks) {
        if(modifiedBook.requiredAction == RequiredActionEnum.download || modifiedBook.requiredAction == RequiredActionEnum.upload){
          return true;
        }
      }
    }

    return false;
  }

  void calculateRemoteActionOnRemote() {
    ///Access the remoteArchive library list
    for (int libIndex = 0; libIndex <  remoteArchive!.libraries.length; libIndex ++) {
      ///Access its modifiedBooks
      for (int index = 0;  index < remoteArchive!.libraries[libIndex].modifiedBooks.length; index++ ) {
        ///Check if the library already exists in the local file;
        ///if the remote file is null, it will go to the else case;
        if((localLibraries).containsLibrary(remoteArchive!.libraries[libIndex].uuid)){
          ///in case that the library exists, we get it;
          BookLibraryV2 localLibrary = localLibraries.firstWhere((element) => element.uuid == remoteArchive!.libraries[libIndex].uuid);
          ///Check if the book already exists in the local file
          ///if the book already exists
          if(localLibrary.modifiedBooks.containsBook(remoteArchive!.libraries[libIndex].modifiedBooks[index].uuid)){
            ///We check which action we should assign
            ModifiedFile localModifiedBook = localLibrary.modifiedBooks.firstWhere((element) => element.uuid == remoteArchive!.libraries[libIndex].modifiedBooks[index].uuid);

            ///if the modified date of the remote book is after the modified date of the local book
            ///then upload orElse download
            remoteArchive!.libraries[libIndex].modifiedBooks[index].requiredAction = localModifiedBook.lastModified.isAfter(remoteArchive!.libraries[libIndex].modifiedBooks[index].lastModified) ? RequiredActionEnum.upload : RequiredActionEnum.download;
          }else {
            remoteArchive!.libraries[libIndex].modifiedBooks[index].requiredAction = RequiredActionEnum.download;
          }
        } else{
          ///if the library does not exist, we just assign requiredAction -> upload
          remoteArchive!.libraries[libIndex].modifiedBooks[index].requiredAction = RequiredActionEnum.download;
        }
      }
    }
  }




  void calculateRequiredAction() {
    ///Access the local library list
    for (int libIndex = 0; libIndex <  localLibraries.length; libIndex ++) {
      ///Access its modifiedBooks
      for (int index = 0;  index < localLibraries[libIndex].modifiedBooks.length; index++ ) {
        ///Check if the library already exists in the remote file;
        ///if the remote file is null, it will go to the else case;
        if((remoteArchive?.libraries ?? []).containsLibrary(localLibraries[libIndex].uuid)){
          ///in case that the library exists, we get it;
          BookLibraryV2 remoteLibrary = remoteArchive!.libraries.firstWhere((element) => element.uuid == localLibraries[libIndex].uuid);
          ///Check if the book already exists in the remote file
          ///if the book already exists
          if(remoteLibrary.modifiedBooks.containsBook(localLibraries[libIndex].modifiedBooks[index].uuid)){
            ///We check which action we should assign
            ModifiedFile remoteModifiedBook = remoteLibrary.modifiedBooks.firstWhere((element) => element.uuid == localLibraries[libIndex].modifiedBooks[index].uuid);
            if(remoteModifiedBook.lastModified.difference(localLibraries[libIndex].modifiedBooks[index].lastModified).inMinutes.abs() > 2) {
              localLibraries[libIndex].modifiedBooks[index].requiredAction = remoteModifiedBook.lastModified.isAfter(localLibraries[libIndex].modifiedBooks[index].lastModified) ? RequiredActionEnum.download : RequiredActionEnum.upload;
            } else{
              localLibraries[libIndex].modifiedBooks[index].requiredAction = RequiredActionEnum.synchronized;
            }
            ///if the modified date of the remote book is after the modified date of the local book
            ///then upload orElse download

          }else {
            localLibraries[libIndex].modifiedBooks[index].requiredAction = RequiredActionEnum.upload;
          }
        } else{
          ///if the library does not exist, we just assign requiredAction -> upload
          localLibraries[libIndex].modifiedBooks[index].requiredAction = RequiredActionEnum.upload;
        }
      }
    }
  }


  ///[synchronizeFirstTimeRemoteFileDoesNotExist] -> Step 3.2: Remote File does not exist;
  Future<void> synchronizeFirstTimeRemoteFileDoesNotExist() async {
    //TODO: implement 3.2 case

    Get.defaultDialog(
      title: 'Synchroning...',
      content: const CircularProgressIndicator(),
      barrierDismissible: false,
    );
    await app.syncWithDrive();
    Get.back();

    Get.defaultDialog(
      title: 'Creating Archive File...',
      content: const CircularProgressIndicator(),
      barrierDismissible: false,
    );
    await createAndPostArchiveFile();
    Get.back();
  }

  Future<void> createAndPostArchiveFile() async{
    ModificationsArchive modificationsArchive = ModificationsArchive(uuid: const Uuid().v4(), libraries: []);
    for(BookLibrary library in app.libraries){
      modificationsArchive.libraries.add(BookLibraryV2.fromBookLibrary(library, []));
      for (Book book in library.books) {
        modificationsArchive.libraries.firstWhere((element) => element.uuid == library.uuid).modifiedBooks.add(ModifiedFile(uuid: book.uuid, lastModified: DateTime.now()));
      }
    }

    await app.drive.saveRemoteArchive(modificationsArchive);
    await app.saveLocalArchive(modificationsArchive);
  }

  ///[createListWithLocalLibraries] -> Step 1: Create list with local libraries;
  void createListWithLocalLibraries() {

    localLibraries
      ..clear()
      ..addAll(app.libraries.map((e) => BookLibraryV2.fromBookLibrary(e, [])).toList());

    fillLocalLibrariesListWithTheirBooks();
  }

  ///[fillLocalLibrariesListWithTheirBooks] -> Step 1.1 fill the list with the local books;
  void fillLocalLibrariesListWithTheirBooks() {
    for(int index = 0; index < localLibraries.length; index ++){
      String uuid = localLibraries[index].uuid;
      List<ModifiedFile> modifiedBooks = app.books.where((element) => element.libraryUuid == uuid).toList().map((e) => ModifiedFile(uuid: e.uuid, lastModified: e.modified ?? DateTime.now())).toList();
      localLibraries[index].modifiedBooks = modifiedBooks;
    }
  }

  ///[fetchRemoteFile] -> Step 2: Fetch Remote file;
  Future<void> fetchRemoteFile() async {

    ///Step 2.1: Ensure that user is logged in;
    await assureUserAuthentication();

    remoteArchive = await app.drive.fetchArchive();
  }

  ///Step 2.1 Assure user authentication
  Future<void> assureUserAuthentication() async {
    if(app.authHeaders != null) return;
    app.googleSignInAccount ??= await app.googleSignIn.signIn();
  }


  void synchronize() {
    if (app.settings[SettingConstant.syncWithGoogleDrive]) {
      if(app.googleSignIn.currentUser != null){
        getArchives();
      }else{
        app.googleSignIn.onCurrentUserChanged
            .listen((GoogleSignInAccount? account) async {
          app.googleSignInAccount = account;
          if (app.googleSignInAccount != null) {
            try {
              // Auto-set notebarsFolderId
              await app.drive.fetchNotebarsFolderId();

              app.settings["googleAuthToken"] =
                  app.googleSignInAccount!.serverAuthCode;

              // Store Google Drive settings permanently
              app.saveAppSettings();

              getArchives();
            } catch (_) {
              Get.offAndToNamed('/libraries');
            }
          }
        });
      }
      Get.offAndToNamed('/libraries');
    } else {
      Get.offAndToNamed('/libraries');
    }
  }

  Future<void> getArchives({bool firstTime = false}) async {
    if (app.settings[SettingConstant.syncWithGoogleDrive]) {
      Get.defaultDialog(
          title: 'Synchronizing Libraries...',
        content: const CircularProgressIndicator(),
      );


      await app.drive.fetchLibraries();
      await app.drive.fetchBooksList();
      await app.drive.createRemoteArchive();
      Get.back();

    }
    googleSyncEnabled.value = false;
  }

  Future<void> fetchEverythingNonRemote() async {
    await app.drive.fetchLibraries();
    await app.drive.fetchBooksList();
    await postLocalLibraries();
    await app.drive.createRemoteArchive();
    Get.back();
  }

  Future<void> fetchEverything() async {
    for (BookLibraryV2 library in remoteArchive!.libraries) {
      await syncSimultaneously(library.modifiedBooks,);
    }
  }

  Future<void> synchronizeLibrary(BookLibrary library) async{

    remoteArchive = await app.drive.fetchArchive();

    if(remoteArchive == null){
      return;
    }

    localArchive ??= await app.fetchLocalModifications();

    remoteArchive!.compareArchives(localArchive!, RequiredActionEnum.download);

    BookLibraryV2? libraryV2 = remoteArchive!.libraries.firstWhereOrNull((element) => element.uuid == library.uuid);

    if(libraryV2 == null){
      log('LIBRARY WITH ${library.name} & ${library.uuid} is not exist in the remote file');
      return;
    }

    for(int index = 0; index < libraryV2.modifiedBooks.length; index ++){
      libraryV2.modifiedBooks[index].requiredAction = RequiredActionEnum.download;
    }

    await syncSimultaneously(libraryV2.modifiedBooks);

    library.booksNeedSync = 0;

    app.saveLibrary(library);
  }

  Future<void> syncSimultaneously(List<ModifiedFile> books) async {
    Get.defaultDialog(
      title: 'Synchronizing books...',
      content: const CircularProgressIndicator(),
      barrierDismissible: false,
    );
    for(int index = 0; index < books.length; index ++){
      books[index].requiredAction = RequiredActionEnum.download;
      fetchBook(books, index);
    }

    while(books.where((element) => element.requiredAction == RequiredActionEnum.download).toList().isNotEmpty){
      await Future.delayed(Duration.zero);
    }

    await app.fetchBooks();

    Get.back();

  }

  void fetchBook(List<ModifiedFile> books, index) async {

    Book? remoteBook = await app.drive.fetchBook(books[index].uuid);

    if(remoteBook != null) await app.saveBook(remoteBook, applyJson: false);

    books[index].requiredAction = RequiredActionEnum.synchronized;

  }



}
