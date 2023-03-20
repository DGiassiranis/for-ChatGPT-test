/// -----------------------------------------------------------------------
///  [2021] - [2022] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:flutter/material.dart';

import '../../classes/book_chapter.dart';

class BookMergeChaptersListItem extends StatelessWidget {
  const BookMergeChaptersListItem({Key? key, required this.chapter, required this.index, this.draggable = false, this.onWillAccept, this.onAccept})
      : super(key: key);

  final int index;
  final BookChapter chapter;
  final Function(BookChapter?, int)? onWillAccept;
  final Function(BookChapter, int)? onAccept;
  final bool draggable;

  @override
  Widget build(BuildContext context) {
    var tile = draggable
        ? Card(color: Colors.deepPurple, child: ListTile(dense: true, title: Text(chapter.name, style: const TextStyle(color: Colors.white, fontSize: 12))))
        : (chapter.uuid.isEmpty
            ? Card(
                color: chapter.name.isEmpty ? Colors.transparent : Colors.deepPurple.withOpacity(.1),
                elevation: 0,
                child: ListTile(dense: true, title: Text(chapter.name, style: const TextStyle(color: Colors.deepPurple, fontSize: 12))))
            : Card(child: ListTile(dense: true, title: Text(chapter.name, style: const TextStyle(fontSize: 12)))));

    Widget widget;
    if (draggable) {
      widget = Draggable<BookChapter>(
        data: chapter,
        maxSimultaneousDrags: 1,
        childWhenDragging: Opacity(
          opacity: 0.5,
          child: tile,
        ),
        feedback: Material(
          color: Colors.transparent,
          elevation: 4.0,
          shadowColor: Colors.black26,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2),
            child: tile,
          ),
        ),
        child: tile,
      );
    } else {
      widget = DragTarget<BookChapter>(
        key: UniqueKey(),
        onWillAccept: (c) => onWillAccept!(c, index),
        onAccept: (c) => onAccept!(c, index),
        builder: (BuildContext context, List<BookChapter?> candidateData, List<dynamic> rejectedData) {
          return Column(
            children: <Widget>[
              AnimatedSize(
                duration: const Duration(milliseconds: 100),
                child: candidateData.isEmpty
                    ? Container()
                    : Opacity(
                        opacity: 0.0,
                        child: tile,
                      ),
              ),
              tile,
            ],
          );
        },
      );
    }

    return widget;
  }
}
