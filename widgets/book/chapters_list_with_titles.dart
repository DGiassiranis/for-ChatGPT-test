import 'package:flutter/material.dart';
import 'package:notebars/classes/book.dart';
import 'package:notebars/classes/book_chapter.dart';
import 'package:notebars/widgets/book/chapter/add_chapter_widget.dart';
import 'package:notebars/widgets/book/chapter/chapter_title_widget.dart';
import 'package:notebars/widgets/book/chapter/sub_chapter_title_widget.dart';

class ChaptersListWithTitles extends StatelessWidget {
  const ChaptersListWithTitles({
    Key? key,
    required this.book,
    this.parentChapter,
    required this.onTapChapter,
    required this.onTapSubChapter,
    required this.onTapUnit,
    required this.addChapter,
  }) : super(key: key);

  final Book book;
  final BookChapter? parentChapter;
  final Function(BookChapter chapter) onTapChapter;
  final Function(
    BookChapter subChapter,
    BookChapter parentChapter,
    Book book,
  ) onTapSubChapter;
  final Function(BookChapter unit, BookChapter subChapter,
      BookChapter parentChapter, Book book) onTapUnit;
  final Function() addChapter;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ...book.chapters
              .map((chapter) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      children: [
                        ChapterTitleWidget(
                          chapter: chapter,
                          onTapChapter: onTapChapter,
                          book: book,
                        ),
                        ...chapter.subChapters
                            .map((subChapter) => SubChapterTitleWidget(
                                  subChapter: subChapter,
                                  parentChapter: chapter,
                                  onTapSubChapter: onTapSubChapter,
                                  onTapUnit: onTapUnit,
                                  book: book,
                                ))
                            .toList(),
                      ],
                    ),
                  ))
              .toList(),
          Row(
            children: [
              SizedBox(width: 60, child: AddChapterWidget(addChapter: addChapter,),),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }
}
