/// -----------------------------------------------------------------------
///  [2021] - [2022] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../classes/book.dart';
import '../../classes/book_chapter.dart';
import '../../widgets/library/book_merge_chapters_list_item.dart';

class BookMergeChaptersList extends StatelessWidget {
  const BookMergeChaptersList(
      {Key? key, required this.originalBook, required this.chapters, required this.availableBooks, this.onWillAccept, this.onAccept, this.onDropBack})
      : super(key: key);

  final Book originalBook;
  final List<BookChapter> chapters;
  final List<Book> availableBooks;
  final Function(BookChapter?, int)? onWillAccept;
  final Function(BookChapter, int)? onAccept;
  final Function(BookChapter, int)? onDropBack;

  @override
  Widget build(BuildContext context) {
    var dropBooks = availableBooks.map((b) => BookChapter(uuid: b.uuid, name: b.name)).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: ListView.builder(
            shrinkWrap: true,
            itemBuilder: (_, index) => index < chapters.length
                ? BookMergeChaptersListItem(
                    key: UniqueKey(),
                    chapter: chapters[index],
                    index: index,
                    draggable: !originalBook.chapters.contains(chapters[index]),
                    onWillAccept: onWillAccept,
                    onAccept: onAccept,
                  )
                : BookMergeChaptersListItem(
                    chapter: BookChapter(name: ''),
                    index: chapters.length,
                    onWillAccept: onWillAccept,
                    onAccept: onAccept,
                  ),
            itemCount: chapters.length + 1,
          ),
        ),
        Expanded(
          flex: 1,
          child: ListView.builder(
            shrinkWrap: true,
            itemBuilder: (_, index) => index < dropBooks.length
                ? BookMergeChaptersListItem(
                    chapter: BookChapter(uuid: dropBooks[index].uuid, name: dropBooks[index].name),
                    index: index,
                    draggable: true,
                    onWillAccept: onWillAccept,
                    onAccept: onAccept,
                  )
                : BookMergeChaptersListItem(
                    chapter: BookChapter(name: ' '),
                    index: 0,
                    onWillAccept: (chapter, index) => chapters.contains(chapter),
                    onAccept: onDropBack,
                  ),
            itemCount: dropBooks.length + (chapters.length > originalBook.chapters.length ? 1 : 0),
          ),
        ),
      ],
    );
  }
}
