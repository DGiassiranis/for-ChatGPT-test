/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:notebars/common/note_constant.dart';

import '../../classes/book_note.dart';
import '../../classes/book_paragraph.dart';
import '../../extensions.dart';
import '../../global.dart';
import '../notes/book_notes_widget_photo.dart';

enum BookNotesRenderMode { questions, keywords, notes, photos }

class BookNotesWidgetRow extends StatelessWidget {
  static const selectedNoteColor = Colors.black54;

  // region Properties
  final BookParagraphGroup paragraphs;
  final bool hasSelectedWords;
  final List<BookNote>? customNotes;
  final BookColorMap colormap;
  final BookNotesRenderMode mode;
  final BookParagraph? activeParagraph;
  final BookNote? activeNote;
  final Function(BookNote?, bool?)? onAddAsKeyword;
  final Function(BookNote)? onNoteLongPress;
  final Function(BookNote)? onNoteDoubleTap;
  final Function(BookNote)? onNoteTap;
  final Function(BookNote)? onKeywordsTap;
  final Function(BookNote)? onPhotoTap;
  final Function(BookNote, bool)? onPhotoSizeTap;
  final Function(BookNote?)? onAddAsNote;
  final Function(BookNote)? onAddQuestion;
  final Function(BookNote)? onShowAnswer;
  final double? explicitHeight;
  final BookNote note;

  // endregion

  // region Getters/setters
  static double get rowHeight => app.settings['noteRowHeight'];

  // endregion

  const BookNotesWidgetRow({
    Key? key,
    required this.paragraphs,
    this.customNotes,
    this.explicitHeight,
    required this.mode,
    required this.colormap,
    required this.activeParagraph,
    required this.activeNote,
    this.onNoteLongPress,
    this.onNoteDoubleTap,
    this.onNoteTap,
    this.onKeywordsTap,
    this.onAddAsKeyword,
    this.onAddAsNote,
    this.onAddQuestion,
    this.onPhotoTap,
    this.onPhotoSizeTap,
    this.onShowAnswer,
    this.hasSelectedWords = false,
    required this.note,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {


    return _bookNotesRowItems(context, note.noteIndex ?? 1);
  }

  Widget _bookNotesRowItems(BuildContext context, int index) {
    final insideActiveParagraph =
        activeParagraph == noteBelongsTo(note);
    switch (index) {
      case NoteConstant.justNoteIndex:
        return GestureDetector(
          onLongPress: () =>
          onNoteLongPress != null ? onNoteLongPress!(note) : null,
          onDoubleTap: () =>
          onNoteDoubleTap != null ? onNoteDoubleTap!(note) : null,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // region Left-side (Keywords)
              Container(
                width: MediaQuery.of(context).size.width * .1,
                height: explicitHeight ??
                    rowHeight *
                        (note.imageData.isNotEmpty
                            ? note.photoSize.heightMultiplier
                            : 1),
                padding:
                const EdgeInsets.only(left: 5, right: 10, top: 5),
                decoration: BoxDecoration(
                  color: paragraphs.indexOf(noteBelongsTo(note)).isOdd
                      ? colormap[BookParagraph.colorBackKeywords]
                      : colormap[BookParagraph.colorBackKeywords],
                  // Red border with the width is equal to 5
                  border: note == activeNote
                      ? const Border(
                      left: BorderSide(
                          width: 4, color: selectedNoteColor))
                      : null,
                ),
                alignment: note.imageData.isNotEmpty
                    ? Alignment.centerRight
                    : null,
              ),
              // endregion

              // region Right-side (keynotes / photo)
              GestureDetector(
                onTap: () => !insideActiveParagraph
                    ? null
                    : (onPhotoTap != null ? onPhotoTap!(note) : null),
                child: Container(
                    width: MediaQuery.of(context).size.width * .9,
                    height: explicitHeight ??
                        rowHeight *
                            (note.imageData.isNotEmpty
                                ? note.photoSize.heightMultiplier
                                : 1),
                    padding:
                    const EdgeInsets.only(left: 10, top: 5, right: 5),
                    decoration: BoxDecoration(
                      color: paragraphs.indexOf(noteBelongsTo(note)).isOdd
                          ? colormap[BookParagraph.colorBackNotes]
                          : colormap[BookParagraph.colorBackNotes],
                      // Red border with the width is equal to 5
                      border: note == activeNote
                          ? const Border(
                          right: BorderSide(
                              width: 4, color: selectedNoteColor))
                          : null,
                    ),
                    child: note.note.isNotEmpty
                        ? GestureDetector(
                      onTap: onNoteTap != null
                          ? () {
                        onNoteTap!(note);
                      }
                          : null,
                      child: Text(
                        note.note,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: colormap[
                          BookParagraph.colorTextPrimary],
                        ),
                      ),
                    )
                        : (note.imageData.isNotEmpty)
                        ? BookNotesWidgetPhoto(
                      hasSelectedWords: hasSelectedWords,
                      note: note,
                      colormap: colormap,
                      onPhotoTap: onPhotoTap != null
                          ? () => onPhotoTap!(note)
                          : null,
                      onIncreasePhotoSize: onPhotoSizeTap !=
                          null &&
                          note.photoSize !=
                              NotePhotoSize.large
                          ? () => onPhotoSizeTap!(note, true)
                          : null,
                      onDecreasePhotoSize: onPhotoSizeTap !=
                          null &&
                          note.photoSize !=
                              NotePhotoSize.small
                          ? () => onPhotoSizeTap!(note, false)
                          : null,
                    )
                        : insideActiveParagraph && !hasSelectedWords
                        ? BookNotesWidgetPhoto(
                      hasSelectedWords: hasSelectedWords,
                      note: note,
                      colormap: colormap,
                      onPhotoTap: onPhotoTap != null
                          ? () => onPhotoTap!(note)
                          : null,
                      onIncreasePhotoSize: onPhotoSizeTap !=
                          null &&
                          note.photoSize !=
                              NotePhotoSize.large
                          ? () =>
                          onPhotoSizeTap!(note, true)
                          : null,
                      onDecreasePhotoSize: onPhotoSizeTap !=
                          null &&
                          note.photoSize !=
                              NotePhotoSize.small
                          ? () =>
                          onPhotoSizeTap!(note, false)
                          : null,
                    )
                        : InkWell(
                      onTap: () {
                        if (onNoteTap == null) return;
                        onNoteTap!(note);
                      },
                      child: Text(
                        note.note,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: colormap[BookParagraph
                              .colorTextPrimary],
                        ),
                      ),
                    )),
              ),
              // endregion
            ],
          ),
        );

      case NoteConstant.justKeyIndex:
        return Row(
          children: [
            Container(
              height: explicitHeight ??
                  rowHeight *
                      (note.imageData.isNotEmpty
                          ? note.photoSize.heightMultiplier
                          : 1),
              width: MediaQuery.of(context).size.width * 0.1,
              color: colormap[BookParagraph.colorBackKeywords],
            ),
            GestureDetector(
              onLongPress: () =>
              onNoteLongPress != null ? onNoteLongPress!(note) : null,
              onDoubleTap: () =>
              onNoteDoubleTap != null ? onNoteDoubleTap!(note) : null,
              onTap: () =>
              onKeywordsTap != null ? onKeywordsTap!(note) : null,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: explicitHeight ??
                    rowHeight *
                        (note.imageData.isNotEmpty
                            ? note.photoSize.heightMultiplier
                            : 1),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: (paragraphs.indexOf(noteBelongsTo(note)).isOdd
                      ? colormap[BookParagraph.colorKeyBackground]
                      : colormap[BookParagraph.colorKeyBackground]),
                  // Red border with the width is equal to 5
                  border: note == activeNote
                      ? const Border(
                    left: BorderSide(
                        width: 4, color: selectedNoteColor),
                    right: BorderSide(
                        width: 4, color: selectedNoteColor),
                  )
                      : null,
                ),
                child: note.imageData.isNotEmpty
                    ? Container(
                  height: explicitHeight ?? rowHeight * (note.imageData.isNotEmpty ? note.photoSize.heightMultiplier : 1),
                  padding: const EdgeInsets.only(left: 10, top: 5, right: 5),
                  child: BookNotesWidgetPhoto(
                    note: note,
                    colormap: colormap,
                    onPhotoTap: onPhotoTap == null ? null : () => onPhotoTap!(note),
                    onIncreasePhotoSize: onPhotoSizeTap != null && note.photoSize != NotePhotoSize.large ? () => onPhotoSizeTap!(note, true) : null,
                    onDecreasePhotoSize: onPhotoSizeTap != null && note.photoSize != NotePhotoSize.small ? () => onPhotoSizeTap!(note, false) : null,
                  ),
                )
                    : (note.keywords.isNotEmpty
                    ? Center(
                  child: Text(
                    note.name.isNotEmpty ? note.name : note.keywords.words.join(' '),
                    style: TextStyle(color: colormap[BookParagraph.colorTextPrimary], fontSize: 16, fontWeight: FontWeight.bold,),
                    textAlign: TextAlign.center,
                  ),
                )
                    : (onAddAsKeyword != null && noteBelongsTo(note) == activeParagraph
                    ? TextButton(
                  onPressed: () => onAddAsKeyword!(note, false),
                  child: Row(
                    children: const [Icon(Icons.add), Text('Add here...')],
                  ),
                )
                    : const SizedBox(width: 1))),
              ),
            ),
            Container(
              height: explicitHeight ??
                  rowHeight *
                      (note.imageData.isNotEmpty
                          ? note.photoSize.heightMultiplier
                          : 1),
              width: MediaQuery.of(context).size.width * 0.1,
              color: colormap[BookParagraph.colorBackNotes],
            )
          ],
        );

      case NoteConstant.keyAndNoteIndex:
        return GestureDetector(
          onLongPress: () =>
          onNoteLongPress != null ? onNoteLongPress!(note) : null,
          onDoubleTap: () =>
          onNoteDoubleTap != null ? onNoteDoubleTap!(note) : null,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // region Left-side (Keywords)
              GestureDetector(
                onTap: () =>
                onKeywordsTap != null ? onKeywordsTap!(note) : null,
                child: Container(
                    width: MediaQuery.of(context).size.width * .4,
                    height: explicitHeight ??
                        rowHeight *
                            (note.imageData.isNotEmpty
                                ? note.photoSize.heightMultiplier
                                : 1),
                    padding:
                    const EdgeInsets.only(left: 5, right: 10, top: 5),
                    decoration: BoxDecoration(
                      color: paragraphs.indexOf(noteBelongsTo(note)).isOdd
                          ? colormap[BookParagraph.colorBackKeywords]
                          : colormap[BookParagraph.colorBackKeywords],
                      // Red border with the width is equal to 5
                      border: note == activeNote
                          ? const Border(
                          left: BorderSide(
                              width: 4, color: selectedNoteColor))
                          : null,
                    ),
                    alignment: note.imageData.isNotEmpty
                        ? Alignment.centerRight
                        : null,
                    child: note.keywords.isNotEmpty
                        ? Text(
                      note.name.isNotEmpty
                          ? note.name
                          : note.keywords.words.join(' '),
                      textAlign: note.imageData.isNotEmpty
                          ? TextAlign.center
                          : TextAlign.end,
                      style: TextStyle(
                          color: colormap[
                          BookParagraph.colorTextPrimary],
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    )
                        : null),
              ),
              // endregion

              // region Right-side (keynotes / photo)
              GestureDetector(
                onTap: () => !insideActiveParagraph
                    ? null
                    : (onPhotoTap != null ? onPhotoTap!(note) : null),
                child: Container(
                    width: MediaQuery.of(context).size.width * .6,
                    height: explicitHeight ??
                        rowHeight *
                            (note.imageData.isNotEmpty
                                ? note.photoSize.heightMultiplier
                                : 1),
                    padding:
                    const EdgeInsets.only(left: 10, top: 5, right: 5),
                    decoration: BoxDecoration(
                      color: paragraphs.indexOf(noteBelongsTo(note)).isOdd
                          ? colormap[BookParagraph.colorBackNotes]
                          : colormap[BookParagraph.colorBackNotes],
                      // Red border with the width is equal to 5
                      border: note == activeNote
                          ? const Border(
                          right: BorderSide(
                              width: 4, color: selectedNoteColor))
                          : null,
                    ),
                    child: note.note.isNotEmpty
                        ? GestureDetector(
                      onTap: onNoteTap != null
                          ? () {
                        onNoteTap!(note);
                      }
                          : null,
                      child: Text(
                        note.note,
                        style: TextStyle(
                          color: colormap[
                          BookParagraph.colorTextPrimary],
                        ),
                      ),
                    )
                        : (note.imageData.isNotEmpty)
                        ? BookNotesWidgetPhoto(
                      hasSelectedWords: hasSelectedWords,
                      note: note,
                      colormap: colormap,
                      onPhotoTap: onPhotoTap != null
                          ? () => onPhotoTap!(note)
                          : null,
                      onIncreasePhotoSize: onPhotoSizeTap !=
                          null &&
                          note.photoSize !=
                              NotePhotoSize.large
                          ? () => onPhotoSizeTap!(note, true)
                          : null,
                      onDecreasePhotoSize: onPhotoSizeTap !=
                          null &&
                          note.photoSize !=
                              NotePhotoSize.small
                          ? () => onPhotoSizeTap!(note, false)
                          : null,
                    )
                        : insideActiveParagraph && !hasSelectedWords
                        ? BookNotesWidgetPhoto(
                      hasSelectedWords: hasSelectedWords,
                      note: note,
                      colormap: colormap,
                      onPhotoTap: onPhotoTap != null
                          ? () => onPhotoTap!(note)
                          : null,
                      onIncreasePhotoSize: onPhotoSizeTap !=
                          null &&
                          note.photoSize !=
                              NotePhotoSize.large
                          ? () =>
                          onPhotoSizeTap!(note, true)
                          : null,
                      onDecreasePhotoSize: onPhotoSizeTap !=
                          null &&
                          note.photoSize !=
                              NotePhotoSize.small
                          ? () =>
                          onPhotoSizeTap!(note, false)
                          : null,
                    )
                        : InkWell(
                      onTap: () {
                        if (onNoteTap == null) return;
                        onNoteTap!(note);
                      },
                      child: Text(
                        note.note,
                        style: TextStyle(
                          color: colormap[BookParagraph
                              .colorTextPrimary],
                        ),
                      ),
                    )),
              ),
              // endregion
            ],
          ),
        );// endregion

      default:
        return const Spacer();
    }
  }

  BookParagraph noteBelongsTo(BookNote note) {
    return paragraphs.firstWhere((p) => p.notes.contains(note));
  }
}
