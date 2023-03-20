
import 'dart:developer';

import 'package:aneya_json/json.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/instance_manager.dart';
import 'package:hive/hive.dart';
import 'package:notebars/classes/book.dart';
import 'package:notebars/classes/modifications_archive.dart';
import 'package:notebars/common/hive_constant.dart';
import 'package:notebars/extensions.dart';
import 'package:notebars/getx/controller/sync_controller.dart';
import 'package:notebars/global.dart';

class DeletedBooksController extends GetxController{

  static DeletedBooksController get find => Get.find();

  List<Book> deletedBooks = [];

  Rx<bool> loaded = false.obs;


  @override
  void onInit() {
    super.onInit();
    fetchDeletedBooks();
  }

  Future<void> fetchDeletedBooks() async {
    loaded.value = false;
    var deletedBooksBox = await Hive.openBox(HiveConstant.deletedBooksBox);

    deletedBooks
      ..clear()
      ..addAll(deletedBooksBox.values.map((cfg) => Book.fromJson(Json.from(cfg))));

    loaded.value = true;
  }

  Future<void> deleteFromDeleted(String uuid) async{
    var deletedBooksBox = await Hive.openBox(HiveConstant.deletedBooksBox);

    try{
      await deletedBooksBox.delete(uuid);
    }catch(_){}

    try{
      await deletedBooksBox.compact();
      await deletedBooksBox.close();
    }catch(_){}
  }

  void restoreBook(Book book) async {

    var deletedBooksBox = await Hive.openBox(HiveConstant.deletedBooksBox);

    await deletedBooksBox.delete(book.uuid);

    try{
      await deletedBooksBox.compact();
      await deletedBooksBox.close();
    }catch(_){}

    var booksBox = await Hive.openBox('books');

    await booksBox.put(book.uuid, book.toJson());

    fetchDeletedBooks();

    await app.fetchBooks();

    await saveInModificationsFile(book, BookDeletionStatus.active);

    SyncController.find.needsSync.value = true;
    SyncController.find.modifiedBooks.add(book.uuid);

  }

  Future<void> deleteBookPermanent(Book book) async {

    var deletedBooksBox = await Hive.openBox(HiveConstant.deletedBooksBox);

    await deletedBooksBox.delete(book.uuid);

    try{
      await deletedBooksBox.compact();
      await deletedBooksBox.close();
    }catch(_){}

    fetchDeletedBooks();

    await saveInModificationsFile(book, BookDeletionStatus.permDeleted);

    SyncController.find.needsSync.value = true;
    SyncController.find.modifiedBooks.add(book.uuid);

  }

  Future<void> deleteBookPermanentViaUuid(String uuid) async {

    var deletedBooksBox = await Hive.openBox(HiveConstant.deletedBooksBox);

    await fetchDeletedBooks();
    Book? book = deletedBooks.firstWhereOrNull((element) => element.uuid == uuid);

    await deletedBooksBox.delete(uuid);

    try{
      await deletedBooksBox.compact();
      await deletedBooksBox.close();
    }catch(_){}

    fetchDeletedBooks();

    if(book != null){
      await saveInModificationsFile(book, BookDeletionStatus.permDeleted);
      SyncController.find.needsSync.value = true;
      SyncController.find.modifiedBooks.add(book.uuid);
    }




  }


  Future<void> saveInModificationsFile(Book book, BookDeletionStatus status) async {

    var box = await Hive.openBox(ModificationsArchive.archiveBox);

    ModificationsArchive? modifications = box.values.isNotEmpty ? ModificationsArchive.fromJson(Json.from(box.values.first)) : null;


    try{
      if(modifications!.libraries.containsLibrary(book.libraryUuid)){
        int libIndex = modifications.libraries.indexOf(modifications.libraries.firstWhere((element) => element.uuid == book.libraryUuid));
        if(modifications.libraries[libIndex].modifiedBooks.containsBook(book.uuid)){
          int bookIndex = modifications.libraries[libIndex].modifiedBooks.indexOf(modifications.libraries[libIndex].modifiedBooks.firstWhere((element) => element.uuid == book.uuid));
          modifications.libraries[libIndex].modifiedBooks[bookIndex].status = status;
          modifications.libraries[libIndex].modifiedBooks[bookIndex].lastModified = DateTime.now();
        }else{
          modifications.libraries[libIndex].modifiedBooks.add(ModifiedFile(uuid: book.uuid, lastModified: DateTime.now(), status: BookDeletionStatus.tempDeleted),);
        }
      }else{
        modifications.libraries.add(BookLibraryV2.fromBookLibrary(app.libraries.firstWhere((element) => element.uuid == book.libraryUuid), [
          ModifiedFile(uuid: book.uuid, lastModified: DateTime.now(), status: BookDeletionStatus.tempDeleted),
        ]));

      }


      await app.saveLocalArchive(modifications);

      await box.compact();
      await box.close();
    }catch(e){
      log(e.toString());
    }

  }



}

