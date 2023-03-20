import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:notebars/classes/book_note.dart';
import 'package:notebars/classes/book_paragraph.dart';
import 'package:notebars/extensions.dart';
import 'package:notebars/global.dart';
import 'package:notebars/views/settings_view.dart';
import 'package:notebars/widgets/notes/book_notes_widget_photo.dart';
import 'package:notebars/widgets/notes/book_notes_widget_row.dart';

class KeyAndNoteBar extends StatelessWidget {
  const KeyAndNoteBar(
      {Key? key,
      required this.paragraphs,
      required this.hasSelectedWords,
      this.customNotes,
      required this.colormap,
      required this.mode,
      this.activeParagraph,
      this.activeNote,
      this.onAddAsKeyword,
      this.onNoteLongPress,
      this.onNoteDoubleTap,
      this.onNoteTap,
      this.onKeywordsTap,
      this.onPhotoTap,
      this.onPhotoSizeTap,
      this.onAddAsNote,
      this.onAddQuestion,
      this.onShowAnswer,
      this.explicitHeight,
      required this.note})
      : super(key: key);

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
    final dynamicSymbolHeight = (explicitHeight ?? note.noteHeight) * .8;
    final dynamicSymbolHeightNoteAndKey = note.noteBarSize == NoteNoteBarSize.small ? (explicitHeight ?? note.noteHeight) * .8 : note.noteBarSize == NoteNoteBarSize.medium ? (explicitHeight ?? note.noteHeight) * .7 : (explicitHeight ?? note.noteHeight) * .6 ;
    final insideActiveParagraph = activeParagraph == noteBelongsTo(note);
    const double textHeight = 1.4;
    final spaceBetweenPadding = 15 - 10*(1.8 - (app.settings['notebarsFontSize'] ?? 1.0));
    return note.isNullNoteV2
        ? const SizedBox()
        : GestureDetector(
            onLongPress: () =>
                onNoteLongPress != null ? onNoteLongPress!(note) : null,
            onDoubleTap: () =>
                onNoteDoubleTap != null ? onNoteDoubleTap!(note) : null,
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // region Left-side (Keywords)
                    GestureDetector(
                      onTap: () =>
                          onKeywordsTap != null ? onKeywordsTap!(note) : null,
                      child: Container(
                          width: MediaQuery.of(context).size.width * .4,
                          height: explicitHeight ?? note.noteHeight,
                          padding: EdgeInsets.only(
                              left: 5,
                              right: spaceBetweenPadding,
                              top: 5),
                          decoration: BoxDecoration(
                            color: paragraphs.indexOf(noteBelongsTo(note)).isOdd
                                ? colormap[BookParagraph.colorBackKeywords]
                                : colormap[BookParagraph.colorBackKeywords],
                          ),
                          child: note.keywords.isNotEmpty
                              ? Column(
                                  mainAxisAlignment: (note
                                                  .symbolAssetPath.isNotEmpty &&
                                              (note.keywords.isEmpty ||
                                                  note.notewords.isEmpty)) ||
                                          note.imageData.isNotEmpty
                                      ? MainAxisAlignment.center
                                      : MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
(                                      note.name.isNotEmpty
                                          ? note.name
                                          : note.keywords.words.join(' ')),
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                          height: textHeight,
                                          color: colormap[
                                              BookParagraph.colorTextPrimary],
                                          fontSize: 14.0 * (app.settings["notebarsFontSize"] ?? notebarsDefaultFontMultiplier),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )
                              : Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if(note.symbolAssetPath.isNotEmpty) SvgPicture.asset(
                                            note.symbolAssetPath,
                                            color: colormap[BookParagraph.colorTextPrimary],
                                            width: dynamicSymbolHeight,
                                            height: dynamicSymbolHeight,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                    ),
                    // endregion

                    // region Right-side (keynotes / photo)
                    GestureDetector(
                      onTap: () => !insideActiveParagraph
                          ? null
                          : (onPhotoTap != null ? onPhotoTap!(note) : null),
                      child: Container(
                          width: MediaQuery.of(context).size.width * .6,
                          height: explicitHeight ?? note.noteHeight,
                          padding: EdgeInsets.only(
                              left: spaceBetweenPadding,
                              top: 5,
                              right: 5),
                          decoration: BoxDecoration(
                            color: paragraphs.indexOf(noteBelongsTo(note)).isOdd
                                ? colormap[BookParagraph.colorBackNotes]
                                : colormap[BookParagraph.colorBackNotes],
                          ),
                          child: note.note.isNotEmpty
                              ? GestureDetector(
                                  onTap: onNoteTap != null
                                      ? () {
                                          onNoteTap!(note);
                                        }
                                      : null,
                                  child: Column(
                                    mainAxisAlignment:
                                    (note.keywords.isEmpty && note.symbolAssetPath.isNotEmpty) ? MainAxisAlignment.center : MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if(note.symbolAssetPath.isNotEmpty && note.keywords.isNotEmpty) SvgPicture.asset(
                                            note.symbolAssetPath,
                                            color: colormap[BookParagraph.colorTextPrimary],
                                            width: dynamicSymbolHeightNoteAndKey,
                                            height: dynamicSymbolHeightNoteAndKey,
                                          ),
                                          if(note.symbolAssetPath.isNotEmpty && note.keywords.isNotEmpty) const SizedBox(width: 5,),
                                          Expanded(
                                            child: Text(
                                              note.note,
                                              style: TextStyle(
                                                height: textHeight,
                                                fontSize: 14.0 * (app.settings["notebarsFontSize"] ?? notebarsDefaultFontMultiplier),
                                                color: colormap[
                                                    BookParagraph.colorTextPrimary],
                                              ),
                                            ),
                                          ),

                                        ],
                                      ),
                                    ],
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
                                  : note.symbolAssetPath.isNotEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  SvgPicture.asset(
                                                    note.symbolAssetPath,
                                                    color: colormap[
                                                        BookParagraph
                                                            .colorTextPrimary],
                                                    width: dynamicSymbolHeight,
                                                    height: dynamicSymbolHeight,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      : insideActiveParagraph &&
                                              !hasSelectedWords
                                          ? BookNotesWidgetPhoto(
                                              hasSelectedWords:
                                                  hasSelectedWords,
                                              note: note,
                                              colormap: colormap,
                                              onPhotoTap: onPhotoTap != null
                                                  ? () => onPhotoTap!(note)
                                                  : null,
                                              onIncreasePhotoSize:
                                                  onPhotoSizeTap != null &&
                                                          note.photoSize !=
                                                              NotePhotoSize
                                                                  .large
                                                      ? () => onPhotoSizeTap!(
                                                          note, true)
                                                      : null,
                                              onDecreasePhotoSize:
                                                  onPhotoSizeTap != null &&
                                                          note.photoSize !=
                                                              NotePhotoSize
                                                                  .small
                                                      ? () => onPhotoSizeTap!(
                                                          note, false)
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
                                                  fontSize: 14.0 * (app.settings["notebarsFontSize"] ?? notebarsDefaultFontMultiplier),
                                                  height: textHeight,
                                                  color: colormap[BookParagraph
                                                      .colorTextPrimary],
                                                ),
                                              ),
                                            )),
                    ),
                    // endregion
                  ],
                ),
                // if (note.keywords.isNotEmpty &&
                //     (note.notewords.isNotEmpty || note.imageData.isNotEmpty) &&
                //     note.symbolAssetPath.isNotEmpty)
                //   Positioned(
                //     left: MediaQuery.of(context).size.width * 0.4 -
                //         symbolSize / 2,
                //     child: Row(
                //       crossAxisAlignment: CrossAxisAlignment.center,
                //       mainAxisAlignment: MainAxisAlignment.start,
                //       children: [
                //         Column(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             SvgPicture.asset(
                //               note.symbolAssetPath,
                //               color: colormap[BookParagraph.colorTextPrimary],
                //               width: symbolSize,
                //               height: symbolSize,
                //             ),
                //           ],
                //         ),
                //       ],
                //     ),
                //   )
              ],
            ),
          );
  }

  BookParagraph noteBelongsTo(BookNote note) {
    try {
      return paragraphs.firstWhere((p) => p.notes.contains(note));
    } catch (_) {
      return paragraphs.last;
    }
  }
}
