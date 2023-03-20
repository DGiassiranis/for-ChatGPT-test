/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:notebars/widgets/book/chapter/add_chapter_widget.dart';

import '../../classes/book.dart';
import '../../classes/book_chapter.dart';

enum ChapterActions { edit, mergeWithPrevious, mergeWithNext, delete }

class ChaptersListToolbar extends StatelessWidget {
  final Book book;
  final BookChapter? currentChapter;
  final Function(BookChapter chapter)? onTapChapter;
  final Function(BookChapter chapter)? onEdit;
  final Function(BookChapter chapter) onMergeUp;
  final Function(BookChapter chapter) onMergeUpSubChapter;
  final Function(BookChapter chapter) onMergeUpUnit;
  final Function(BookChapter chapter) onMergeDown;
  final Function(BookChapter chapter) onMergeDownSubChapter;
  final Function(BookChapter chapter) onMergeDownUnit;
  final Function(BookChapter chapter, ChapterType type) onDelete;
  final Function() addChapter;
  final bool bookChanged;

  const ChaptersListToolbar({
    Key? key,
    required this.book,
    this.currentChapter,
    this.onTapChapter,
    this.onEdit,
    required this.onMergeUp,
    required this.onMergeUpSubChapter,
    required this.onMergeUpUnit,
    required this.onMergeDown,
    required this.onMergeDownSubChapter,
    required this.onMergeDownUnit,
    required this.onDelete,
    required this.addChapter,
    required this.bookChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ...book.chapters.map(
              (ch) => Column(
                children: [
                  _chapterTitleItem(context, ch, (book.chapters.indexOf(ch) + 1).toString(), ChapterType.chapter),
                  ...ch.subChapters.map((subChapter) => Column(
                    children: [
                      _chapterTitleItem(context, subChapter, '.${ch.subChapters.indexOf(subChapter) + 2}', ChapterType.subChapter),
                      ...subChapter.units.map((unit) => _chapterTitleItem(context, unit, '..${String.fromCharCode(subChapter.units.indexOf(unit) + 97 + 1)}', ChapterType.unit)),
                    ],
                  )),
                ],
              ),
            ), AddChapterWidget(addChapter: addChapter,),
          ],
        ),
      ),
    );
  }

  Widget _chapterTitleItem(BuildContext context, BookChapter ch, String title, ChapterType type) {
    late Offset tapPosition;
    return GestureDetector(
    onTapDown: (data) {
      tapPosition = data.globalPosition;
    },
    child: Container(
      width: type == ChapterType.chapter ? 40: 30,
      height: type == ChapterType.chapter? 40 : 30,
      margin: const EdgeInsets.only(bottom: 10),
      child: MaterialButton(
        shape: type == ChapterType.chapter ? const CircleBorder() : null,
        padding: EdgeInsets.zero,
        color: ch == currentChapter
            ? (ch.length > Book.maxChapterLength ? Colors.pinkAccent.withOpacity(.8) : Colors.deepPurpleAccent)
            : type == ChapterType.unit ? Colors.transparent : (ch.length > Book.maxChapterLength ? Colors.pinkAccent.withOpacity(.4) : Colors.white54),
        textColor: ch == currentChapter ? Colors.white : null,
        elevation: 0,
        onPressed: () {
          if (onTapChapter != null) onTapChapter!(ch);
        },
        onLongPress: () async {
          ChapterActions? selected = await showMenu<ChapterActions>(
            position: RelativeRect.fromLTRB(tapPosition.dx, tapPosition.dy, tapPosition.dx + 1, tapPosition.dy + 1),
            context: context,
            items: [
              if(!bookChanged)PopupMenuItem(
                value: ChapterActions.edit,
                child: Row(children: const [Icon(Icons.edit, color: Colors.black26), SizedBox(width: 10), Text('Edit Note')]),
              ),
              if(!bookChanged)const PopupMenuItem(
                enabled: false,
                height: 5,
                child: Divider(),
              ),
              PopupMenuItem(
                value: ChapterActions.mergeWithPrevious,
                child: Row(children: const [Icon(Icons.file_upload, color: Colors.black26), SizedBox(width: 10), Text('Merge with previous')]),
              ),
              PopupMenuItem(
                value: ChapterActions.mergeWithNext,
                child: Row(children: const [Icon(Icons.file_download, color: Colors.black26), SizedBox(width: 10), Text('Merge with next')]),
              ),
              const PopupMenuItem(
                enabled: false,
                height: 5,
                child: Divider(),
              ),
              PopupMenuItem(
                value: ChapterActions.delete,
                child: Row(children: const [Icon(Icons.delete_forever, color: Colors.redAccent), SizedBox(width: 10), Text('Delete')]),
              ),
            ],
          );
          if (selected == ChapterActions.edit) {
            if(bookChanged) return;
            if (onEdit != null) onEdit!(ch);
          }
          if (selected == ChapterActions.mergeWithPrevious) {
            switch(type){
              case ChapterType.chapter:
                onMergeUp(ch);
                break;
              case ChapterType.subChapter:
                onMergeUpSubChapter(ch);
                break;
              case ChapterType.unit:
                onMergeUpUnit(ch);
                break;
            }
          } else if (selected == ChapterActions.mergeWithNext) {
            switch(type){
              case ChapterType.chapter:
                onMergeDown(ch);
                break;
              case ChapterType.subChapter:
                onMergeDownSubChapter(ch);
                break;
              case ChapterType.unit:
                onMergeDownUnit(ch);
                break;
            }

          } else if (selected == ChapterActions.delete) {
              onDelete(ch, type);
          }
        },
        child: Text(title),
      ),
    ),
  );
  }
}

enum ChapterType{
  chapter,
  subChapter,
  unit,
}