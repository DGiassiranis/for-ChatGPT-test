import 'package:flutter/material.dart';
import 'package:notebars/classes/book.dart';
import 'package:notebars/classes/book_chapter.dart';
import 'package:notebars/widgets/book/chapter/prefix_indent.dart';
import 'package:notebars/widgets/book/chapter/unit_title_widget.dart';

class SubChapterTitleWidget extends StatelessWidget {
  const SubChapterTitleWidget({
    Key? key,
    required this.subChapter,
    required this.parentChapter,
    required this.onTapSubChapter,
    required this.book,
    required this.onTapUnit,
  }) : super(key: key);

  final BookChapter subChapter;
  final BookChapter parentChapter;
  final Book book;
  final Function(BookChapter subChapter, BookChapter parentChapter, Book book)
      onTapSubChapter;
  final Function(BookChapter unit, BookChapter subChapter,
      BookChapter parentChapter, Book book) onTapUnit;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.black.withOpacity(0.4),
      fontSize: 13,
    );
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            onTapSubChapter(
              subChapter,
              parentChapter,
              book,
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PrefixIndent(
                  depth: subChapter.depth,
                ),
                SizedBox(
                  width: 30,
                  height: 30,
                  child: MaterialButton(
                    padding: EdgeInsets.zero,
                    color: Colors.deepPurpleAccent.withOpacity(0.5),
                    disabledColor: Colors.deepPurpleAccent.withOpacity(0.5),
                    textColor: Colors.white,
                    elevation: 0,
                    onPressed: null,
                    child: Text(
                      '${parentChapter.subChapters.indexOf(subChapter) + 2}',
                      style: textStyle.copyWith(color: Colors.white,),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    subChapter.name,
                    style: textStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
        ...subChapter.units.map((unit) => UnitTitleWidget(
              unit: unit,
              subChapter: subChapter,
              parentChapter: parentChapter,
              book: book,
              onTapUnit: onTapUnit,
            )),
      ],
    );
  }
}
