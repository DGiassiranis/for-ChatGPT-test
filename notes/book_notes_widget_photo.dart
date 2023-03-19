/// -----------------------------------------------------------------------
///  [2021] - [2022] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:notebars/classes/book_note.dart';
import 'package:notebars/classes/book_paragraph.dart';
import 'package:notebars/extensions.dart';
import 'package:notebars/widgets/notes/book_notes_widget_row.dart';
import 'package:notebars/widgets/notes/note_bar_image.dart';

class BookNotesWidgetPhoto extends StatelessWidget {
  const BookNotesWidgetPhoto(
      {Key? key,
      required this.note,
      required this.colormap,
      this.onPhotoTap,
      this.onIncreasePhotoSize,
      this.onDecreasePhotoSize,
      this.hasSelectedWords = false})
      : super(key: key);

  final BookNote note;
  final BookColorMap colormap;
  final VoidCallback? onPhotoTap;
  final VoidCallback? onDecreasePhotoSize;
  final VoidCallback? onIncreasePhotoSize;
  final bool hasSelectedWords;

  @override
  Widget build(BuildContext context) {
    if (note.imageData.isEmpty) {
      return onPhotoTap != null && !hasSelectedWords
          ? Icon(Icons.camera_alt_outlined,
              color: colormap[BookParagraph.colorTextPrimary]?.withOpacity(.4))
          : const SizedBox.shrink();
    }

    final hasSizeCallbacks =
        onIncreasePhotoSize != null || onDecreasePhotoSize != null;

    return SizedBox(
      height: BookNotesWidgetRow.rowHeight * note.photoSize.heightMultiplier,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (hasSizeCallbacks)
            const Expanded(
              flex: 0,
              child: SizedBox(),
            ),
          Expanded(
            flex: 2,
            child: NotebarImage(
              note: note,
              colormap: colormap,
              hasSelectedWords: hasSelectedWords,
              onPhotoTap: onPhotoTap,
              onDecreasePhotoSize: onDecreasePhotoSize,
              onIncreasePhotoSize: onIncreasePhotoSize,
            ),
          ),
          if (hasSizeCallbacks) const SizedBox(),
        ],
      ),
    );
  }
}
