/// -----------------------------------------------------------------------
///  [2021] - [2022] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:flutter/material.dart';

import '../classes/book.dart';
import '../classes/book_chapter.dart';
import '../global.dart';
import '../widgets/library/book_merge_chapters_list.dart';
import '../widgets/library/book_merge_source_bar.dart';

class BookMergeView extends StatefulWidget {
  const BookMergeView({Key? key, required this.books}) : super(key: key);

  final List<Book> books;

  @override
  BookMergeViewState createState() => BookMergeViewState();
}

class BookMergeViewState extends State<BookMergeView> {
  late Book destination;
  late List<BookChapter> chapters;
  late List<Book> dropBooks;
  bool processing = false;

  // region Events
  bool onWillAccept(BookChapter? chapter, int index) {
    return chapter != null && chapters.indexOf(chapter) != index;
  }

  void onAccept(BookChapter chapter, int index) {
    if (chapters.contains(chapter)) {
      setState(() {
        int currentIndex = chapters.indexOf(chapter);
        chapters.remove(chapter);
        chapters.insert(currentIndex > index ? index : index - 1, chapter);
      });
    } else {
      setState(() {
        dropBooks.removeWhere((book) => book.uuid == chapter.uuid);
        chapters.insert(index, chapter);
      });
    }
  }

  void onDropBack(BookChapter chapter, int index) {
    setState(() {
      chapters.removeWhere((book) => book.uuid == chapter.uuid);
      dropBooks.insert(dropBooks.isNotEmpty ? index + 1 : index, widget.books.firstWhere((book) => book.uuid == chapter.uuid));
    });
  }
  // endregion

  // region Methods
  save() async {
    setState(() => processing = true);

    var destChapters = chapters.toList();

    // Insert dropped books' chapters into the destination book
    var insertedBooks = widget.books.where((book) => chapters.indexWhere((chapter) => chapter.uuid == book.uuid) > 0).toList();
    for (var book in insertedBooks) {
      int index = destChapters.indexWhere((chapter) => chapter.uuid == book.uuid);
      destChapters.removeAt(index);

      if (index >= destChapters.length) {
        destChapters.addAll(book.chapters);
      } else {
        destChapters.insertAll(index, book.chapters);
      }
    }

    // Remove all dropped books from the temporary chapters list
    for (var book in insertedBooks) {
      int index = chapters.indexWhere((chapter) => chapter.uuid == book.uuid);
      chapters.removeAt(index);
    }

    destination.chapters.clear();
    destination.chapters.addAll(destChapters);

    var status = await app.saveBook(destination, saveInLocalModifications: true);
    if (status.isOK) {
      for (var book in insertedBooks) {
        await app.deleteBookTemporarily(book);
      }
    } else {
      if (!mounted) return; // Ensure context is valid across async gaps
      app.showStatusSnackBar(context, status);
    }

    setState(() => processing = false);

    if (!mounted) return; // Ensure context is valid across async gaps
    Navigator.of(context).popAndPushNamed('/libraries');
  }
  // endregion

  @override
  void initState() {
    super.initState();

    destination = widget.books.first;
    chapters = destination.chapters.toList();
    dropBooks = widget.books.where((book) => book != destination).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffdbe2e7),
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
        title: const Text('Merge Books'),
        centerTitle: true,
        actions: [
          processing
              ? ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 24, maxHeight: 16), child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : IconButton(onPressed: dropBooks.isEmpty ? save : null, icon: const Icon(Icons.check)),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BookMergeSourceBar(
            books: widget.books,
            destination: destination,
            onBookPressed: (book) => setState(() {
              destination = book;
              chapters = destination.chapters.toList();
              dropBooks = widget.books.where((book) => book != destination).toList();
            }),
          ),
          Expanded(
            child: BookMergeChaptersList(
              originalBook: destination,
              chapters: chapters,
              availableBooks: dropBooks,
              onAccept: onAccept,
              onWillAccept: onWillAccept,
              onDropBack: onDropBack,
            ),
          ),
        ],
      ),
    );
  }
}
