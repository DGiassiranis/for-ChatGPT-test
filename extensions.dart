/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'dart:convert';
import 'dart:math';

import 'package:aneya_json/json.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:notebars/classes/book_note_sync_move.dart';
import 'package:notebars/views/book_notes_view.dart';
import 'package:notebars/views/settings_view.dart';
import 'package:notebars/widgets/notes/book_notes_widget_toolbar.dart';
import 'package:notebars/widgets/notes/book_notes_widget_v2.dart';
import 'package:uuid/uuid.dart';

import 'classes/book.dart';
import 'classes/book_chapter.dart';
import 'classes/book_library.dart';
import 'classes/book_note.dart';
import 'classes/book_paragraph.dart';
import 'classes/keyword.dart';
import 'global.dart';
import 'widgets/book/paragraph_import_reader.dart';
import 'widgets/book/paragraph_simple_reader.dart';
import 'widgets/notes/book_notes_widget_row.dart';

typedef BookParagraphGroup = List<BookParagraph>;
typedef BookColorMap = Map<String, Color>;

extension BookChapterWidgets on BookChapter {
  List<Widget> render({
    BookRenderMode mode = BookRenderMode.notes,
    bool onlyFirstWords = false,
    BookParagraph? activeParagraph,
    BookNote? activeNote,
    List<Keyword> selectedWords = const [],
    Function(BookParagraph paragraph)? onParagraphTap,
    Function(BookParagraph paragraph)? onParagraphDoubleTap,
    Function(BookParagraph paragraph)? onParagraphLongPress,
    Function(BookNote)? onNoteLongPress,
    Function(BookNote)? onNoteDoubleTap,
    Function(BookNote)? onNoteTap,
    Function(BookNote)? onKeywordsTap,
    Function(BookParagraph paragraph, String word, int wordCount)? onWordTap,
    Function(BookParagraph paragraph, String word, int wordCount)? onWordDoubleTap,
    Function(BookParagraph paragraph, String word, int wordCount)? onWordLongPress,
    Function(BookParagraph paragraph)? onToggleExpanded,
    Function()? onToggleCapitalNotes,
    Function()? onClearSelection,
    Function()? onClearSelectionLongPress,
    Function()? onClearParagraphSelection,
    Function(BookParagraph)? onLinkWithPrevious,
    Function(BookParagraph)? onUnlinkWithPrevious,
    Function(BookParagraph paragraph, String color)? onChangeColor,
    Function(BookNote? note, bool? capital, {bool? longpress})? onAddActionTap,
    Function(BookNote? note, bool? capital)? onAddAsKeywords,
    required AddAction addAction,
    required bool addActionLock,
    Function(BookNote? note)? onAddAsNote,
    Function(BookNote note)? onAddQuestion,
    Function(BookNote note)? onPhotoTap,
    Function(BookNote note, bool)? onPhotoSizeTap,
    Function(BookNote note)? onShowAnswer,
    required Function(BookNote note, int page, List<BookNote>? notesToChange) onNotesIndexChanged,
    Function(BookChapter onEdit)? onEdit,
    bool hasSelectedWords = false,
    bool isNextKeyword = false,
    bool keywordsCapital = false,
    bool noteWordsCapital = false,
    BookNote? activatedSentenceOfNote,
    required ShiftingStatus shiftingStatus,
    required LockStatus lockStatus,
    required Function(BookNote note, int page, List<BookNote>? notes) onTransparentIndexChanged,
    List<BookNoteSyncMove>? bookNoteSyncMoveList,
    required List<BookParagraphGroup> customGroups,
    required Map<String, List<int>> lockedIndexes
  }) {

    if (mode == BookRenderMode.notes) {

      return
      [
        ...groups
            .map((group) => group.render(
          isFirstGroup: group == groups.first,
          lockedIndexes: lockedIndexes,
          allParagraphs: group.paragraphs,
          bookNoteSyncMoveList: bookNoteSyncMoveList,
          lockStatus: lockStatus,
          onTransparentIndexChanged: onTransparentIndexChanged,
          shiftingStatus: shiftingStatus,
          activatedSentenceOfNote: activatedSentenceOfNote,
          isNextKeyword: isNextKeyword,
          hasSelectedWords: hasSelectedWords,
          keywordsCapital: keywordsCapital,
          noteWordsCapital: noteWordsCapital,
                  activeParagraph: activeParagraph,
                  activeNote: activeNote,
                  selected: activeParagraph != null && paragraphs.contains(activeParagraph),
                  selectedWords: activeParagraph != null && paragraphs.contains(activeParagraph) ? selectedWords : [],
                  onWordTap: onWordTap,
                  onWordDoubleTap: onWordDoubleTap,
                  onWordLongPress: onWordLongPress,
                  onParagraphTap: onParagraphTap,
                  onParagraphDoubleTap: onParagraphDoubleTap,
                  onParagraphLongPress: onParagraphLongPress,
                  onNoteLongPress: onNoteLongPress,
                  onNoteDoubleTap: onNoteDoubleTap,
                  onNoteTap: onNoteTap,
                  onKeywordsTap: onKeywordsTap,
                  onClearSelection: onClearSelection,
                  onClearSelectionLongPress: onClearSelectionLongPress,
                  onClearParagraphSelection: onClearParagraphSelection,
                  onToggleExpanded: onToggleExpanded,
                  onToggleCapitalNotes: onToggleCapitalNotes,
                  onLinkWithPrevious: activeParagraph != null && paragraphs.indexOf(activeParagraph) > 0 ? onLinkWithPrevious : null,
                  onUnlinkWithPrevious: activeParagraph != null && paragraphs.indexOf(activeParagraph) > 0 ? onUnlinkWithPrevious : null,
                  onChangeColor: onChangeColor,
          onAddActionTap: onAddActionTap,
          onAddAsKeywords: onAddAsKeywords,
                  addAction: addAction,
                  addActionLock: addActionLock,
                  onAddAsNote: onAddAsNote,
                  onAddQuestion: onAddQuestion,
                  onPhotoTap: onPhotoTap,
                  onPhotoSizeTap: onPhotoSizeTap,
                  onShowAnswer: onShowAnswer,
                  onNotesIndexChanged: onNotesIndexChanged,
          continuousNotes: [],
                ))
            .toList()
      ];
    } else {
      return [
        ...paragraphs
            .map((p) => p.render(
          mode: mode,
          onlyFirstWords: onlyFirstWords,
          selected: p == activeParagraph,
          selectedWords: p == activeParagraph ? selectedWords : [],
          onWordTap: onWordTap,
          onWordDoubleTap: onWordDoubleTap,
          onWordLongPress: onWordLongPress,
          onParagraphTap: onParagraphTap,
          onParagraphDoubleTap: onParagraphDoubleTap,
          onParagraphLongPress: onParagraphLongPress,
          onToggleExpanded: onToggleExpanded,
        ))
            .toList()
      ];
    }
  }



  List<List<BookNote>> calculateContinuousNotes(BookNote? activatedSentenceOfNote){
    List<List<BookNote>> calculatedList = [];

    List<BookNote> allNotes = getAllNotes();

    if(allNotes.isEmpty) return [];

    String previousParagraphUuid = allNotes.first.paragraphUuid;

    List<BookNote> matchingNotes = [];
    for(BookNote note in allNotes){
      if(note == activatedSentenceOfNote){
        BookParagraph paragraph = paragraphs.firstWhere((p) => p.uuid == note.paragraphUuid);
        previousParagraphUuid =  paragraph.uuid;
        int paragraphIndex = paragraphs.indexOf(paragraph);
        if(paragraphIndex > 0 && paragraphs[paragraphIndex - 1].isExpanded){
          calculatedList.add(matchingNotes);
          matchingNotes = [];
        }
        matchingNotes.add(note);
        calculatedList.add(matchingNotes);
        matchingNotes = [];
        continue;
      }
      if(note.paragraphUuid == previousParagraphUuid){
        if(matchingNotes.isNotEmpty && note.noteIndex == matchingNotes.last.noteIndex){
          matchingNotes.add(note);
        }else if(matchingNotes.isEmpty){
          matchingNotes.add(note);
        } else{
          calculatedList.add(matchingNotes);
          matchingNotes = [];
          matchingNotes.add(note);
        }
      }else{
        BookParagraph paragraph = paragraphs.firstWhere((p) => p.uuid == note.paragraphUuid);
        previousParagraphUuid =  paragraph.uuid;
        int paragraphIndex = paragraphs.indexOf(paragraph);
        if(paragraphIndex > 0 && paragraphs[paragraphIndex - 1].isExpanded){
          calculatedList.add(matchingNotes);
          matchingNotes = [];
        } else if(!(matchingNotes.isNotEmpty && matchingNotes.last.noteIndex == note.noteIndex)){
          calculatedList.add(matchingNotes);
          matchingNotes = [];
        }
        matchingNotes.add(note);
      }
    }
    if(matchingNotes.isNotEmpty){
      calculatedList.add(matchingNotes);
    }

    calculatedList.removeWhere((l) => l.isEmpty);

    return calculatedList;
  }

  List<BookNote> getAllNotes(){
    List<BookNote> calculatedNotes = [];

    for (var p in paragraphs) {
      calculatedNotes.addAll(p.notes);
    }

    return calculatedNotes;
  }

}

extension StringListExt on List<String> {

  String getSurroundedSentenceFromPos(int pos){
    List<String> surroundedWords = [];
    for(int index = 0; index < length; index ++){
      if(index - pos <= 0 && index - pos >= -2){
        surroundedWords.add(this[index]);
      }if(pos - index < 0 && pos - index >= -2){
        surroundedWords.add(this[index]);
      }
    }
    return surroundedWords.join(' ');
  }

}

extension BookParagraphGroupUtils on BookParagraphGroup {

  /// Returns all grouped paragraphs as a single list
  List<BookParagraph> get paragraphs => [...map((p) => p)].toList();

  bool containsUuid(String uuid) => firstWhereOrNull((element) => element.uuid == uuid) != null;

  /// Returns all grouped paragraphs notes as a single list
  List<BookNote> get notes => [...map((p) => p.notes)].expand((p) => p).toList();

  /// Returns the total height needed to render all notes in the paragraph group, taking into account the increased height needed to draw photos
  double get notesHeight =>
      notes.fold(0, (sum, note) => 1 + (BookNotesWidgetRow.rowHeight * (note.imageData.isNotEmpty ? note.photoSize.heightMultiplier : 1)));

  BookColorMap get colormap => BookParagraph.colors[first.color] ?? <String, Color>{};

  bool get expanded => first.uiOptions['expanded'];

  set expanded(bool value) => first.uiOptions['expanded'] = value;

  /// Returns paragraph group's notes slide index
  int get notesIndex => first.uiOptions['notesIndex'] ?? 2;

  /// Manually sets paragraph group's notes slide index
  set notesIndex(int value) => first.uiOptions['notesIndex'] = value >= 0 && value < 4 ? value : 2;

  Widget render({
    bool selected = false,
    bool isFirstGroup = false,
    bool isNextKeyword = false,
    BookParagraph? activeParagraph,
    BookNote? activeNote,
    List<Keyword> selectedWords = const [],
    Function(BookParagraph paragraph)? onParagraphTap,
    Function(BookParagraph paragraph)? onParagraphDoubleTap,
    Function(BookParagraph paragraph)? onParagraphLongPress,
    Function(BookNote)? onNoteLongPress,
    Function(BookNote)? onNoteDoubleTap,
    Function(BookParagraph paragraph, String word, int wordCount)? onWordTap,
    Function(BookParagraph paragraph, String word, int wordCount)? onWordDoubleTap,
    Function(BookParagraph paragraph, String word, int wordCount)? onWordLongPress,
    Function(BookParagraph paragraph)? onToggleExpanded,
    Function()? onToggleCapitalNotes,
    Function()? onClearSelection,
    Function()? onClearSelectionLongPress,
    Function()? onClearParagraphSelection,
    Function(BookParagraph)? onLinkWithPrevious,
    Function(BookParagraph)? onUnlinkWithPrevious,
    Function(BookParagraph paragraph, String color)? onChangeColor,
    Function(BookNote? note, bool? capital, {bool? longpress})? onAddActionTap,
    Function(BookNote? note, bool? capital)? onAddAsKeywords,
    required AddAction addAction,
    required bool addActionLock,
    Function(BookNote?)? onAddAsNote,
    Function(BookNote)? onNoteTap,
    Function(BookNote)? onKeywordsTap,
    Function(BookNote)? onAddQuestion,
    Function(BookNote)? onPhotoTap,
    Function(BookNote, bool)? onPhotoSizeTap,
    Function(BookNote)? onShowAnswer,
    required Function(BookNote note, int, List<BookNote>? notesToChange) onNotesIndexChanged,
    bool hasSelectedWords = false,
    bool keywordsCapital = false,
    bool noteWordsCapital = false,
    BookNote? activatedSentenceOfNote,
    required ShiftingStatus shiftingStatus,
    required LockStatus lockStatus,
    required Function(BookNote note, int page, List<BookNote>? notes) onTransparentIndexChanged,
    List<BookNoteSyncMove>? bookNoteSyncMoveList,
    required List<List<BookNote>> continuousNotes,
    required List<BookParagraph> allParagraphs,
    required Map<String, List<int>> lockedIndexes

}) {
    ///HERE IS THE CHANGE
    ///NOTES WENT ON THE TOP OF PARAGRAPH INSTEAD OF THE TOP OF GROUP;
    // return BookNotesWidget(
    return BookNotesWidgetV2(
      isFirstGroup: isFirstGroup,
      lockedIndexes: lockedIndexes,
      allParagraphs: allParagraphs,
      continuousNotes: continuousNotes,
      lockStatus: lockStatus,
      onTransparentIndexChanged: onTransparentIndexChanged,
      shiftingStatus: shiftingStatus,
      hasSelectedWords: hasSelectedWords,
      keywordsCapital: keywordsCapital,
      noteWordsCapital: noteWordsCapital,
      isNextKeyword: isNextKeyword,
      paragraphs: this,
      activeParagraph: activeParagraph,
      activeNote: activeNote,
      active: activeParagraph != null && paragraphs.contains(activeParagraph),
      selectedWords: selectedWords,
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
      onToggleExpanded: (onToggleExpanded == null) ? null : () => onToggleExpanded(first),
      onToggleCapitalNotes: onToggleCapitalNotes,
      onClearSelection: onClearSelection,
      onClearSelectionLongPress: onClearSelectionLongPress,
      onClearParagraphSelection: onClearParagraphSelection,
      onLinkWithPrevious: activeParagraph != null && paragraphs.indexOf(activeParagraph) == 0 ? onLinkWithPrevious : null,
      onUnlinkWithPrevious: activeParagraph != null && paragraphs.indexOf(activeParagraph) > 0 ? onUnlinkWithPrevious : null,
      onChangeColor: onChangeColor,
      onAddActionTap: onAddActionTap,
      onAddAsKeywords: onAddAsKeywords,
      addAction: addAction,
      addActionLock: addActionLock,
      onAddAsNote: onAddAsNote,
      onAddQuestion: onAddQuestion,
      onPhotoTap: onPhotoTap,
      onPhotoSizeTap: onPhotoSizeTap,
      onShowAnswer: onShowAnswer,
      onNotesIndexChanged: onNotesIndexChanged,
      activatedSentenceOfNote: activatedSentenceOfNote,
        bookNoteSyncMoveList: bookNoteSyncMoveList,
    );
  }
}

extension BookParagraphWidgets on BookParagraph {
  bool get isNullParagraph {
    return notes.isEmpty && color.isEmpty && text.isEmpty;
  }

  double get notesHeight =>
      notes.fold(0, (sum, note) => sum + (BookNotesWidgetRow.rowHeight * (note.imageData.isNotEmpty ? note.photoSize.heightMultiplier : 1)));

  static double notesHeightByNotes(List<BookNote> incomingNotes){
    return incomingNotes.fold(0, (sum, note) => sum + (BookNotesWidgetRow.rowHeight * (note.imageData.isNotEmpty ? note.photoSize.heightMultiplier : 1)));
  }

  Widget render({
    BookRenderMode mode = BookRenderMode.read,
    bool selected = false,
    bool onlyFirstWords = false,
    List<Keyword> selectedWords = const [],
    Function(BookParagraph paragraph)? onParagraphTap,
    Function(BookParagraph paragraph)? onParagraphDoubleTap,
    Function(BookParagraph paragraph)? onParagraphLongPress,
    Function(BookParagraph paragraph, String word, int wordCount)? onWordTap,
    Function(BookParagraph paragraph, String word, int wordCount)? onWordDoubleTap,
    Function(BookParagraph paragraph, String word, int wordCount)? onWordLongPress,
    Function(BookParagraph paragraph)? onToggleExpanded,
  }) {
    if (mode == BookRenderMode.read) {
      return ParagraphSimpleReader(
        paragraph: this,
        selected: selected,
        onParagraphTap: (onParagraphTap == null) ? null : () => onParagraphTap(this),
        onParagraphDoubleTap: (onParagraphDoubleTap == null) ? null : () => onParagraphDoubleTap(this),
        onParagraphLongPress: (onParagraphLongPress == null) ? null : () => onParagraphLongPress(this),
      );
    } else {
      return ParagraphImportReader(
        paragraph: this,
        onlyFirstWords: onlyFirstWords,
        onWordTap: onWordTap,
        onWordLongPress: onWordLongPress,
        onParagraphTap: (onParagraphTap == null) ? null : () => onParagraphTap(this),
        onParagraphDoubleTap: (onParagraphDoubleTap == null) ? null : () => onParagraphDoubleTap(this),
        onParagraphLongPress: (onParagraphLongPress == null) ? null : () => onParagraphLongPress(this),
      );
    }
  }

  List<InlineSpan> asTextSpans({
    required TextStyle style,
    Map<String, int> selectedWords = const {},
    Function(BookParagraph paragraph)? onParagraphTap,
    Function(BookParagraph paragraph)? onParagraphDoubleTap,
    Function(BookParagraph paragraph)? onParagraphLongPress,
    Function(BookParagraph paragraph, String word, int wordCount)? onWordTap,
    Function(BookParagraph paragraph, String word, int wordCount)? onWordDoubleTap,
    Function(BookParagraph paragraph, String word, int wordCount)? onWordLongPress,
  }) {
    List<InlineSpan> spans = [];
    List<String> words = text.asWords();
    double fontSize = app.settings['appFontSize'];

    for (int wordCnt = 0; wordCnt < words.length; wordCnt++) {
      var w = words[wordCnt];

      spans.add(
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              '$w ',
              style: style,
            ),
            onTap: () {
              if (onWordTap != null) onWordTap(this, w, wordCnt);
            },
            onDoubleTap: () {
              if (onWordDoubleTap != null) onWordDoubleTap(this, w, wordCnt);
            },
            onLongPress: () {
              if (onWordLongPress != null) onWordLongPress(this, w, wordCnt);
            },
          ),
        ),
      );
    }

    return spans.toList();
  }

  List<InlineSpan> asWidgetSpans({
    List<Keyword> selectedWords = const [],
    BookNote? activatedSentenceOfNote,
    bool active = false,
    bool isNextKeyword = false,
    bool keywordsCapital = false,
    bool noteWordsCapital = false,
    required BookColorMap colormap,
    Function(BookParagraph paragraph)? onParagraphTap,
    Function(BookParagraph paragraph)? onParagraphDoubleTap,
    Function(BookParagraph paragraph)? onParagraphLongPress,
    Function(BookParagraph paragraph, String word, int wordCount)? onWordTap,
    Function(BookParagraph paragraph, String word, int wordCount)? onWordDoubleTap,
    Function(BookParagraph paragraph, String word, int wordCount)? onWordLongPress,
    required AddAction addAction,
    ShiftingStatus shiftingStatus = ShiftingStatus.none,
    required bool shouldAddBullet,
    required bool isTitle,
  }) {
    List<InlineSpan> spans = [];
    List<String> words = text.asWords();



    if(shouldAddBullet && cropUntilIndex == null && (activatedSentenceOfNote == null || activatedSentenceOfNote.startIndex == 0) && !hasBackground && !this.isTitle && !isJustItalic){
      print(isJustItalic);
      spans.addAll([
        WidgetSpan(
          child: Text(
            '֍ ',
            style: TextStyle(
                height: app.settings['paragraphLineHeight'],
                fontSize: app.settings['appFontSize'],
                letterSpacing: 0.5,
                fontWeight: FontWeight.bold,
                color: colormap[BookParagraph.colorTextPrimary]
            ),
          ),
        )
      ]);
    }


    for (int wordCnt = activatedSentenceOfNote != null ? (activatedSentenceOfNote.startIndex ?? 0) : cropUntilIndex ?? 0; wordCnt < (activatedSentenceOfNote != null ? activatedSentenceOfNote.endIndex ?? 0: words.length); wordCnt++) {

      if(cropUntilIndex != null){
        if(cropUntilIndex == wordCnt) {
          spans.add(        WidgetSpan(
            child: GestureDetector(
              child: Text(
                '...',
                style: TextStyle(
                  height: app.settings['paragraphLineHeight'],
                  letterSpacing: 0.5,

                ),
              ),
            ),
          ));
          continue;
        }
      } else if(activatedSentenceOfNote != null && activatedSentenceOfNote.startIndex != 0 && activatedSentenceOfNote.startIndex == wordCnt) {
        spans.add( WidgetSpan(
          child: GestureDetector(
            child: Text(
              '...',
              style: TextStyle(
                height: app.settings['paragraphLineHeight'],
                letterSpacing: 0.5,

              ),
            ),
          ),
        ));
      }
      var w = words[wordCnt];

      var isKeyword =
          notes.firstWhere((element) => element.keywords.positions.contains(wordCnt), orElse: () => BookNote(paragraphUuid: '', keywords: [], notewords: [], uuid: const Uuid().v4())).keywords.isNotEmpty;
      bool shouldCapital = false;

      if(isKeyword){
        BookNote? note = notes.firstWhereOrNull((element) => element.keywords.positions.contains(wordCnt),);
        Keyword? keyword = note?.keywords.firstWhereOrNull((element) => w.toUpperCase().contains(element.word.toUpperCase()));
        if(keyword != null){
          shouldCapital = keyword.capital && (app.settings['capitalizedEnabled'] ?? capitalizedEnabledDefault);
        }
      }
      var isNoteword = notes
          .firstWhere((element) => element.notewords.positions.contains(wordCnt), orElse: () => BookNote(paragraphUuid: '', keywords: [], notewords: [], uuid: const Uuid().v4()))
          .notewords
          .isNotEmpty;

      if(isNoteword){
        BookNote? note = notes.firstWhereOrNull((element) => element.notewords.positions.contains(wordCnt),);
        Keyword? keyword = note?.notewords.firstWhereOrNull((element) => w.toUpperCase().contains(element.word.toUpperCase()));
        if(keyword != null){
          shouldCapital = keyword.capital && (app.settings['capitalizedEnabled'] ?? capitalizedEnabledDefault);
        }
      }
      var isSelected = (selectedWords.containsKeyword(w, wordCnt));

      if(isSelected) {
        Keyword keyword = selectedWords.getSpecificKeyword(w, wordCnt)!;
        shouldCapital = keyword.capital;
      }

      double fontSize = app.settings['appFontSize'];

      double finalFontSize = fontSize;
      if(isSelected || isKeyword || isNoteword){
        if(isSelected && isNextKeyword){
          finalFontSize = shouldCapital ? fontSize - 1.8 : fontSize;
        }else if(isSelected){
          finalFontSize = shouldCapital ? fontSize - 1.8 : fontSize;
        }else if(isNoteword){
          finalFontSize = shouldCapital ? fontSize - 1 : fontSize;
        }else if(isKeyword){
          finalFontSize = shouldCapital ? fontSize - 1: fontSize + 1;
        }
      }

      if(this.isTitle){
        finalFontSize = finalFontSize * 1.4;
      }

      if(isLarge){
        finalFontSize = finalFontSize * 1.25;
      }

      if(shiftingStatus != ShiftingStatus.none && isSelected){
        finalFontSize = fontSize + 2;
      }else{
      }

      spans.add(
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              shouldCapital ? '${w.toUpperCaseStrict} '  : '$w ',
              style: TextStyle(
                height: app.settings['paragraphLineHeight'],
                letterSpacing: 0.5,
                color: isSelected ? Colors.black : (isKeyword || isNoteword ? colormap[BookParagraph.colorTextSecondary] : Colors.black),
                fontSize: finalFontSize * (this.isTitle ? 1.2 : (isItalic && !hasBackground) ? .8 : 1),
                fontStyle: activatedSentenceOfNote != null || isItalic ? FontStyle.italic : null,
                fontWeight: (isSelected && isNextKeyword) || isKeyword || isBold || this.isTitle ? FontWeight.bold : null,
                decoration: isSelected && !isNextKeyword ? TextDecoration.underline : null,
              ),
            ),
            onTap: () {
              if (onWordTap != null) onWordTap(this, w, wordCnt);
            },
            onDoubleTap: () {
              if (onWordDoubleTap != null) onWordDoubleTap(this, w, wordCnt);
            },
            onLongPress: () {
              if (onWordLongPress != null) onWordLongPress(this, w, wordCnt);
            },
          ),
        ),
      );
    }

    return spans.toList();
  }
}



extension BookParsing on String {

  String get toUpperCaseStrict {
    String toUpperCaseStrictWord =  toUpperCase();
    toUpperCaseStrictWord = toUpperCaseStrictWord.replaceAll(RegExp(r'[Ά]'), 'Α');
      toUpperCaseStrictWord = toUpperCaseStrictWord.replaceAll(RegExp(r'[Έ]'), 'Ε');
      toUpperCaseStrictWord = toUpperCaseStrictWord.replaceAll(RegExp(r'[Ή]'), 'Η');
      toUpperCaseStrictWord = toUpperCaseStrictWord.replaceAll(RegExp(r'[Ί]'), 'Ι');
      toUpperCaseStrictWord = toUpperCaseStrictWord.replaceAll(RegExp(r'[Ό]'), 'Ο');
      toUpperCaseStrictWord = toUpperCaseStrictWord.replaceAll(RegExp(r'[Ύ]'), 'Υ');
      toUpperCaseStrictWord = toUpperCaseStrictWord.replaceAll(RegExp(r'[Ώ]'), 'Ω');
      toUpperCaseStrictWord = toUpperCaseStrictWord.replaceAll(RegExp(r'[ΐ]'), 'Ϊ');
    toUpperCaseStrictWord = toUpperCaseStrictWord.replaceAll(RegExp(r'[ΰ]'), 'Ϋ');

    return toUpperCaseStrictWord;
  }

  bool get containsDot => contains('.');

  bool get containsEndOfSentenceSymbol => contains(RegExp(
      r'[.!;:,?·]'));

  bool get containsExclamationMark => contains('!');

  bool get containsDotOrExclamationMark => containsDot || containsExclamationMark;

  bool get containsEndingSymbol => containsDotOrExclamationMark || contains('?') || contains(';') || contains(']') || contains('·') || contains(')') || contains(':');

  List<String> asLines() => const LineSplitter().convert(this).map((s) => s.trim()).toList();

  List<String> asWords() => split(RegExp(r"\s+"));

  String shorten(int chars) {
    // If value is less than the preferred shorten version, return the whole string
    if (length <= chars) return this;

    var pos = indexOf(RegExp(r'[\s+\.+]'), chars);
    if (pos < 0) pos = length;

    if (pos == chars) substring(0, pos);

    var words = substring(0, pos).split(RegExp(r"\s+"));
    words.removeLast();

    return '${words.join(' ')}...';
  }

}

extension StringHex on String {

  Color toColor() => Color(int.parse(substring(1, 9), radix: 16));
}

extension BookWidgets on Book {
  Widget render({
    BookRenderMode mode = BookRenderMode.notes,
    BookChapter? chapter,
    BookParagraph? paragraph,
    BookNote? note,
    List<Keyword> selectedWords = const [],
    Function(BookParagraph paragraph)? onParagraphTap,
    Function(BookParagraph paragraph)? onParagraphDoubleTap,
    Function(BookParagraph paragraph)? onParagraphLongPress,
    Function(BookNote)? onNoteLongPress,
    Function(BookNote)? onNoteDoubleTap,
    Function(BookNote)? onNoteTap,
    Function(BookNote)? onKeywordsTap,
    Function(BookParagraph paragraph, String word, int wordCount)? onWordTap,
    Function(BookParagraph paragraph, String word, int wordCount)? onWordDoubleTap,
    Function(BookParagraph paragraph, String word, int wordCount)? onWordLongPress,
    Function(BookParagraph paragraph)? onToggleExpanded,
    Function()? onToggleCapitalNotes,
    Function()? onClearSelection,
    Function()? onClearSelectionLongPress,
    Function()? onClearParagraphSelection,
    Function(BookParagraph)? onLinkWithPrevious,
    Function(BookParagraph)? onUnlinkWithPrevious,
    Function(BookParagraph paragraph, String color)? onChangeColor,
    Function(BookNote? note, bool? capital, {bool? longpress})? onAddActionTap,
    Function(BookNote? note, bool? capital)? onAddAsKeywords,
    required AddAction addAction,
    required bool addActionLock,
    Function(BookNote? note)? onAddAsNote,
    Function(BookNote note)? onAddQuestion,
    Function(BookNote note)? onPhotoTap,
    Function(BookNote note, bool)? onPhotoSizeTap,
    Function(BookNote note)? onShowAnswer,
    required Function(BookNote note, int page, List<BookNote>? notesToChange) onNotesIndexChanged,
    bool hasSelectedWords = false,
    bool isNextKeyword = false,
    bool keywordsCapital = false,
    bool noteWordsCapital = false,
    BookNote? activatedSentenceOfNote,
    required ShiftingStatus shiftingStatus,
    required LockStatus lockStatus,
    required Function(BookNote note, int page, List<BookNote>? notes) onTransparentIndexChanged,
    List<BookNoteSyncMove>? bookNoteSyncMoveList,
    required Map<String, List<int>> lockedIndexes,
    bool hasFirstNotes = true,
    ScrollController? scrollController,
  }) {


    return ListView(
      controller: scrollController,
      children: <Widget>[
        if(!hasFirstNotes) const SizedBox(height: 25,),
        ...allChapters
            .where((ch) => mode == BookRenderMode.process ? true : ch.uuid == chapter?.uuid)
            .map(
              (c) => c.render(
                lockedIndexes: lockedIndexes,
                customGroups: c.customGroups(activatedSentenceOfNote),
                bookNoteSyncMoveList: bookNoteSyncMoveList,
                lockStatus: lockStatus,
                onTransparentIndexChanged: onTransparentIndexChanged,
                shiftingStatus: shiftingStatus,
                activatedSentenceOfNote: activatedSentenceOfNote,
                keywordsCapital: keywordsCapital,
                noteWordsCapital: noteWordsCapital,
                isNextKeyword: isNextKeyword,
                hasSelectedWords: hasSelectedWords,
                mode: mode,
                activeParagraph: paragraph,
                activeNote: note,
                selectedWords: selectedWords,
                onWordTap: onWordTap,
                onWordDoubleTap: onWordDoubleTap,
                onWordLongPress: onWordLongPress,
                onParagraphTap: onParagraphTap,
                onParagraphDoubleTap: onParagraphDoubleTap,
                onParagraphLongPress: onParagraphLongPress,
                onNoteLongPress: onNoteLongPress,
                onNoteDoubleTap: onNoteDoubleTap,
                onNoteTap: onNoteTap,
                onKeywordsTap: onKeywordsTap,
                onToggleExpanded: onToggleExpanded,
                onToggleCapitalNotes: onToggleCapitalNotes,
                onClearSelection: onClearSelection,
                onClearSelectionLongPress: onClearSelectionLongPress,
                onClearParagraphSelection: onClearParagraphSelection,
                onLinkWithPrevious: onLinkWithPrevious,
                onUnlinkWithPrevious: onUnlinkWithPrevious,
                onChangeColor: onChangeColor,
                onAddActionTap: onAddActionTap,
                onAddAsKeywords: onAddAsKeywords,
                addAction: addAction,
                addActionLock: addActionLock,
                onAddAsNote: onAddAsNote,
                onAddQuestion: onAddQuestion,
                onPhotoTap: onPhotoTap,
                onPhotoSizeTap: onPhotoSizeTap,
                onShowAnswer: onShowAnswer,
                onNotesIndexChanged: onNotesIndexChanged,
              ),
            )
            .expand((l) => l)
            .toList(),
        SizedBox(height: Get.height * 0.25),
      ],
    );
  }


  List<BookChapter> get allChapters{
    List<BookChapter> allChapters = [];
    for (var chapter in chapters) {
      allChapters.add(chapter);
      for (var subChapter in chapter.subChapters) {
        allChapters.add(subChapter);
        for (var unit in subChapter.units) {
          allChapters.add(unit);
        }
      }
    }
    return allChapters;
  }
}

extension ColorHex on Color {
  String toHex() => '#${value.toRadixString(16).padLeft(8, '0')}';
}

extension DurationExtensions on Duration {
  int get elapsedYears => (isNegative ? DateTime(0).subtract(this) : DateTime(0).add(this)).year;
  int get elapsedMonths => (isNegative ? DateTime(0).subtract(this) : DateTime(0).add(this)).month - 1;
  int get elapsedDays => (isNegative ? DateTime(0).subtract(this) : DateTime(0).add(this)).day - 1;
  int get elapsedHours => (isNegative ? DateTime(0).subtract(this) : DateTime(0).add(this)).hour;
  int get elapsedMinutes => (isNegative ? DateTime(0).subtract(this) : DateTime(0).add(this)).minute;
  int get elapsedSeconds => (isNegative ? DateTime(0).subtract(this) : DateTime(0).add(this)).second;

  compareToLoose(Duration duration) {
    var rank = elapsedYears.compareTo(duration.elapsedYears);
    if (rank != 0) return rank;

    rank = elapsedMonths.compareTo(duration.elapsedMonths);
    if (rank != 0) return rank;

    rank = elapsedDays.compareTo(duration.elapsedDays);
    if (rank != 0) return rank;

    rank = elapsedHours.compareTo(duration.elapsedHours);
    if (rank != 0) return rank;

    if ((inMinutes - duration.inMinutes).abs() < 45) return 0;
    return inMinutes.compareTo(duration.inMinutes);
  }
}

extension BookListExtensions on List<Book> {
  bool containsUuid(String uuid) => any((element) => element.uuid == uuid);
}

extension BookNoteListExtensions on List<BookNote> {
  bool containsUuid(String uuid) => firstWhereOrNull((element) => element.uuid == uuid) != null;

  List<List<BookNote>> get groupedNotes{
    List<List<BookNote>> noteGroups = [];

    int noteIndex =  first.noteIndex!;

    List<BookNote> groupList = [];
    for (BookNote n in this){
      if(n.noteIndex == noteIndex){
        groupList.add(n);
      }else{
        noteGroups.add(groupList);
        groupList = [];
        noteIndex = n.noteIndex!;
        groupList.add(n);
      }
    }
    noteGroups.add(groupList);

    return noteGroups;
  }
}

extension BookLibraryListExtensions on List<BookLibrary> {
  bool containsUuid(String uuid) => any((element) => element.uuid == uuid);
}

extension ListUtils<T> on List<T> {
  T random() => length == 1 ? first : this[Random().nextInt(length)];

  T? firstWhereOrNull(bool Function(T element) test){
    try{
      for (T element in this) {
        if (test(element)) return element;
      }
    }catch(_){
      return null;
    }

    return null;
  }
}

extension IterableExtensions<T> on Iterable<T> {
  bool containsAll(Iterable<T> list) {
    for (T t in list) {
      var found = false;

      for (T s in this) {
        if (s == t) {
          found = true;
          break;
        }
      }

      if (!found) return false;
    }

    return true;
  }
}

extension IntExtensions on int {
  List<T> repeat<T>(T Function(int) f) {
    var list = <T>[];

    for (var num = 0; num < this; num++) {
      list.add(f(num));
    }

    return list;
  }

  ///[isBetween] cases:
  ///number is smaller than start, returns false;
  ///end is bigger than start, returns false;
  ///end is equal with start, returns true only if this == start == end
  ///number is between start and end
  bool isBetween(int start, int end) => this >= start && this <= start;
}

extension MapExtensions<String, int> on Map<String, int> {
  bool isEqual(Map<String, int> b) {
    if (length != b.length) return false;
    var keysAsList = keys.toList();

    for (var num = 0; num < keys.length; num++) {
      if (!b.containsKey(keysAsList[num]) || this[num] != b[num]) return false;
    }

    return true;
  }
}

extension KeywordsListExtensions on List<Keyword> {
  List<String> get words {
    return map((e) => e.word).toList();
  }

  List<int> get positions {
    return map((e) => e.pos).toList();
  }

  bool isEqual(List<Keyword> b) {
    if (length != b.length) return false;

    for (var num = 0; num < length; num++) {
      if (!this[num].isEqual(b[num])) return false;
    }

    return true;
  }

  bool containsKeyword(String word, int pos) {
    for (var num = 0; num < length; num++) {
      var keyword = elementAt(num);
      if ((keyword.normalCase == word || keyword.word == word) && keyword.pos == pos) {
        return true;
      }
    }

    return false;
  }

  Keyword? getSpecificKeyword(String word, int pos){
    for (var num = 0; num < length; num++) {
      var keyword = elementAt(num);
      if ((keyword.normalCase == word || keyword.word == word) && keyword.pos == pos) return keyword;
    }
    return null;
  }

  List<Json> toJson() {
    return map((e) => e.toJson()).toList();
  }
}
