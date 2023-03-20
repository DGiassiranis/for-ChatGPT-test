/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:notebars/classes/book_note_sync_move.dart';
import 'package:notebars/views/book_notes_view.dart';
import 'package:notebars/widgets/notes/book_notes_widget_toolbar.dart';

import '../../classes/book.dart';
import '../../classes/book_chapter.dart';
import '../../classes/book_note.dart';
import '../../classes/book_paragraph.dart';
import '../../classes/keyword.dart';
import '../../extensions.dart';

class BookReader extends StatelessWidget {
  final Book book;
  final BookChapter? chapter;
  final BookParagraph? activeParagraph;
  final BookNote? activeNote;
  final BookRenderMode mode;
  final List<Keyword> selectedWords;
  final Function(BookParagraph paragraph)? onParagraphTap;
  final Function(BookParagraph paragraph)? onParagraphDoubleTap;
  final Function(BookParagraph paragraph)? onParagraphLongPress;
  final Function(BookParagraph paragraph, String word, int wordCount)?
      onWordTap;
  final Function(BookParagraph paragraph, String word, int wordCount)?
      onWordDoubleTap;
  final Function(BookParagraph paragraph, String word, int wordCount)?
      onWordLongPress;

  final Function(BookParagraph paragraph)? onToggleExpanded;
  final Function()? onToggleCapitalNotes;
  final Function()? onClearSelection;
  final Function()? onClearSelectionLongPress;
  final Function()? onClearParagraphSelection;
  final Function(BookParagraph paragraph)? onLinkWithPrevious;
  final Function(BookParagraph paragraph)? onUnlinkWithPrevious;
  final Function(BookParagraph paragraph, String color)? onChangeColor;
  final Function(BookNote)? onNoteLongPress;
  final Function(BookNote)? onNoteDoubleTap;
  final Function(BookNote)? onNoteTap;
  final Function(BookNote)? onKeywordsTap;
  final Function(BookNote? note, bool? capital, {bool? longpress})?
      onAddActionTap;
  final Function(BookNote? note, bool? capital)? onAddAsKeywords;
  final AddAction addAction;
  final bool addActionLock;
  final Function(BookNote? note)? onAddAsNote;
  final Function(BookNote note)? onAddQuestion;
  final Function(BookNote note)? onPhotoTap;
  final Function(BookNote note, bool increase)? onPhotoSizeTap;
  final Function(BookNote note)? onShowAnswer;
  final Function(BookNote note, int, List<BookNote>? notesToChange) onNotesIndexChanged;
  final bool hasSelectedWords;
  final bool isNextKeyword;
  final bool keywordsCapital;
  final bool noteWordsCapital;
  final BookNote? activatedSentenceOfNote;
  final ShiftingStatus shiftingStatus;
  final LockStatus lockStatus;
  final Function(BookNote note, int page, List<BookNote>? notes) onTransparentIndexChanged;
  final List<BookNoteSyncMove>? bookNoteSyncMoveList;
  final Map<String, List<int>> lockedIndexes;
  final bool? hasFirstNotes;
  final ScrollController? scrollController;


  const BookReader({
    Key? key,
    required this.book,
    this.chapter,
    this.activeParagraph,
    this.activeNote,
    this.mode = BookRenderMode.read,
    this.selectedWords = const [],
    this.onParagraphTap,
    this.onParagraphDoubleTap,
    this.onParagraphLongPress,
    this.onWordTap,
    this.onWordDoubleTap,
    this.onWordLongPress,
    this.onToggleExpanded,
    this.onToggleCapitalNotes,
    this.onClearSelection,
    this.onClearSelectionLongPress,
    this.onClearParagraphSelection,
    this.onLinkWithPrevious,
    this.onUnlinkWithPrevious,
    this.onChangeColor,
    this.onNoteLongPress,
    this.onNoteDoubleTap,
    this.onNoteTap,
    this.onKeywordsTap,
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
    required this.shiftingStatus,
    required this.lockStatus,
    required this.onTransparentIndexChanged,
    this.bookNoteSyncMoveList,
    required this.lockedIndexes,
    this.hasFirstNotes,
    this.scrollController,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      color: const Color(0xfff5f2ec),
      width: double.infinity,
      height: Get.height,
      child: book.render(
        hasFirstNotes: hasFirstNotes ?? true,
        lockedIndexes: lockedIndexes,
        bookNoteSyncMoveList: bookNoteSyncMoveList,
        shiftingStatus: shiftingStatus,
        lockStatus: lockStatus,
        onTransparentIndexChanged: onTransparentIndexChanged,
        keywordsCapital: keywordsCapital,
        noteWordsCapital: noteWordsCapital,
        hasSelectedWords: hasSelectedWords,
        chapter: chapter,
        paragraph: activeParagraph,
        note: activeNote,
        selectedWords: selectedWords,
        mode: mode,
        onParagraphTap: onParagraphTap,
        onParagraphDoubleTap: onParagraphDoubleTap,
        onParagraphLongPress: onParagraphLongPress,
        onNoteLongPress: onNoteLongPress,
        onNoteDoubleTap: onNoteDoubleTap,
        onNoteTap: onNoteTap,
        onKeywordsTap: onKeywordsTap,
        onWordTap: onWordTap,
        onWordDoubleTap: onWordDoubleTap,
        onWordLongPress: onWordLongPress,
        onToggleExpanded: onToggleExpanded,
        onToggleCapitalNotes: onToggleCapitalNotes,
        onClearSelection: onClearSelection,
        onClearSelectionLongPress: onClearSelectionLongPress,
        onClearParagraphSelection: onClearParagraphSelection,
        onLinkWithPrevious: onLinkWithPrevious,
        onUnlinkWithPrevious: onUnlinkWithPrevious,
        onChangeColor: onChangeColor,
        onAddActionTap: onAddActionTap,
        addAction: addAction,
        addActionLock: addActionLock,
        onAddAsNote: onAddAsNote,
        onAddQuestion: onAddQuestion,
        onPhotoTap: onPhotoTap,
        onPhotoSizeTap: onPhotoSizeTap,
        onShowAnswer: onShowAnswer,
        onNotesIndexChanged: onNotesIndexChanged,
        isNextKeyword: isNextKeyword,
          activatedSentenceOfNote: activatedSentenceOfNote,
        scrollController: scrollController,
      ),
    );
  }
}
