
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:notebars/classes/book_note.dart';
import 'package:notebars/classes/book_paragraph.dart';
import 'package:notebars/extensions.dart';
import 'package:notebars/global.dart';
import 'package:notebars/views/settings_view.dart';
import 'package:notebars/widgets/notes/book_notes_widget_photo.dart';
import 'package:notebars/widgets/notes/book_notes_widget_row.dart';



class JustNoteBar extends StatelessWidget {
  const JustNoteBar({Key? key, required this.paragraphs, required this.hasSelectedWords, this.customNotes, required this.colormap, required this.mode, this.activeParagraph, this.activeNote, this.onAddAsKeyword, this.onNoteLongPress, this.onNoteDoubleTap, this.onNoteTap, this.onKeywordsTap, this.onPhotoTap, this.onPhotoSizeTap, this.onAddAsNote, this.onAddQuestion, this.onShowAnswer, this.explicitHeight, required this.note}) : super(key: key);

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

  // region Getters/setters
  static double get rowHeight => app.settings['noteRowHeight'];

  @override
  Widget build(BuildContext context) {

    final double symbolHeight = (explicitHeight ??
        note.noteHeight) * .8;
    final insideActiveParagraph =
        activeParagraph == noteBelongsTo(note);
    const double textHeight = 1.4;
    return note.isNullNoteV2 ? const SizedBox() : GestureDetector(
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
                    note.noteHeight,
            decoration: BoxDecoration(
              color: paragraphs.indexOf(noteBelongsTo(note)).isOdd
                  ? colormap[BookParagraph.colorBackKeywords]
                  : colormap[BookParagraph.colorBackKeywords],

            ),
            alignment: note.imageData.isNotEmpty
                ? Alignment.centerRight
                : null,
            padding: const EdgeInsets.all(2.0),
            child: note.symbolAssetPath.isNotEmpty  && (note.notewords.isNotEmpty || note.imageData.isNotEmpty) ?  Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(note.symbolAssetPath, color: colormap[BookParagraph.colorTextPrimary], height: symbolHeight, width: symbolHeight,),
              ],
            ) : const SizedBox(),
          ),
          // endregion

          // region Right-side (keynotes / photo)
          GestureDetector(
            onTap: () => !insideActiveParagraph
                ? null
                : (onPhotoTap != null ? onPhotoTap!(note) : null),
            child: Container(
                width: MediaQuery.of(context).size.width * .8,
                height: explicitHeight ??
                    note.noteHeight,
                padding:
                const EdgeInsets.only(left: 10, top: 5, right: 5),
                decoration: BoxDecoration(
                  color: paragraphs.indexOf(noteBelongsTo(note)).isOdd
                      ? colormap[BookParagraph.colorBackNotes]
                      : colormap[BookParagraph.colorBackNotes],
                ),
                alignment: note.symbolAssetPath.isNotEmpty && note.imageData.isEmpty ? Alignment.centerLeft : null,
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
                      height: textHeight,
                      fontStyle: FontStyle.italic,
                      fontSize: 14.0 * (app.settings["notebarsFontSize"] ?? notebarsDefaultFontMultiplier),
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
                ) : note.symbolAssetPath.isNotEmpty ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(note.symbolAssetPath, color: colormap[BookParagraph.colorTextPrimary], height: symbolHeight, width: symbolHeight,),
                  ],
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
                      height: 1.4,
                      fontSize: 14.0 * (app.settings["notebarsFontSize"] ?? notebarsDefaultFontMultiplier),
                      fontStyle: FontStyle.italic,
                      color: colormap[BookParagraph
                          .colorTextPrimary],
                    ),
                  ),
                )),
          ),
          Container(
            width: MediaQuery.of(context).size.width * .1,
            height: explicitHeight ??
                note.noteHeight,
            padding:
            const EdgeInsets.only(left: 1, right: 1, top: 5),
            decoration: BoxDecoration(
              color: paragraphs.indexOf(noteBelongsTo(note)).isOdd
                  ? colormap[BookParagraph.colorBackNotes]
                  : colormap[BookParagraph.colorBackNotes],
            ),
            alignment: note.imageData.isNotEmpty
                ? Alignment.centerRight
                : null,
          )
          // endregion
        ],
      ),
    );
  }

  BookParagraph noteBelongsTo(BookNote note) {
    try{
      return paragraphs.firstWhere((p) => p.notes.contains(note));
    }catch(_){
      return paragraphs.last;
    }
  }
}
