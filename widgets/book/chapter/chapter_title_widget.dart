import 'package:flutter/material.dart';
import 'package:notebars/classes/book.dart';
import 'package:notebars/classes/book_chapter.dart';

class ChapterTitleWidget extends StatelessWidget {

  const ChapterTitleWidget({Key? key, required this.chapter, required this.onTapChapter, required this.book}) : super(key: key);

  final Book book;
  final BookChapter chapter;
  final Function(BookChapter chapter) onTapChapter;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    return GestureDetector(
      onTap: () {
        onTapChapter(chapter);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            child: MaterialButton(
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
              color: Colors.deepPurpleAccent,
              disabledColor: Colors.deepPurpleAccent,
              textColor: Colors.white,
              elevation: 0,
              onPressed: null,
              child: Text(
                  (book.chapters.indexOf(chapter) + 1)
                      .toString(),
                style: textStyle,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              chapter.name,
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }
}
