/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:notebars/classes/book_note_sync_move.dart';
import 'package:notebars/global.dart';
import 'package:notebars/views/book_notes_view.dart';
import 'package:notebars/widgets/notes/book_notes_bar.dart';

import '../../classes/book_note.dart';
import '../../classes/book_paragraph.dart';
import '../../classes/keyword.dart';
import '../../extensions.dart';
import 'book_notes_widget_toolbar.dart';

class BookNotesWidgetV2 extends StatelessWidget {
  // region Properties
  final BookParagraphGroup paragraphs;
  final BookParagraph? activeParagraph;
  final BookNote? activeNote;
  final BookNote? activatedSentenceOfNote;
  final int initialPage;
  final bool active;
  final List<Keyword> selectedWords;
  final Function(BookParagraph)? onParagraphTap;
  final Function(BookParagraph)? onParagraphDoubleTap;
  final Function(BookParagraph)? onParagraphLongPress;
  final Function(BookParagraph, String, int)? onWordTap;
  final Function(BookParagraph, String, int)? onWordDoubleTap;
  final Function(BookParagraph, String, int)? onWordLongPress;
  final Function()? onToggleExpanded;
  final Function()? onToggleCapitalNotes;
  final Function()? onClearSelection;
  final Function()? onClearSelectionLongPress;
  final Function()? onClearParagraphSelection;
  final Function(BookNote)? onNoteLongPress;
  final Function(BookNote)? onNoteDoubleTap;
  final Function(BookNote)? onNoteTap;
  final Function(BookNote)? onKeywordsTap;
  final Function(BookParagraph)? onLinkWithPrevious;
  final Function(BookParagraph)? onUnlinkWithPrevious;
  final Function(BookParagraph, String)? onChangeColor;
  final Function(BookNote? note, bool? capital, {bool? longpress})?
      onAddActionTap;
  final Function(BookNote? note, bool? capital)? onAddAsKeywords;
  final AddAction addAction;
  final bool addActionLock;
  final Function(BookNote? note)? onAddAsNote;
  final Function(BookNote note)? onAddQuestion;
  final Function(BookNote note)? onPhotoTap;
  final Function(BookNote note, bool)? onPhotoSizeTap;
  final Function(BookNote note)? onShowAnswer;
  final Function(BookNote note, int page, List<BookNote>? notesToChange)
      onNotesIndexChanged;
  final bool hasSelectedWords;
  final bool isNextKeyword;
  final bool keywordsCapital;
  final bool noteWordsCapital;
  final LockStatus lockStatus;
  final Function(BookNote note, int page, List<BookNote>? notes)
      onTransparentIndexChanged;
  final List<BookNoteSyncMove>? bookNoteSyncMoveList;
  final ShiftingStatus shiftingStatus;
  final List<List<BookNote>> continuousNotes;
  final List<BookParagraph> allParagraphs;
  final Map<String, List<int>> lockedIndexes;
  final bool isFirstGroup;

  // endregion

  const BookNotesWidgetV2(
      {Key? key,
      required this.shiftingStatus,
      required this.paragraphs,
        this.isFirstGroup = false,
      this.activeParagraph,
      this.activeNote,
      this.initialPage = 2,
      this.active = false,
      this.selectedWords = const [],
      this.onParagraphTap,
      this.onParagraphDoubleTap,
      this.onParagraphLongPress,
      this.onWordTap,
      this.onWordDoubleTap,
      this.onWordLongPress,
      this.onNoteLongPress,
      this.onNoteDoubleTap,
      this.onNoteTap,
      this.onKeywordsTap,
      this.onToggleExpanded,
      this.onToggleCapitalNotes,
      this.onClearSelection,
      this.onClearSelectionLongPress,
      this.onClearParagraphSelection,
      this.onLinkWithPrevious,
      this.onUnlinkWithPrevious,
      this.onChangeColor,
      this.onAddActionTap,
      this.onAddAsKeywords,
      required this.addAction,
      required this.addActionLock,
      this.onAddAsNote,
      this.onAddQuestion,
      this.onPhotoTap,
      this.onPhotoSizeTap,
      this.onShowAnswer,
      required this.onNotesIndexChanged,
      this.hasSelectedWords = false,
      this.isNextKeyword = false,
      this.keywordsCapital = false,
      this.noteWordsCapital = false,
      this.activatedSentenceOfNote,
      required this.lockStatus,
      required this.onTransparentIndexChanged,
      this.bookNoteSyncMoveList,
      required this.continuousNotes,
      required this.allParagraphs,
      required this.lockedIndexes})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    BookColorMap? colormap = BookParagraph.colors[paragraphs.first.color] ??
        BookParagraph.colors['grey'];
    return Column(
        children: paragraphs
            .map(
              (p) {
                int paragraphIndex = paragraphs.indexOf(p);
                bool shouldAddBullet = !(BookParagraph.darkColors.containsKey(p.color)) && ((paragraphIndex != 0 && paragraphs[paragraphIndex - 1].color != p.color) || paragraphIndex == 0) && p.notes.where((n) => !n.isNullNoteV2).toList().isEmpty;
                bool isFirstParagraph = allParagraphs.first == p && isFirstGroup;
                bool hasSameFormat = paragraphIndex < paragraphs.length - 1 && paragraphs[paragraphIndex + 1].hasSameFormat(p);
                return paragraphWidget(context, p, colormap, p.notes, shouldAddBullet, isFirstParagraph: isFirstParagraph, hasSameFormat: hasSameFormat);
              },
            )
            .toList());
  }

  Widget paragraphWidget(BuildContext context, BookParagraph p,
      BookColorMap? colormap, List<BookNote> notes, bool shouldAddBullet, {bool isFirstParagraph = false, bool hasSameFormat = false}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          if (notes.isNotEmpty)
            BookNotesBar(
              continuousNotes: continuousNotes,
              notes: notes,
              shiftingStatus: shiftingStatus,
              paragraphs: paragraphs,
              onNotesIndexChanged: onNotesIndexChanged,
              hasSelectedWords: hasSelectedWords,
              paragraph: p,
              activeParagraph: activeParagraph,
              activeNote: activeNote,
              colorMap: colormap as BookColorMap,
              onAddAsNote: onAddAsNote,
              onAddQuestion: onAddQuestion,
              onPhotoTap: onPhotoTap,
              onPhotoSizeTap: onPhotoSizeTap,
              onShowAnswer: onShowAnswer,
              onNoteLongPress: onNoteLongPress,
              onNoteDoubleTap: onNoteDoubleTap,
              onNoteTap: onNoteTap,
              onKeywordsTap: onKeywordsTap,
              onAddAsKeywords: onAddAsKeywords,
              selectedWords: selectedWords,
              initialPage: initialPage,
              active: active,
              lockStatus: lockStatus,
              onTransparentIndexChanged: onTransparentIndexChanged,
              bookNoteSyncMoveList: bookNoteSyncMoveList,
            ),
          if (p.uiOptions["expanded"])
            Container(
              color: p.hasBackground ? (BookParagraph.colors[p.color]?[BookParagraph.colorKeyBackground] ?? Colors.transparent) : Colors.transparent,
              padding: EdgeInsets.only(left: p.hasBackground ? app.settings['appFontSize'] ?? 14 : 0),
              child: Container(
                color: p.hasBackground ? (BookParagraph.colors[p.color]?[BookParagraph.colorBackNotes] ?? Colors.transparent) : Colors.transparent,
                padding: EdgeInsets.only(left: 10, right: 10, bottom: p == paragraphs.last || !hasSameFormat ? 20 : 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      children: p.asWidgetSpans(
                        keywordsCapital: keywordsCapital,
                        noteWordsCapital: noteWordsCapital,
                        isNextKeyword: isNextKeyword,
                        colormap: colormap as BookColorMap,
                        selectedWords: p == activeParagraph ? selectedWords : [],
                        active: p == activeParagraph,
                        onWordTap: onWordTap,
                        onWordDoubleTap: onWordDoubleTap,
                        onWordLongPress: onWordLongPress,
                        shiftingStatus: shiftingStatus,
                        addAction: addAction,
                        shouldAddBullet: shouldAddBullet,
                        isTitle: p.isTitleParagraph(),
                      ),
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            ),
          if (!p.uiOptions["expanded"] &&
              activatedSentenceOfNote != null &&
              p == activeParagraph)
            Row(
              children: [
                if((paragraphs.notes).containsUuid(activatedSentenceOfNote?.uuid ?? 'no_uuid_found_404')) SvgPicture.asset(
                  'assets/svg/notes/bullets/abullet11b.svg',
                  color: colormap![BookParagraph.colorTextSecondary],
                  height: 50,
                  fit: BoxFit.fitHeight,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                          children: p.asWidgetSpans(
                            activatedSentenceOfNote: activatedSentenceOfNote,
                            keywordsCapital: keywordsCapital,
                            noteWordsCapital: noteWordsCapital,
                            isNextKeyword: isNextKeyword,
                            colormap: colormap as BookColorMap,
                            selectedWords: p == activeParagraph ? selectedWords : [],
                            active: p == activeParagraph,
                            onWordTap: onWordTap,
                            onWordDoubleTap: onWordDoubleTap,
                            onWordLongPress: onWordLongPress,
                            addAction: addAction,
                            shiftingStatus: shiftingStatus,
                            shouldAddBullet: shouldAddBullet,
                            isTitle: p.isTitleParagraph(),
                          ),
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),
                ),
                if((paragraphs.notes).containsUuid(activatedSentenceOfNote?.uuid ?? 'no_uuid_found_404')) Transform.rotate(
                  angle: pi,
                  child: SvgPicture.asset(
                    'assets/svg/notes/bullets/abullet11b.svg',
                    color: colormap[BookParagraph.colorTextSecondary],
                    height: 50,
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
