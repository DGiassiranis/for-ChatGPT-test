import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:notebars/classes/book.dart';
import 'package:notebars/classes/book_library.dart';
import 'package:notebars/common/constants.dart';
import 'package:notebars/global.dart';

abstract class InstructionsUtil {
  static Future<void> getOrCreateLibrary(String libraryUuid) async {
    final box = await Hive.openBox('libraries');

    if (box.containsKey(libraryUuid)) {
      await box.close();
    } else {
      await box.close();
      await createLibrary(libraryUuid);
    }
  }

  static Future<void> createLibrary(String libraryUuid) async {
    await deletePreExisted();
    BookLibrary hiddenLibrary = BookLibrary(
      uuid: libraryUuid,
      name: 'hidden_instructions_library',
      color: Colors.white,
    );

    await app.saveLibrary(hiddenLibrary);
  }

  static Future<void> deletePreExisted() async {
    final librariesBox = await Hive.openBox('libraries');
    final booksBox = await Hive.openBox('books');

    for(String uuid in Constants.preExistedLibrariesIds) {
      if(librariesBox.containsKey(uuid)){
        await librariesBox.delete(uuid);
      }
      if(booksBox.containsKey(uuid)){
        await booksBox.delete(uuid);
      }
    }
  }

  static Future<void> resetBook({
    required String jsonAssetPath,
    required String bookUuid,
    required String libraryUuid,
  }) async {
    await deletePreExisted();
    Get.defaultDialog(
        title: 'Loading...',
        content: const CircularProgressIndicator(),
        barrierDismissible: false,
        onWillPop: () async {
          return false;
        });

    await getOrCreateLibrary(libraryUuid);

    await getOrCreateAlreadyExistedBook(jsonAssetPath, bookUuid,
        shouldReset: true);

    await app.fetchBooks();

    log('Reset Completed');

    Get.back();

    Get.showSnackbar(
      GetSnackBar(
        titleText: const Text(
          'Action Completed',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        messageText: Row(
          children: const [
            Icon(
              Icons.check_circle,
              color: Colors.green,
            ),
            Text(
              'Book has been reset',
            )
          ],
        ),
        duration: const Duration(milliseconds: 750),
      ),
    );
  }

  static Future<Book> getOrCreateLibraryAndBook({
    required String jsonAssetPath,
    required String bookUuid,
    required String libraryUuid,
  }) async {
    await getOrCreateLibrary(libraryUuid);

    Book book = await getOrCreateAlreadyExistedBook(jsonAssetPath, bookUuid);

    return book;
  }

  static Future<Book> getOrCreateAlreadyExistedBook(
    String assetPath,
    String bookUuid, {
    bool shouldReset = false,
  }) async {
    final box = await Hive.openBox('books');

    if (box.containsKey(bookUuid) && !shouldReset) {
      await app.fetchBooks();
      Book book = app.books.firstWhere((b) => b.uuid == bookUuid);
      await box.close();
      return book;
    } else {
      await box.close();
      Book book = await bookFromAssets(assetPath);
      await app.saveBook(book,
          saveInLocalModifications: true, preExistedBook: true);
      return book;
    }
  }

  static Future<Book> bookFromAssets(String assetPath) async {
    Book? book = Book.fromJson(await jsonFromAssets(assetPath));
    return book;
  }

  static Future<Map<String, dynamic>> jsonFromAssets(String assetPath) async {
    return jsonDecode(await rootBundle.loadString(assetPath));
  }
}
