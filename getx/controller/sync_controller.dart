import 'dart:developer';

import 'package:aneya_json/json.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:hive/hive.dart';
import 'package:notebars/classes/book_library.dart';
import 'package:notebars/classes/modifications_archive.dart';
import 'package:notebars/common/hive_constant.dart';
import 'package:notebars/extensions.dart';
import 'package:notebars/getx/controller/app_controller.dart';
import 'package:notebars/getx/controller/deleted_books_controller.dart';
import 'package:notebars/getx/controller/network_controller.dart';
import 'package:notebars/global.dart';
import 'package:uuid/uuid.dart';

///[SyncController] will take care of the sync that will take place
///1. while user presses the button to sync the books
///2. while the app starts and the user has the sync enabled;
class SyncController extends GetxController {
  static SyncController get find => Get.find();

  Rx<bool> needsSync = false.obs;

  Rx<String> message = ''.obs;
  Rx<String> dialogMessage = ''.obs;

  RxList<String> modifiedBooks = <String>[].obs;

  int downloadedBooks = 0;
  int uploadedBooks = 0;

  Future<void> startTheSync() async {
    await NetworkController.find.getConnectionType();
    if(!NetworkController.find.isNetworkConnected.value) {
      Get.offAndToNamed('/libraries');
      return;
    }
    message.value = 'Initializing...';
    await initiateLocalArchive();
    message.value = 'Synchronizing...';
    await synchronize(showDialogs: false);

  }

  Future<bool> checkNetwork() async{
    if (!NetworkController
        .find.isNetworkConnected.value) {
      Get.defaultDialog(
          title: 'Unavailable',
          content: const Text(
            'It seems that your device is not connected to any network. Please, connect your device to the internet and try again.',
            textAlign: TextAlign.center,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('OK'),
            ),
          ]);
      return false;
    }
    return true;

  }

  Future<void> initiateLocalArchive() async {
    ModificationsArchive? remoteArchive = await app.drive.fetchArchive();

    ModificationsArchive? localArchive = await fetchLocalArchive();


    if (remoteArchive != null) {
      for (var remoteArchiveLibrary in remoteArchive.libraries) {
        ///we need to ensure that the library does not already exists
        if(app.libraries.containsLibrary(remoteArchiveLibrary.uuid)) continue;
        BookLibrary bookLibrary = BookLibrary.fromBookLibraryV2(remoteArchiveLibrary);
        app.saveLibrary(bookLibrary);
      }
      ModificationsArchive fArchive = compareTwoArchives(
          remoteArchive,
          localArchive ??
              ModificationsArchive(uuid: const Uuid().v4(), libraries: []));
      await saveLocalArchive(fArchive);
    }
  }

  ModificationsArchive compareTwoArchives(
      ModificationsArchive remoteArchive, ModificationsArchive localArchive) {
    ModificationsArchive finalLocalArchive =
        ModificationsArchive(uuid: const Uuid().v4(), libraries: []);

    for (int libIndex = 0;
        libIndex < remoteArchive.libraries.length;
        libIndex++) {
      if (!localArchive.libraries
          .containsLibrary(remoteArchive.libraries[libIndex].uuid)) {
        BookLibraryV2 copiedLibrary = remoteArchive.libraries[libIndex];
        for (int index = 0;
            index < copiedLibrary.modifiedBooks.length;
            index++) {
          copiedLibrary.modifiedBooks[index].lastModified = DateTime(1980);
        }

        finalLocalArchive.libraries.add(copiedLibrary);
      } else {
        BookLibraryV2 emptyLibrary = BookLibraryV2(
            uuid: remoteArchive.libraries[libIndex].uuid,
            title: remoteArchive.libraries[libIndex].title,
            color: remoteArchive.libraries[libIndex].color,
            modifiedBooks: []);
        for (int bookIndex = 0;
            bookIndex < remoteArchive.libraries[libIndex].modifiedBooks.length;
            bookIndex++) {
          if (!localArchive.libraries
              .firstWhere((element) =>
                  element.uuid == remoteArchive.libraries[libIndex].uuid)
              .modifiedBooks
              .containsBook(remoteArchive
                  .libraries[libIndex].modifiedBooks[bookIndex].uuid)) {
            emptyLibrary.modifiedBooks.add(ModifiedFile(
                uuid: remoteArchive
                    .libraries[libIndex].modifiedBooks[bookIndex].uuid,
                lastModified: DateTime(1980)));
          } else {
            emptyLibrary.modifiedBooks.add(localArchive.libraries
                .firstWhere((element) =>
                    element.uuid == remoteArchive.libraries[libIndex].uuid)
                .modifiedBooks
                .firstWhere((element) =>
                    element.uuid ==
                    remoteArchive
                        .libraries[libIndex].modifiedBooks[bookIndex].uuid));
          }
        }
        finalLocalArchive.libraries.add(emptyLibrary);
      }
    }

    for (var library in localArchive.libraries) {
      if (!finalLocalArchive.libraries.containsLibrary(library.uuid)) {
        finalLocalArchive.libraries.add(library);
      } else {
        int libIndex = finalLocalArchive.libraries.indexOf(finalLocalArchive
            .libraries
            .firstWhere((element) => element.uuid == library.uuid));

        for (var book in library.modifiedBooks) {
          if (!finalLocalArchive.libraries[libIndex].modifiedBooks
              .containsBook(book.uuid)) {
            finalLocalArchive.libraries[libIndex].modifiedBooks.add(book);
          }
        }
      }
    }

    return finalLocalArchive;
  }

  Future<void> createdNonFoundLocalLibraries(ModificationsArchive remoteArchive,
      ModificationsArchive localArchive) async {
  }

  Future<void> synchronize({bool showDialogs = true}) async {

    if(!(await checkNetwork())) return;

    downloadedBooks = 0;
    uploadedBooks = 0;
    dialogMessage.value = '';

    if (showDialogs) {
      Get.defaultDialog(
        title: 'Initializing...',
        content: Column(
          children: const [
            CircularProgressIndicator(),
            Text(
              '\n> Calculating required changes...\n'
            )
          ],
        ),
        barrierDismissible: false,
      );
    }
    ModificationsArchive? remoteArchive = await app.drive.fetchArchive();
    if (showDialogs) {
      Get.back();
    }
    if (remoteArchive == null) {
      Get.defaultDialog(
          title: 'It seems that your data have conflict with google drive',
          content: const CircularProgressIndicator(),
          actions: [
            ElevatedButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                AppController.find.synchronizeFirstTimeV2();
              },
              child: const Text('Start google sync again.'),
            )
          ]);
      return;
    }

    if (showDialogs) {
      Get.defaultDialog(
        title: 'Synchronizing...',
        content: Column(
          children: [
            const CircularProgressIndicator(),
            ObxValue((Rx<String> dialogMessage) => dialogMessage.value.isNotEmpty ? Text(dialogMessage.value, textAlign: TextAlign.start,) : const SizedBox(), dialogMessage)
          ],
        ),
        barrierDismissible: false,
      );
    }
    ModificationsArchive? localArchive = await fetchLocalArchive();

    localArchive ??= ModificationsArchive(uuid: const Uuid().v4(), libraries: []);

    ///case that there is nothing on drive yet;
    if (remoteArchive.libraries.isEmpty) {
      for (int libIndex = 0;
          libIndex < localArchive.libraries.length;
          libIndex++) {
        remoteArchive.libraries.add(BookLibraryV2.fromBookLibrary(
            app.libraries.firstWhere((element) => false), []));
        for (int bookIndex = 0;
            bookIndex < localArchive.libraries[libIndex].modifiedBooks.length;
            bookIndex++) {
          ModifiedFile file = ModifiedFile(
              uuid: localArchive
                  .libraries[libIndex].modifiedBooks[bookIndex].uuid,
              status: localArchive
                  .libraries[libIndex].modifiedBooks[bookIndex].status,
              lastModified: DateTime.now(),
              requiredAction: RequiredActionEnum.upload);
          remoteArchive.libraries[libIndex].modifiedBooks.add(file);
        }
      }
    } else {
      List<BookLibraryV2> nonExistedLibraries = [];

      ///find non existed libraries;
      for (var element in localArchive.libraries) {
        if (!remoteArchive.libraries.containsLibrary(element.uuid)) {
          BookLibrary? localLibrary =
              app.libraries.firstWhereOrNull((lib) => lib.uuid == element.uuid);
          if (localLibrary == null) continue;
          // if(!localLibrary.enableStudying) continue;
          nonExistedLibraries.add(element);
        }
      }

      for (int libIndex = 0;
          libIndex < nonExistedLibraries.length;
          libIndex++) {
        for (int bookIndex = 0;
            bookIndex < nonExistedLibraries[libIndex].modifiedBooks.length;
            bookIndex++) {
          uploadedBooks += 1;
          nonExistedLibraries[libIndex]
              .modifiedBooks[bookIndex]
              .requiredAction = RequiredActionEnum.upload;
          nonExistedLibraries[libIndex].modifiedBooks[bookIndex].lastModified =
              DateTime.now();
        }
      }

      ///modifyBooks
      for (int libIndex = 0;
          libIndex < remoteArchive.libraries.length;
          libIndex++) {
        if (localArchive.libraries
            .containsLibrary(remoteArchive.libraries[libIndex].uuid)) {
          BookLibraryV2 localLibrary = localArchive.libraries.firstWhere(
              (element) =>
                  element.uuid == remoteArchive.libraries[libIndex].uuid);

          ///if the library is not activated, or cannot be found inside the app.libraries, we continue;
          BookLibrary? library = app.libraries
              .firstWhereOrNull((lib) => lib.uuid == localLibrary.uuid);
          if (library == null) continue;
          // if(!library.enableStudying) continue;

          ///find nonExistedBooks;
          List<ModifiedFile> nonExistedBooks = [];
          for (var element in localLibrary.modifiedBooks) {
            if (!remoteArchive.libraries[libIndex].modifiedBooks
                .containsBook(element.uuid)) {
              element.lastModified = DateTime.now();
              uploadedBooks += 1;
              element.requiredAction = RequiredActionEnum.upload;
              nonExistedBooks.add(element);
            }
          }

          for (int bookIndex = 0; bookIndex < remoteArchive.libraries[libIndex].modifiedBooks.length; bookIndex++) {
            if (!localLibrary.modifiedBooks.containsBook(remoteArchive
                .libraries[libIndex].modifiedBooks[bookIndex].uuid)) continue;
            ModifiedFile localBook = localLibrary.modifiedBooks.firstWhere(
                (element) =>
                    element.uuid ==
                    remoteArchive
                        .libraries[libIndex].modifiedBooks[bookIndex].uuid);
            if (remoteArchive
                    .libraries[libIndex].modifiedBooks[bookIndex].lastModified
                    .difference(localBook.lastModified)
                    .inSeconds
                    .abs() <
                1) continue;
            if (remoteArchive
                .libraries[libIndex].modifiedBooks[bookIndex].lastModified
                .isAfter(localBook.lastModified)) {
              downloadedBooks += 1;
              remoteArchive.libraries[libIndex].modifiedBooks[bookIndex]
                  .requiredAction = RequiredActionEnum.download;
            } else {
              uploadedBooks += 1;
              remoteArchive.libraries[libIndex].modifiedBooks[bookIndex]
                  .requiredAction = RequiredActionEnum.upload;
              remoteArchive.libraries[libIndex].modifiedBooks[bookIndex]
                  .status = localBook.status;
              remoteArchive.libraries[libIndex].modifiedBooks[bookIndex]
                  .lastModified = DateTime.now();
            }
          }

          for (var library in remoteArchive.libraries) {
            List<ModifiedFile> modifiedFiles = library.modifiedBooks.sortByTime();

            if(modifiedFiles.isNotEmpty){
              if(modifiedFiles.first.requiredAction == RequiredActionEnum.upload){
                remoteArchive.libraries[remoteArchive.libraries.indexOf(remoteArchive.libraries.firstWhere((element) => element.uuid == library.uuid))].color = localArchive.libraries.firstWhere((element) => element.uuid == library.uuid).color;
                remoteArchive.libraries[remoteArchive.libraries.indexOf(remoteArchive.libraries.firstWhere((element) => element.uuid == library.uuid))].title = localArchive.libraries.firstWhere((element) => element.uuid == library.uuid).title;
              }else if(modifiedFiles.first.requiredAction == RequiredActionEnum.download){
                app.saveLibrary(BookLibrary.fromBookLibraryV2(library));
              }
            }
          }


          remoteArchive.libraries[libIndex].modifiedBooks
              .addAll(nonExistedBooks);
        }
      }

      remoteArchive.libraries.addAll(nonExistedLibraries);
    }

    message.value = '';

    if(downloadedBooks != 0){
      dialogMessage.value  += '\n> Downloading $downloadedBooks book(s)...\n ';
      message.value  += '\n> Downloading $downloadedBooks book(s)...\n ';
    }
    if(uploadedBooks != 0){
      dialogMessage.value += '\n> Uploading $uploadedBooks book(s)...\n\n';
      message.value += '\n> Uploading $uploadedBooks book(s)...\n\n';
    }
    if(dialogMessage.value.isEmpty){
      dialogMessage.value = 'Everything is up to date...';
      message.value = 'Everything is up to date...';
    }



    var deletedBooksBox = await Hive.openBox(HiveConstant.deletedBooksBox);

    ///So far, so good, the only thing remains is to sync the unSyncBooks;
    for (int libIndex = 0;
        libIndex < remoteArchive.libraries.length;
        libIndex++) {
      for (int bookIndex = 0;
          bookIndex < remoteArchive.libraries[libIndex].modifiedBooks.length;
          bookIndex++) {
        switch (remoteArchive
            .libraries[libIndex].modifiedBooks[bookIndex].requiredAction) {
          case RequiredActionEnum.upload:
            try {
              if (deletedBooksBox.containsKey(remoteArchive
                  .libraries[libIndex].modifiedBooks[bookIndex].uuid)) {
                // remoteArchive
                //     .libraries[libIndex].modifiedBooks[bookIndex].requiredAction = RequiredActionEnum.synchronized;
                try{
                  await app.deleteBookTemporarily(app.books.firstWhere((element) => element.uuid == remoteArchive
                      .libraries[libIndex].modifiedBooks[bookIndex].uuid));

                }catch(_) {}
                // break;
              }
              if(remoteArchive.libraries[libIndex].modifiedBooks[bookIndex].status == BookDeletionStatus.permDeleted){
                remoteArchive
                    .libraries[libIndex].modifiedBooks[bookIndex].requiredAction = RequiredActionEnum.synchronized;
                break;
              }
              saveBook(remoteArchive, libIndex, bookIndex, remoteArchive
                  .libraries[libIndex].modifiedBooks[bookIndex].status);
              BookLibraryV2? localLibrary = localArchive.libraries
                  .firstWhereOrNull((element) =>
                      element.uuid == remoteArchive.libraries[libIndex].uuid);
              if (localLibrary != null) {
                if (localLibrary.modifiedBooks.length <= 1) {
                  localArchive.libraries.removeWhere(
                      (element) => element.uuid == localLibrary.uuid);
                } else {
                  localArchive
                      .libraries[localArchive.libraries.indexOf(
                          localArchive.libraries.firstWhere(
                              (element) => element.uuid == localLibrary.uuid))]
                      .modifiedBooks
                      .removeWhere((element) =>
                          element.uuid ==
                          remoteArchive.libraries[libIndex]
                              .modifiedBooks[bookIndex].uuid);
                }
              }
            } catch (_) {
              log('ERROR: sync_controller.dart, line: 168');
            }
            break;
          case RequiredActionEnum.download:
            if(remoteArchive.libraries[libIndex].modifiedBooks[bookIndex].status == BookDeletionStatus.permDeleted){
              remoteArchive
                  .libraries[libIndex].modifiedBooks[bookIndex].requiredAction = RequiredActionEnum.synchronized;
              app.books.removeWhere((element) => element.uuid == remoteArchive
                  .libraries[libIndex].modifiedBooks[bookIndex].uuid);

              DeletedBooksController.find.deleteBookPermanentViaUuid(remoteArchive
                  .libraries[libIndex].modifiedBooks[bookIndex].uuid);
              break;
            }
            fetchBook(remoteArchive, libIndex, bookIndex, remoteArchive.libraries[libIndex].modifiedBooks[bookIndex].status);
            try {

              BookLibraryV2? localLibrary = localArchive.libraries
                  .firstWhereOrNull((element) =>
                      element.uuid == remoteArchive.libraries[libIndex].uuid);
              if (localLibrary != null) {
                if (localLibrary.modifiedBooks.length <= 1) {
                  localArchive.libraries.removeWhere(
                      (element) => element.uuid == localLibrary.uuid);
                } else {
                  localArchive
                      .libraries[localArchive.libraries.indexOf(
                          localArchive.libraries.firstWhere(
                              (element) => element.uuid == localLibrary.uuid))]
                      .modifiedBooks
                      .removeWhere((element) =>
                          element.uuid ==
                          remoteArchive.libraries[libIndex]
                              .modifiedBooks[bookIndex].uuid);
                }
              }
            } catch (e) {
              log('ERROR: sync_controller.dart, line: 181');
            }
            break;
          default:
          //do nothing;
        }
      }
    }

    while (doesExistBookDownloadingOrUploading(remoteArchive.libraries)) {
      await Future.delayed(Duration.zero);
    }

    message.value = 'Everything is up to date now...';

    if (showDialogs) {
      dialogMessage.value = '\nEverything is up to date now...\n';

      Get.back();

      Get.defaultDialog(
        title: 'Summarizing...',
        content: Column(
          children: [
            const CircularProgressIndicator(),
            ObxValue((Rx<String> dialogMessage) => dialogMessage.value.isNotEmpty ? Text(dialogMessage.value, textAlign: TextAlign.start,) : const SizedBox(), dialogMessage)
          ],
        ),
        barrierDismissible: false,
      );

    }


    await app.drive.saveRemoteArchive(remoteArchive);

    await saveLocalArchive(remoteArchive);

    if (showDialogs) {
      Get.back();
    }

    needsSync.value = false;
    modifiedBooks.clear();


  }

  bool doesExistBookDownloadingOrUploading(List<BookLibraryV2> libraries) {
    for (var element in libraries) {
      for (var modifiedBook in element.modifiedBooks) {
        if (modifiedBook.requiredAction == RequiredActionEnum.download ||
            modifiedBook.requiredAction == RequiredActionEnum.upload) {
          return true;
        }
      }
    }

    return false;
  }

  void fetchBook(
      ModificationsArchive remoteArchive, int libIndex, int bookIndex, BookDeletionStatus status) async {
    switch(status){

      case BookDeletionStatus.active:
        await DeletedBooksController.find.deleteFromDeleted(remoteArchive.libraries[libIndex].modifiedBooks[bookIndex].uuid);
        await app.drive.fetchBook(
            remoteArchive.libraries[libIndex].modifiedBooks[bookIndex].uuid,
            shouldSave: true, saveInDeleted: remoteArchive.libraries[libIndex].modifiedBooks[bookIndex].status == BookDeletionStatus.tempDeleted);

        remoteArchive.libraries[libIndex].modifiedBooks[bookIndex].requiredAction =
            RequiredActionEnum.synchronized;
        break;
      case BookDeletionStatus.tempDeleted:
        await DeletedBooksController.find.deleteFromDeleted(remoteArchive.libraries[libIndex].modifiedBooks[bookIndex].uuid);
        await app.drive.fetchBook(
            remoteArchive.libraries[libIndex].modifiedBooks[bookIndex].uuid,
            shouldSave: true, saveInDeleted: remoteArchive.libraries[libIndex].modifiedBooks[bookIndex].status == BookDeletionStatus.tempDeleted);

        remoteArchive.libraries[libIndex].modifiedBooks[bookIndex].requiredAction =
            RequiredActionEnum.synchronized;
        break;
      case BookDeletionStatus.permDeleted:
        remoteArchive.libraries[libIndex].modifiedBooks[bookIndex].requiredAction = RequiredActionEnum.synchronized;
        break;
    }
  }

  void saveBook(
      ModificationsArchive remoteArchive, int libIndex, int bookIndex, BookDeletionStatus status) async {

    try{
      switch(status){

        case BookDeletionStatus.active:
          await app.drive.saveBook(app.books.firstWhere((element) =>
          element.uuid ==
              remoteArchive.libraries[libIndex].modifiedBooks[bookIndex].uuid));
          remoteArchive.libraries[libIndex].modifiedBooks[bookIndex].requiredAction = RequiredActionEnum.synchronized;
          break;
        case BookDeletionStatus.tempDeleted:
          await app.drive.saveBook(DeletedBooksController.find.deletedBooks.firstWhere((element) =>
          element.uuid ==
              remoteArchive.libraries[libIndex].modifiedBooks[bookIndex].uuid));
          remoteArchive.libraries[libIndex].modifiedBooks[bookIndex].requiredAction = RequiredActionEnum.synchronized;
          break;
        case BookDeletionStatus.permDeleted:
          remoteArchive.libraries[libIndex].modifiedBooks[bookIndex].requiredAction = RequiredActionEnum.synchronized;
          break;
      }
    }catch(e){
      log(e.toString());
    }

    remoteArchive.libraries[libIndex].modifiedBooks[bookIndex].requiredAction =
        RequiredActionEnum.synchronized;
  }

  Future<ModificationsArchive?> fetchLocalArchive() async {
    var box = await Hive.openBox(ModificationsArchive.archiveBox);

    ModificationsArchive? localArchive = box.values.isNotEmpty
        ? ModificationsArchive.fromJson(Json.from(box.values.first))
        : null;

    try {
      await box.compact();
      await box.close();
    } catch (_) {}

    return localArchive;
  }

  Future<void> saveLocalArchive(ModificationsArchive archive) async {
    var box = await
    Hive.openBox(ModificationsArchive.archiveBox);

    await box.put(ModificationsArchive.archiveBox, archive.toJson());

    try {
      await box.compact();
      await box.close();
    } catch (_) {}
  }
}
