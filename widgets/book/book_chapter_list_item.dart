/// -----------------------------------------------------------------------
///  [2021] - [2022] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:notebars/classes/book_chapter.dart';

import '../../classes/book_chapter_for_study.dart';
import '../../global.dart';

class BookChapterListItem extends StatelessWidget {
  const BookChapterListItem({Key? key, required this.chapterForStudy, this.onEdit, required this.lastVisited}) : super(key: key);

  final BookChapterForStudy chapterForStudy;
  final Function(BookChapterForStudy)? onEdit;
  final bool lastVisited;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
            leading: const Padding(
              padding: EdgeInsets.only(left: 12),
              child: Icon(Bootstrap.book, size: 36, color: Colors.grey),
            ),
            minLeadingWidth: 0, // Reduce leading icon's width as much as possible
            title: Text(
              '${chapterForStudy.book.name} ${chapterForStudy.chapter.orderOfChapter(chapterForStudy.book)}',
              style: const TextStyle(fontFamily: 'Roboto', fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey),
            ),
            subtitle: Text(chapterForStudy.chapter.name, style: const TextStyle(fontSize: 13, color: Colors.black)),
            trailing: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 60),
                child: Text(
                  app.getLibraryByBook(chapterForStudy.book).name,
                  softWrap: true,
                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w300),
                ),
              ),
            ),
            onTap: onEdit != null ? () => onEdit!(chapterForStudy) : null,
          ),
        ),
        if(lastVisited) const Positioned(
          top: 0,
          right: 10,
          child: Icon(Icons.bookmark, color: Colors.deepPurpleAccent,),),
      ],
    );
  }
}
