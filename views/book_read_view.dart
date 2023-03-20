/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:notebars/views/book_notes_view.dart';
import 'package:notebars/widgets/notes/book_notes_widget_toolbar.dart';

import '../classes/book.dart';
import '../classes/book_chapter.dart';
import '../widgets/book/book_reader.dart';

class BookReadView extends StatefulWidget {
  final Book book;

  const BookReadView({Key? key, required this.book}) : super(key: key);

  @override
  BookReadViewState createState() => BookReadViewState();
}

class BookReadViewState extends State<BookReadView> {
  late BookChapter chapter;

  final ScrollController _scrollController = ScrollController();

  int get chapterIndex => widget.book.chapters.indexOf(chapter);

  @override
  void initState() {
    super.initState();

    chapter = widget.book.chapters.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffdbe2e7),
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
        title: Text(widget.book.name),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  chapter.name,
                  style: const TextStyle(color: Color.fromRGBO(171, 167, 232, 1.0)),
                ),
              ],
            ),
          ),
        ),
        actions: const [
          Icon(Icons.more_vert),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.menu,
        activeIcon: Icons.close,
        backgroundColor: Colors.deepPurpleAccent,
        childPadding: const EdgeInsets.all(5),
        spaceBetweenChildren: 4,
        renderOverlay: false,
        children: [
          SpeedDialChild(
            label: 'Next chapter',
            child: const Icon(Icons.chevron_right),
            foregroundColor: Colors.white,
            backgroundColor: Colors.lightBlueAccent,
            labelBackgroundColor: Colors.black54,
            labelStyle: const TextStyle(color: Colors.white),
            onTap: () => navigateNext(),
            visible: chapter != widget.book.chapters.last,
          ),
          SpeedDialChild(
            label: 'Previous chapter',
            child: const Icon(Icons.chevron_left),
            foregroundColor: Colors.white,
            backgroundColor: Colors.lightBlueAccent,
            labelBackgroundColor: Colors.black54,
            labelStyle: const TextStyle(color: Colors.white),
            onTap: () => navigatePrevious(),
            visible: chapter != widget.book.chapters.first,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(10),
        shrinkWrap: true,
        children: [BookReader(book: widget.book, chapter: chapter, mode: BookRenderMode.read, addAction: AddAction.keyword, addActionLock: false, shiftingStatus: ShiftingStatus.none, onNotesIndexChanged: (_, __, ___ ) {  }, lockStatus: LockStatus.unlocked, onTransparentIndexChanged: (_, __, ___) {  }, lockedIndexes: const {},)],
      ),
    );
  }

  // region Action methods
  /// Navigate to a specific chapter
  void navigateTo(int index) {
    if (index >= 0 && index < widget.book.chapters.length) chapter = widget.book.chapters[index];

    scrollToTop();
  }

  /// Navigate to the next chapter
  void navigateNext() {
    if (chapter != widget.book.chapters.last) {
      setState(() {
        chapter = widget.book.chapters[chapterIndex + 1];
      });
    }

    scrollToTop();
  }

  /// Navigate to the previous chapter
  void navigatePrevious() {
    if (chapter != widget.book.chapters.first) {
      setState(() {
        chapter = widget.book.chapters[chapterIndex - 1];
      });
    }

    scrollToTop();
  }

  Future<void> scrollToTop() async {
    await _scrollController.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
  }
  // endregion
}
