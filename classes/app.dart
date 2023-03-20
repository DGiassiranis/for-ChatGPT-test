/// -----------------------------------------------------------------------
///  [2021] - [${YEAR}] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:aneya_app_flutter/app_flutter.dart';
import 'package:aneya_auth/auth.dart';
import 'package:aneya_core/core.dart';
import 'package:aneya_json/json.dart';
import 'package:encrypt/encrypt.dart' as encrypt_lib;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive_api;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:notebars/classes/modifications_archive.dart';
import 'package:notebars/common/constants.dart';
import 'package:notebars/common/hive_constant.dart';
import 'package:notebars/common/setting_constant.dart';
import 'package:notebars/extensions.dart';
import 'package:notebars/getx/controller/sync_controller.dart';
import 'package:notebars/helpers/secure_storage_service.dart';
import 'package:notebars/views/settings_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../api/drive.dart';
import 'book.dart';
import 'book_library.dart';

class NotebarsApp extends FlutterApplication {
  // region Constants
  static const double version = 1.0;

  static const int errorAppSettingsNotFound = -1;
  static const int errorUserSettingsNotFound = -2;

  // endregion

  // region Properties
  List<BookLibrary> libraries = [];
  List<Book> books = [];
  List<String> _selectedLibraryUuids = [];

  static late NotebarsApp _instance;

  final Map<String, bool> _fetched = {'libraries': false, 'settings': false};

  late final GoogleDrive drive;
  GoogleSignInAccount? googleSignInAccount;

  WindowsUser? windowsUser;

  Map<String, String>? authHeaders;

  late final GoogleSignIn googleSignIn;

  // endregion

  // region Construction & initialization
  NotebarsApp() : super() {
    _instance = this;
    settings = {
      'fontSize': 16,
      'noteRowHeight': 50,
      'noteStickyOpacity': 0.0,
      'notesCapital': true,
      'textAlign': 'left',
      'readingSpeed': 1,
      SettingConstant.syncWithGoogleDrive: false,
      "googleAuthToken": ""
    };

    user = User();


    googleSignIn =
        GoogleSignIn(scopes: <String>['email', drive_api.DriveApi.driveScope, 'openid'],);

    drive = GoogleDrive({});
  }

  // endregion

  // region Getters / setters
  bool get fetchedLibraries => _fetched['libraries'] ?? false;

  bool get fetchedSettings => _fetched['settings'] ?? false;

  /// List of books that the library they belong to has studying enabled
  List<Book> get studyBooks => books
      .where((book) => libraries
          .where((l) => l.enableStudying)
          .map((l) => l.uuid)
          .contains(book.libraryUuid))
      .toList();

  /// List of books that don't belong to any of the existing libraries
  List<Book> get orphanedBooks => books
      .where((book) =>
          !libraries.map((library) => library.uuid).contains(book.libraryUuid))
      .toList();

  static NotebarsApp get instance => _instance;

  // endregion



  // region Methods

  Future<void> clearData() async {
    await Hive.deleteFromDisk();
    await clearLibraries();
    await clearBooks();

    notifyListeners();
  }

  Future<void> clearLibraries() async {
    var box = await Hive.openBox('libraries');
    await box.clear();
    libraries.clear();
    await box.close();
  }

  Future<void> clearBooks() async {
    var box = await Hive.openBox('books');
    await box.clear();
    books.clear();
    await box.close();
  }

  // region Library methods
  /// Fetches user's book libraries from server
  Future<Status> fetchLibraries() async {
    var box = await Hive.openBox('libraries');

    try {
      libraries
        ..clear()
        ..addAll(box.values.map((cfg) => BookLibrary.fromJson(Json.from(cfg))));

      _fetched['libraries'] = true;
    } catch (e) {
      return Status(false, message: '$e');
    }

    await box.close();

    // Refresh any dependent listener widget(s)
    notifyListeners();

    return const Status(true);
  }

  Future<bool> isFirstTimeSync() async {
    var box = await Hive.openBox('settings');

    return await box.get(SettingConstant.firstTimeSync, defaultValue: true);
  }

  Future<void> saveFirstTimeSync() async {
    var box = await Hive.openBox('settings');

    await box.put(SettingConstant.firstTimeSync, false);
  }

  /// Saves the library to the local storage
  Future<Status> saveLibrary(BookLibrary library,
      {bool syncedFromDrive = false}) async {
    // Update modified date, unless library has no modified set or was added during Drive sync
    if (!syncedFromDrive && library.modified != null) {
      library.modified = DateTime.now();
    }

    if (library.uuid.isEmpty) {
      library.uuid = const Uuid().v4();
      libraries.add(library);
    } else {
      if (libraries.firstWhereOrNull((l) => l.uuid == library.uuid) == null) {
        libraries.add(library);
      }
      libraries
          .firstWhereOrNull((l) => l.uuid == library.uuid)!
          .applyCfg(library.toJson());
    }

    // Store locally
    var box = await Hive.openBox('libraries');
    await box.put(library.uuid, library.toJson());

    try {
      await box.compact();
      await box.close();
    } catch (_) {}

    // Refresh any dependent listener widget(s)
    notifyListeners();

    return const Status(true);
  }

  /// Deletes the library from the local storage
  Future<Status> deleteLibrary(
    BookLibrary library,
  ) async {
    if (library.uuid.isEmpty) {
      libraries.remove(library);
      return const Status(true);
    }

    // Delete locally
    var box = await Hive.openBox('libraries');
    await box.delete(library.uuid);

    // Delete on Google Drive
    if (settings[SettingConstant.syncWithGoogleDrive]) {
      drive.saveLibraries(libraries);
    }

    await box.compact();
    await box.close();

    // Refresh any dependent listener widget(s)
    notifyListeners();

    return const Status(true);
  }

  Future<Book> fetchBookById(String uuid) async {
    Box box = await Hive.openBox('books');

    return box.values
        .map((b) => Book.fromJson(Json.from(b)))
        .toList()
        .firstWhere((b) => b.uuid == uuid);
  }

  /// Fetches user's book libraries from server
  Future<Status> fetchBooks() async {
    var box = await Hive.openBox('books');

    try {
      List<Book> newBooks =
          box.values.map((cfg) => Book.fromJson(Json.from(cfg))).toList();
      if (newBooks.isNotEmpty) {
        books
          ..clear()
          ..addAll(newBooks);
      }
    } catch (e) {
      return Status(false, message: '$e');
    }

    try {
      await box.close();
    } catch (_) {}

    _fetched['books'] = true;

    // Refresh any dependent listener widget(s)
    notifyListeners();

    return const Status(true);
  }

  Future<void> justSaveBook(Book book) async {
    var box = await Hive.openBox('books');
    box = await Hive.openBox('books');
    var json = book.toJson();
    await box.put(book.uuid, json);
  }

  /// Saves the book to the local storage
  Future<Status> saveBook(
    Book book, {
    bool applyJson = true,
    bool intermediateSave = false,
    bool doNotifyListeners = true,
    bool saveInLocalModifications = false,
    bool shouldFetchBooks = true,
    bool preExistedBook = false,
  }) async {
    // Update modified date
    book.modified = DateTime.now();

    var json = book.toJson();
    if (book.uuid.isEmpty) {
      book.uuid = const Uuid().v4();
      await fetchBooks();
      books.add(book);
    } else if(preExistedBook) {
      await fetchBooks();
      books.add(book);
    } else if (applyJson) {
      books.firstWhere((l) => l.uuid == book.uuid).applyCfg(book.toJson());
    }

    // Save locally
    bool saved = false;
    var box = await Hive.openBox('books');
    while (!saved) {
      try {
        box = await Hive.openBox('books');
        await box.put(book.uuid, json);
        saved = true;
      } catch (_) {}
    }

    try {
      await box.compact();
      await box.close();
    } catch (_) {}

    if (saveInLocalModifications) {
      saveBookIntoModificationsFile(book);
      if (!SyncController.find.modifiedBooks.contains(book.uuid)) {
        SyncController.find.modifiedBooks.add(book.uuid);
      }
    }
    // Refresh any dependent listener widget(s)

    if (shouldFetchBooks) {
      await fetchBooks();
    }
    if ((doNotifyListeners)) {
      notifyListeners();
    }

    return const Status(true);
  }

  Future<void> saveBookInDeleted(Book book,
      {bool applyJson = true,
      bool intermediateSave = false,
      bool doNotifyListeners = true,
      bool saveInLocalModifications = false}) async {
    // Update modified date
    deleteBookTemporarily(book);
  }

  Future<ModificationsArchive> fetchLocalModifications() async {
    var box = await Hive.openBox(ModificationsArchive.archiveBox);

    ModificationsArchive? modifications = box.values.isNotEmpty
        ? ModificationsArchive.fromJson(Json.from(box.values.first))
        : null;
    if (modifications == null) {
      modifications = ModificationsArchive(
        uuid: const Uuid().v4(),
        libraries: [],
      );
      await box.put(modifications.uuid, modifications.toJson());
    }

    try {
      await box.compact();
      await box.close();
    } catch (_) {}

    return modifications;
  }

  Future<void> saveBookIntoModificationsFile(Book book) async {
    var box = await Hive.openBox(ModificationsArchive.archiveBox);

    ModificationsArchive? localArchive = box.values.isNotEmpty
        ? ModificationsArchive.fromJson(Json.from(box.values.first))
        : null;

    localArchive ??=
        ModificationsArchive(uuid: const Uuid().v4(), libraries: []);

    if (localArchive.libraries.containsLibrary(book.libraryUuid)) {
      int libIndex = localArchive.libraries.indexOf(localArchive.libraries
          .firstWhere((element) => element.uuid == book.libraryUuid));

      BookLibrary? libraryV1 = libraries
          .firstWhereOrNull((element) => element.uuid == book.libraryUuid);

      localArchive.libraries[libIndex].color =
          libraryV1?.color ?? localArchive.libraries[libIndex].color;
      localArchive.libraries[libIndex].title =
          libraryV1?.name ?? localArchive.libraries[libIndex].title;

      if (localArchive.libraries[libIndex].modifiedBooks
          .containsBook(book.uuid)) {
        int bookIndex = localArchive.libraries[libIndex].modifiedBooks.indexOf(
            localArchive.libraries[libIndex].modifiedBooks
                .firstWhere((element) => element.uuid == book.uuid));
        localArchive.libraries[libIndex].modifiedBooks[bookIndex].lastModified =
            DateTime.now();
      } else {
        localArchive.libraries[libIndex].modifiedBooks
            .add(ModifiedFile(uuid: book.uuid, lastModified: DateTime.now()));
      }
    } else {
      BookLibrary library =
          libraries.firstWhere((element) => element.uuid == book.libraryUuid);

      BookLibraryV2 libraryV2 = BookLibraryV2.fromBookLibrary(library,
          [ModifiedFile(uuid: book.uuid, lastModified: DateTime.now())]);

      localArchive.libraries.add(libraryV2);
    }

    await box.put(ModificationsArchive.archiveBox, localArchive.toJson());

    try {
      await box.compact();
      await box.close();
    } catch (_) {}

    SyncController.find.needsSync.value = true;
  }

  ///deletes the book temporarily, it puts it in deleted_books box;
  Future<void> deleteBookTemporarily(Book book) async {
    var deletedBooksBox = await Hive.openBox(HiveConstant.deletedBooksBox);

    await deletedBooksBox.put(book.uuid, book.toJson());

    try {
      await deletedBooksBox.compact();
      await deletedBooksBox.close();
    } catch (_) {}

    books.removeWhere((element) => element.uuid == book.uuid);

    // Delete book locally
    var box = await Hive.openBox('books');
    await box.delete(book.uuid);

    try {
      await box.compact();
      await box.close();
    } catch (_) {}

    await updateArchiveFileUponRemoval(book);

    SyncController.find.needsSync.value = true;

    SyncController.find.modifiedBooks.add(book.uuid);

    notifyListeners();
  }

  Future<void> updateArchiveFileUponRemoval(Book book) async {
    var box = await Hive.openBox(ModificationsArchive.archiveBox);

    ModificationsArchive? modifications = box.values.isNotEmpty
        ? ModificationsArchive.fromJson(Json.from(box.values.first))
        : null;

    try {
      if (modifications!.libraries.containsLibrary(book.libraryUuid)) {
        int libIndex = modifications.libraries.indexOf(modifications.libraries
            .firstWhere((element) => element.uuid == book.libraryUuid));
        if (modifications.libraries[libIndex].modifiedBooks
            .containsBook(book.uuid)) {
          int bookIndex = modifications.libraries[libIndex].modifiedBooks
              .indexOf(modifications.libraries[libIndex].modifiedBooks
                  .firstWhere((element) => element.uuid == book.uuid));
          modifications.libraries[libIndex].modifiedBooks[bookIndex].status =
              BookDeletionStatus.tempDeleted;
          modifications.libraries[libIndex].modifiedBooks[bookIndex]
              .lastModified = DateTime.now();
        } else {
          modifications.libraries[libIndex].modifiedBooks.add(
            ModifiedFile(
                uuid: book.uuid,
                lastModified: DateTime.now(),
                status: BookDeletionStatus.tempDeleted),
          );
        }
      } else {
        modifications.libraries.add(BookLibraryV2.fromBookLibrary(
            libraries.firstWhere((element) => element.uuid == book.libraryUuid),
            [
              ModifiedFile(
                  uuid: book.uuid,
                  lastModified: DateTime.now(),
                  status: BookDeletionStatus.tempDeleted),
            ]));
      }

      await saveLocalArchive(modifications);

      await box.compact();
      await box.close();
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> saveLocalArchive(ModificationsArchive archive) async {
    var box = await Hive.openBox(ModificationsArchive.archiveBox);

    await box.put(ModificationsArchive.archiveBox, archive.toJson());

    try {
      await box.compact();
      await box.close();
    } catch (_) {}
  }

  /// Deletes the book from the local storage
  Future<Status> deleteBook(Book book) async {
    books.remove(book);

    if (book.uuid.isEmpty) {
      return const Status(true);
    }

    // Delete book locally
    var box = await Hive.openBox('books');
    await box.delete(book.uuid);

    await box.compact();
    await box.close();

    // Also delete book from Google Drive
    if (settings[SettingConstant.syncWithGoogleDrive]) {
      if (book.driveId.isNotEmpty) {
        await drive.deleteBook(book.driveId);
      }
    }

    return const Status(true);
  }

  /// Syncs local libraries and books with Google Drive
  Future<SyncStatus> syncWithDrive() async {
    try {
      final driveLibraries = await drive.fetchLibraries();

      bool driveNeedsRefresh = false;
      bool localNeedsRefresh = false;
      int librariesUploaded = 0;
      int librariesDownloaded = 0;
      int booksUploaded = 0;
      int booksDownloaded = 0;

      // region Handle Google Drive libraries by comparing with local
      for (final remote in driveLibraries) {
        final local = libraries
            .firstWhereOrNull((element) => element.uuid == remote.uuid);

        if (local != null) {
          // region Remote library exists locally
          if (remote.modified == null ||
              (local.modified != null &&
                  local.modified!.isAfter(remote.modified ?? DateTime(1980)))) {
            // Local is newer
            remote.applyCfg(local.toJson());
            driveNeedsRefresh = true;
            librariesUploaded++;
          } else if (local.modified!.isBefore(remote.modified!)) {
            // Remote is newer
            local.applyCfg(remote.toJson());
            localNeedsRefresh = true;
            librariesDownloaded++;
          }
          // endregion
        } else {
          // region Remote library does not exist locally
          libraries.add(remote);
          await saveLibrary(remote, syncedFromDrive: true);
          localNeedsRefresh = true;
          librariesDownloaded++;
          // endregion
        }
      }
      // endregion

      // region Handle any local libraries that do not exist in Google Drive
      for (final local in libraries) {
        if (driveLibraries.containsUuid(local.uuid)) continue;

        driveLibraries.add(local);
        driveNeedsRefresh = true;
      }
      // endregion

      if (driveNeedsRefresh) await drive.saveLibraries(driveLibraries);
      if (localNeedsRefresh) await saveAppSettings();

      final driveBooks = await drive.fetchBooksList();

      // region Handle Google Drive books by comparing with local
      for (final remote in driveBooks) {
        final local = books.firstWhereOrNull(
            (element) => '${element.uuid}.json' == remote.name);

        if (local != null) {
          // region Remote library exists locally
          // Skip file if modification time is equal to local's (include milliseconds rounding during conversion)
          if (remote.modifiedTime != null &&
              remote.modifiedTime!
                      .difference(local.modified ?? local.created)
                      .inSeconds ==
                  0) continue;

          if (remote.modifiedTime == null ||
              (local.modified != null &&
                  local.modified!
                      .isAfter(remote.modifiedTime ?? DateTime(1980)))) {
            // Local is newer
            final driveId = await drive.saveBook(local);
            if (driveId != local.driveId) {
              local.driveId = driveId;
              await saveBook(local, intermediateSave: true, applyJson: false);
            }
            booksUploaded++;
          } else if ((local.modified ?? local.created)
              .isBefore(remote.modifiedTime!)) {
            // Remote is newer
            final book = await drive.fetchBook(local.uuid);
            if (book != null) {
              await saveBook(book, intermediateSave: true, applyJson: false);
              booksDownloaded++;
            }
          }
          // endregion
        } else {
          // region Remote book does not exist locally
          final uuid = remote.name!.replaceAll('.json', '');
          final book = await drive.fetchBook(uuid);
          if (book != null) {
            await saveBook(book, intermediateSave: true, applyJson: false);
            booksDownloaded++;
          }
          // endregion
        }
      }
      // endregion

      // region Handle local books that do not exist in Google Drive
      for (final local in books) {
        if (driveBooks.any((element) => element.name == '${local.uuid}.json')) {
          continue;
        }

        local.driveId = await drive.saveBook(local);
        await saveBook(local, intermediateSave: true, applyJson: false);
        booksUploaded++;
      }
      // endregion

      return SyncStatus(true,
          librariesDownloaded: librariesDownloaded,
          librariesUploaded: librariesUploaded,
          booksDownloaded: booksDownloaded,
          booksUploaded: booksUploaded);
    } catch (e) {
      return SyncStatus(false, message: '$e');
    }
  }

  /// Adds a library into the app's list of selected libraries and saves the change in the storage
  Future<Status> selectLibrary(BookLibrary library) async {
    if (!_selectedLibraryUuids.contains(library.uuid)) {
      _selectedLibraryUuids.add(library.uuid);
      return await saveAppSettings();
    }

    return const Status(true);
  }

  /// Removes a library from the app's list of selected libraries and saves the change in the storage
  Future<Status> deselectLibrary(BookLibrary library) async {
    if (_selectedLibraryUuids.contains(library.uuid)) {
      _selectedLibraryUuids.remove(library.uuid);
      return await saveAppSettings();
    }

    return const Status(true);
  }

  /// Returns the library that contains the given book
  BookLibrary getLibraryByBook(Book book) =>
      libraries.firstWhere((library) => library.books.contains(book),
          orElse: () => BookLibrary(name: ''));

  // endregion

  // region Application settings methods
  /// Saves given application settings to mobile's shared preferences
  @override
  Future<Status> saveAppSettings() async {
    try {
      var box = await Hive.openBox('settings');
      box.put('version', version);
      box.put('uuid', uuid.isNotEmpty ? uuid : const Uuid().v4());

      // Save user-customizable settings
      box.put('appFontSize', settings['appFontSize']);
      box.put('textAlign', settings['textAlign']);
      box.put('noteRowHeight', settings['noteRowHeight']);
      box.put('noteStickyOpacity', settings['noteStickyOpacity']);
      box.put('notesCapital', settings['notesCapital']);
      box.put('readingSpeed', settings['readingSpeed']);
      box.put(SettingConstant.syncWithGoogleDrive,
          settings[SettingConstant.syncWithGoogleDrive] ?? false);
      box.put("googleAuthToken", settings["googleAuthToken"] ?? "");
      box.put("automatedStudying", settings["automatedStudying"]);
      box.put("smartChapterCreation", settings["smartChapterCreation"]);
      box.put("quickChangeState", settings["quickChangeState"]);
      box.put("capitalizedEnabled", settings["capitalizedEnabled"]);
      box.put("paragraphLineHeight", settings["paragraphLineHeight"]);
      box.put("notebarsFontSize", settings["notebarsFontSize"]);

      // Save selected libraries list
      box.put('selectedLibraries', _selectedLibraryUuids);

      await box.compact();
      await box.close();

      return const Status(true);
    } catch (e) {
      return const Status(false,
          code: -1, message: 'Could not store application settings');
    }
  }

  /// Retrieves application settings from mobile's shared preferences and applies it to instance's options
  @override
  Future<Status> loadAppSettings() async {
    if (fetchedSettings) return const Status(true);

    try {
      var box = await Hive.openBox('settings');

      double v = box.get('version') ?? 0.0;
      if (v != version) {
        // Close settings box to release it and allow upgrading app's settings
        await box.compact();
        await box.close();

        // Migrate application settings to the new version
        Status st = await upgrade(v);
        if (st.isError) return st;

        // Re-open Hive's settings box
        box = await Hive.openBox('settings');
      }

      uuid = box.get('uuid') ?? '';
      if (uuid.isEmpty) {
        Uuid u = const Uuid();
        uuid = u.v4();
        box.put('uuid', uuid);
      }

      // Load user-customizable settings
      settings['appFontSize'] = box.get('appFontSize', defaultValue: 16.0) ?? 16.0;
      settings['textAlign'] =
          box.get('textAlign', defaultValue: 'left') ?? 'left';
      settings['noteRowHeight'] =
          box.get('noteRowHeight', defaultValue: 40.0) ?? 40.0;
      settings['noteStickyOpacity'] =
          box.get('noteStickyOpacity', defaultValue: 0.0) ?? 0.0;
      settings['notesCapital'] =
          box.get('notesCapital', defaultValue: true) ?? true;
      settings['readingSpeed'] = box.get('readingSpeed', defaultValue: 1) ?? 1;
      settings['automatedStudying'] =
          box.get('automatedStudying', defaultValue: false);
      settings['smartChapterCreation'] =
          box.get('smartChapterCreation', defaultValue: true);
      settings['quickChangeState'] =
          box.get('quickChangeState', defaultValue: 3);
      settings['capitalizedEnabled'] = box.get('capitalizedEnabled',
          defaultValue: capitalizedEnabledDefault);
      settings['paragraphLineHeight'] =
          fixLineHeightValue(box.get('paragraphLineHeight', defaultValue: paragraphLineHeightDefaultValue) ?? paragraphLineHeightDefaultValue);
      settings['notebarsFontSize'] = box.get('notebarsFontSize', defaultValue: notebarsDefaultFontMultiplier) ?? notebarsDefaultFontMultiplier;

      if (settings['appFontSize'] is int) {
        settings['appFontSize'] = (settings['appFontSize'] as int).toDouble();
      }
      if (settings['noteRowHeight'] is int) {
        settings['noteRowHeight'] =
            (settings['noteRowHeight'] as int).toDouble();
      }
      if (settings['readingSpeed'] is int) {
        settings['readingSpeed'] = (settings['readingSpeed'] as int).toDouble();
      }

      settings[SettingConstant.syncWithGoogleDrive] =
          box.get(SettingConstant.syncWithGoogleDrive, defaultValue: false) ??
              false;

      settings['googleAuthToken'] =
          box.get("googleAuthToken", defaultValue: "") ?? "";

      // Load selected libraries list
      _selectedLibraryUuids =
          box.get('selectedLibraries', defaultValue: <String>[]) ?? <String>[];

      await box.compact();
      await box.close();

      var status = await fetchLibraries();
      if (status.isError) {
        return status;
      }
      status = await fetchBooks();

      // Clear any selected libraries that aren't available anymore
      List<String> allLibUuids = libraries.map((lib) => lib.uuid).toList();
      _selectedLibraryUuids = _selectedLibraryUuids
          .where((uuid) => allLibUuids.contains(uuid))
          .toList();

      // Refresh any dependent listener widget(s)
      notifyListeners();

      return status;
    } catch (e) {
      return const Status(false,
          code: -1, message: 'Could not load application settings');
    }
  }

  double fixLineHeightValue(double incomingValue){
    return incomingValue < 1.7 ? 1.7 : incomingValue > 1.9 ? 1.9 : incomingValue;
  }

  /// Allows classes to manually notify app that the settings have been changed (e.g. in the settings view)
  void notifySettingsChanged() {
    notifyListeners();
  }

  /// Upgrades application settings from an older version to current version
  @override
  Future<Status> upgrade(double oldVersion) async {
    switch (oldVersion) {
      default:
        // region First time launch
        return await saveAppSettings();
      // endregion
    }
  }

  // endregion

  // region Auxiliary methods
  /// Show a SnackBar with the corresponding icon, message and color of the given status.
  showStatusSnackBar(BuildContext context, Status status) {
    InAppNotification.show(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: status.isOK ? Colors.lightGreen : Colors.redAccent,
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        ),
        child: Row(
          children: [
            Icon(status.isOK ? Icons.check : Icons.error,
                color: Colors.white.withOpacity(.7)),
            const SizedBox(width: 10),
            Flexible(
                child: Text(
              status.message.isNotEmpty ? status.message : status.toString(),
              style: const TextStyle(color: Colors.white),
            ))
          ],
        ),
      ),
      context: context,
    );
  }

  /// Returns the encrypted version of the given string
  String encrypt(String text) {
    final key = encrypt_lib.Key.fromUtf8(
        startOptions.getString('encryptionKey', '------------')); //32 chars
    final iv = encrypt_lib.IV.fromLength(16); //16 chars

    final e = encrypt_lib.Encrypter(
        encrypt_lib.AES(key, mode: encrypt_lib.AESMode.cbc));
    final encryptedData = e.encrypt(text, iv: iv);

    return encryptedData.base64;
  }

  /// Decrypts the given encrypted string and returns the decryption result
  String decrypt(String text) {
    final key = encrypt_lib.Key.fromUtf8(
        startOptions.getString('encryptionKey', '------------')); //32 chars
    final iv = encrypt_lib.IV.fromLength(16); //16 chars

    final e = encrypt_lib.Encrypter(
        encrypt_lib.AES(key, mode: encrypt_lib.AESMode.cbc));
    final decryptedData =
        e.decrypt(encrypt_lib.Encrypted.fromBase64(text), iv: iv);

    return decryptedData;
  }

  @override
  Future<Status> cacheUserCredentials(String username, String password) {
    // TODO: implement cacheUserCredentials
    throw UnimplementedError();
  }

  @override
  Future<Status> deleteCachedUserCredentials() {
    // TODO: implement deleteCachedUserCredentials
    throw UnimplementedError();
  }

  @override
  Future<Status> signIn(
      {String username = '',
      String password = '',
      String token = '',
      AuthenticationOptions? options}) {
    // TODO: implement signIn
    throw UnimplementedError();
  }

  @override
  Future<Status> signInUserFromCache() {
    // TODO: implement signInUserFromCache
    throw UnimplementedError();
  }

  // endregion
  // endregion

  void openYoutubePlaylist() async {
    if (Platform.isIOS) {
      if (await canLaunchUrl(Constants.youtubePlaylistIOSUri)) {
        await launchUrl(
          Constants.youtubePlaylistIOSUri,
        );
      } else {
        await launchUrl(Constants.youtubePlaylistAndroidUri);
      }
    } else {
      await launch(Constants.youtubePlaylistAndroid);
    }
  }

  void launchNotebarsTutorial() async {
    await launch(Constants.notebarsTutorial);
  }
}

class SyncStatus<T> extends Status<T> {
  SyncStatus(super.isPositive,
      {this.librariesUploaded = 0,
      this.librariesDownloaded = 0,
      this.booksUploaded = 0,
      this.booksDownloaded = 0,
      super.code,
      super.message,
      super.debugMessage,
      super.data});

  final int librariesUploaded;
  final int librariesDownloaded;
  final int booksUploaded;
  final int booksDownloaded;

  bool get inSync =>
      librariesDownloaded == 0 &&
      librariesUploaded == 0 &&
      booksDownloaded == 0 &&
      booksUploaded == 0;

  @override
  String toString() {
    if (!isPositive) return super.toString();
    if (inSync) return 'Google Drive and device are already synchronized';

    final messages = [];

    if (librariesUploaded > 0) {
      messages.add(
          'Uploaded $librariesUploaded libraries that were changed locally.');
    }
    if (librariesDownloaded > 0) {
      messages.add(
          'Downloaded $librariesDownloaded libraries that were newer in Google Drive.');
    }
    if (booksUploaded > 0) {
      messages.add('Uploaded $booksUploaded books that were changed locally.');
    }
    if (booksDownloaded > 0) {
      messages.add(
          'Downloaded $booksDownloaded books that were newer in Google Drive.');
    }

    return messages.join('\n');
  }
}
