import 'package:flutter/material.dart';
import 'package:notebars/classes/book.dart';
import 'package:notebars/classes/book_chapter.dart';
import 'package:notebars/widgets/book/chapter/prefix_indent.dart';

class UnitTitleWidget extends StatelessWidget {
  const UnitTitleWidget(
      {Key? key,
        required this.unit,
        required this.subChapter,
        required this.parentChapter,
        required this.onTapUnit,
        required this.book})
      : super(key: key);

  final BookChapter unit;
  final BookChapter subChapter;
  final BookChapter parentChapter;
  final Book book;
  final Function(BookChapter unit,BookChapter subChapter, BookChapter parentChapter, Book book) onTapUnit;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = const TextStyle(
      color: Colors.grey,
      fontSize: 13,
    );
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            onTapUnit(unit, subChapter, parentChapter, book,);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PrefixIndent(
                  depth: unit.depth,
                ),
                SizedBox(
                  width: 30,
                  height: 30,
                  child: MaterialButton(
                    padding: EdgeInsets.zero,
                    color: Colors.transparent,
                    disabledColor: Colors.transparent,
                    textColor: Colors.white,
                    elevation: 0,
                    onPressed: null,
                    child:
                    Text(String.fromCharCode(subChapter.units.indexOf(unit) + 97 + 1), style: textStyle,),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    unit.name,
                    style: textStyle,
                  ),
                ),

              ],
            ),
          ),
        ),
      ],
    );
  }
}
