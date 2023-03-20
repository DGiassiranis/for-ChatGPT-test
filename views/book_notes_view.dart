/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
///
import 'dart:async';
import 'dart:ui' as ui;

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/instance_manager.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:notebars/classes/book_note_sync_move.dart';
import 'package:notebars/classes/book_to_setup.dart';
import 'package:notebars/classes/force_chapter_model.dart';
import 'package:notebars/common/note_constant.dart';
import 'package:notebars/common/route_constant.dart';
import 'package:notebars/dialogs/note_edit_sheet.dart';
import 'package:notebars/dialogs/note_photo_selecte_sheet_v2.dart';
import 'package:notebars/dialogs/note_symbol_select_sheet.dart';
import 'package:notebars/dialogs/preview_photo_sheet.dart';
import 'package:notebars/dialogs/preview_svg_sheet.dart';
import 'package:notebars/getx/controller/note_edit_controller.dart';
import 'package:notebars/getx/controller/note_photo_select_controller.dart';
import 'package:notebars/getx/controller/note_symbol_select_controller.dart';
import 'package:notebars/helpers/image_util.dart';
import 'package:notebars/widgets/notes/book_notes_paragraph_bottom_bar.dart';
import 'package:notebars/widgets/notes/book_notes_permanent_bottom_bar.dart';
import 'package:notebars/widgets/notes/book_notes_view_bar.dart';
import 'package:notebars/widgets/notes/book_notes_widget_toolbar.dart';
import 'package:uuid/uuid.dart';

import '../classes/book.dart';
import '../classes/book_chapter.dart';
import '../classes/book_note.dart';
import '../classes/book_paragraph.dart';
import '../classes/keyword.dart';
import '../extensions.dart';
import '../global.dart';
import '../widgets/book/book_reader.dart';

part 'package:notebars/classes/book_notes_view_enum.dart';

class BookNotesView extends StatefulWidget {
  final Book book;
  final bool studyMode;
  final BookChapter? chapter;

  const BookNotesView({
    Key? key,
    required this.book,
    this.studyMode = false,
    this.chapter,
  })  : assert(!studyMode || (studyMode && chapter != null),
            'Expecting passing a specific chapter, when in study mode'),
        super(key: key);

  @override
  BookNotesViewState createState() => BookNotesViewState();
}

class BookNotesViewState extends State<BookNotesView> {
  // region Constants
  static const noteModeNone = 0;
  static const noteModeKeyword = 1;
  static const noteModeNoteword = 2;

  CollapseAction collapseAction = CollapseAction.collapseTillNoNotes;

  ///milliseconds per one period
  static const timerPeriod = 500;
  int tries = 10;
  Rx<bool> hasSelectedWords = false.obs;

  bool thereIsNewNote = false;
  bool onSaving = false;
  Rx<bool> addActionLock = false.obs;
  Rx<bool> keywordsLocked = false.obs;
  Rx<bool> noteWordsLocked = false.obs;
  Rx<bool> binActivated = false.obs;
  Rx<bool> undoDisabled = true.obs;
  Rx<bool> cropActivated = false.obs;
  Rx<bool> isNextKeyword = true.obs;
  Rx<bool> keywordsCapital = true.obs;
  Rx<bool> noteWordsCapital = true.obs;
  Rx<bool> paragraphsExpanded = true.obs;
  Rx<GearRotationMode> gearRotationMode = GearRotationMode.none.obs;
  Rx<LockStatus> lockStatus = LockStatus.unlocked.obs;
  Rx<ShiftingStatus> shiftingStatus = ShiftingStatus.none.obs;
  Timer? keyShiftingStatusTimer;
  Timer? noteShiftingStatusTimer;
  Timer? gearRotationTimer;

  BookNote? lastNoteAdded;
  BookNote? lastDeletedNote;
  List<BookNote>? lastDeletedNotes;
  List<Keyword> lastDeletedKeywords = [];
  String lastDeletedNoteTitle = '';
  String lastDeletedImage = '';
  int? lastDeletedNoteIndex;
  int? lastDeletedNoteParagraphIndex;
  Rx<LastAction> lastAction = LastAction.noAction.obs;
  List<Keyword> lastSelectedWords = [];

  List<BookNoteSyncMove> bookNoteSyncMoveList = [];

  Map<String, List<int>> lockedIndexes = {};

  // endregion

  // region Properties
  late BookChapter chapter;
  Rx<BookParagraph> paragraph = BookParagraph().obs;
  BookNote? note;
  Rx<BookNote> activatedNote = BookNote(
          paragraphUuid: '',
          keywords: [],
          notewords: [],
          uuid: const Uuid().v4())
      .obs;
  List<Keyword> selectedWords = [];

  /// If true, book has been changed since last save
  bool bookChanged = false;

  /// Stores the mode of the last note selection
  int lastNoteSelectionMode = noteModeNone;

  Rx<AddAction> addAction = AddAction.keyword.obs;

  // Chapter's study eligibility upon opening
  late StudyEligibilityState lastStudyEligibilityState;

  final ScrollController _scrollController = ScrollController();

  // endregion

  // region Getters/setters
  int get chapterIndex =>
      widget.book.allChapters.indexOf(widget.book.allChapters
              .firstWhereOrNull((element) => element.uuid == chapter.uuid) ??
          widget.book.allChapters.first);

  double get stickyOpacity => app.settings['noteStickyOpacity'];

  bool get notesCapital => app.settings['notesCapital'];

  // endregion

  @override
  void initState() {
    super.initState();

    chapter = widget.book.findChapterById(
        widget.chapter?.uuid ?? '', widget.chapter?.depth ?? 0,
        parentChapterUuid: widget.chapter?.parentChapterUuid,
        parentSubChapterUuid: widget.chapter?.parentSubchapterUuid);
    initiateExpanded();
    lastStudyEligibilityState = chapter.studyEligibilityState;

    // Auto-save once per 15 seconds
    // autoSaveTimer = Timer.periodic(const Duration(seconds: 15), (Timer t) {
    //   if (bookChanged) save(intermediate: true);
    // });
  }

  initiateExpanded() {
    paragraphsExpanded.value = false;
    for (var element in chapter.paragraphs) {
      if (element.uiOptions["expanded"]) {
        paragraphsExpanded.value = true;
        return;
      }
    }
  }

  @override
  void dispose() {
    // Apply any changes back to app's in-memory book instance
    app.books
        .firstWhere((l) => l.uuid == widget.book.uuid)
        .applyCfg(widget.book.toJson());

    app.saveBook(widget.book);
    // Store any changes made within this view to app's general settings
    app.saveAppSettings();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
        title: Text('${chapter.orderOfChapter(widget.book)} ${chapter.name}'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Bootstrap.sliders),
            tooltip: 'Settings',
            onPressed: () => Navigator.pushNamed(context, '/settings').then((value) {
              setState(() {
              });
            }),
          ),
        ],
      ),
      floatingActionButton: selectedWords.isEmpty &&
                  paragraph.value.isNullParagraph ||
              !activatedNote.value.isNullNote()
          ? FloatingActionButton(
              onPressed: markAsRead,
              backgroundColor: Colors.deepPurpleAccent,
              child: const Icon(Icons.playlist_add_check),
            )
          : FloatingActionButton(
              onPressed:
                  lastAction.value != LastAction.noAction ? onUndoTap : null,
              backgroundColor: BookParagraph.colors[paragraph.value.color]
                  ?[BookParagraph.colorBackKeywords],
              child: ObxValue(
                  (Rx<LastAction> lastAction) => GestureDetector(
                        onLongPress: () {
                          closeShiftingMode();
                        },
                        child: Icon(CupertinoIcons.arrow_counterclockwise,
                            color: lastAction.value == LastAction.noAction
                                ? Colors.grey
                                : BookParagraph.colors[paragraph.value.color]
                                    ?[BookParagraph.colorTextPrimary]),
                      ),
                  lastAction),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: !paragraph.value.isNullParagraph &&
              activatedNote.value.isNullNote()
          ? BottomAppBar(
              color: BookParagraph.colors[paragraph.value.color]
                  ?[BookParagraph.colorBackKeywords],
              shape: const CircularNotchedRectangle(),
              child: Obx(
                () => BookNotesPermanentBottomBar(
                  finishShiftingMode: closeShiftingMode,
                  onCropLongPress: () {
                    closeShiftingMode();
                    onCropLongPress(paragraph.value);
                  },
                  onCropTap: () {
                    closeShiftingMode();
                    cropActivated.value = !cropActivated.value;
                  },
                  shiftingStatus: shiftingStatus.value,
                  onBinPress: onBinPress,
                  onBinLongPress: onBinLongPress,
                  binActivated: binActivated.value,
                  cropActivated: cropActivated.value,
                  keywordsLocked: keywordsLocked.value,
                  noteWordsLocked: noteWordsLocked.value,
                  keywordsCapital: keywordsCapital.value,
                  noteWordsCapital: noteWordsCapital.value,
                  capital: notesCapital,
                  onLinkWithPrevious: onLinkWithPrevious,
                  onUnlinkWithPrevious: onUnlinkWithPrevious,
                  linkedWithPrevious:
                      chapter.paragraphs.indexOf(paragraph.value) > 0 &&
                          chapter
                                  .paragraphs[chapter.paragraphs
                                          .indexOf(paragraph.value) -
                                      1]
                                  .color ==
                              paragraph.value.color,
                  paragraph: paragraph.value,
                  onToggleCapitalNotes: onToggleCapitalNotes,
                  colorMap: BookParagraph.colors[paragraph.value.color] ??
                      BookParagraph.colors[BookParagraph.colorNameGrey]!,
                  onKeyButtonLongPress: onKeyButtonLongPress,
                  onNoteButtonLongPress: onNoteButtonLongPress,
                  onClearSelection: onClearSelection,
                  onClearSelectionLongPress: onClearSelectionLongPressV2,
                  onAddAsKeywords: onAddAsKeywords,
                  onAddAsNote: onAddAsNote,
                  onChangeColor: onChangeColorNoParagraph,
                  onKeyIconTap: () {
                    if (isNextKeyword.value &&
                        (keyShiftingStatusTimer?.isActive ?? false)) {
                      closeShiftingMode();
                      return;
                    }
                    if (shiftingStatus.value != ShiftingStatus.none &&
                        shiftingStatus.value != ShiftingStatus.noteCapital &&
                        shiftingStatus.value == ShiftingStatus.noteLower) {
                      closeShiftingMode();
                      return;
                    }

                    closeShiftingMode();

                    keywordsCapital.value = !keywordsCapital.value;
                    if (isNextKeyword.value) {
                      for (var keyword in selectedWords) {
                        keyword.capital = keywordsCapital.value;
                      }
                    }
                  },
                  onNoteIconTap: () {
                    if (!isNextKeyword.value &&
                        (noteShiftingStatusTimer?.isActive ?? false)) {
                      closeShiftingMode();
                      return;
                    }
                    if (shiftingStatus.value != ShiftingStatus.none &&
                        (shiftingStatus.value == ShiftingStatus.noteCapital ||
                            shiftingStatus.value ==
                                ShiftingStatus.noteCapital)) {
                      closeShiftingMode();
                      return;
                    }

                    closeShiftingMode();

                    noteWordsCapital.value = !noteWordsCapital.value;
                    if (!isNextKeyword.value) {
                      for (var keyword in selectedWords) {
                        keyword.capital = noteWordsCapital.value;
                      }
                    }
                  },
                ),
              ),
            )
          : BottomAppBar(
              color: Colors.deepPurpleAccent,
              shape: const CircularNotchedRectangle(),
              child: Obx(
                () => BookNotesViewBar(
                  collapseAction: collapseAction,
                  gearRotationMode: gearRotationMode.value,
                  onLockTap: onLockTap,
                  onLockLongPress: () {},
                  lockStatus: lockStatus.value,
                  collapseAllTillNoteFinished: collapseAllTillNoteFinished,
                  expanded: paragraphsExpanded.value,
                  expandAll: expandAll,
                  collapseAll: collapseAll,
                  nextChapter: chapter.uuid != widget.book.allChapters.last.uuid
                      ? goToNextChapter
                      : null,
                  previousChapter:
                      chapter.uuid != widget.book.allChapters.first.uuid
                          ? goToPreviousChapter
                          : null,
                  onGearTap: onGearTap,
                  onGearLongPress: onGearLongPress,
                ),
              ),
            ),
      body: Obx(() {
        return BookReader(
          scrollController: _scrollController,
          hasFirstNotes: chapter.paragraphs.first.notes.isNotEmpty,
          lockedIndexes: lockedIndexes,
          shiftingStatus: shiftingStatus.value,
          keywordsCapital: keywordsCapital.value,
          noteWordsCapital: noteWordsCapital.value,
          hasSelectedWords: hasSelectedWords.value,
          isNextKeyword: (keywordsLocked.value || isNextKeyword.value) &&
              !noteWordsLocked.value,
          book: widget.book,
          chapter: chapter,
          activeParagraph: paragraph.value,
          activeNote: note,
          mode: BookRenderMode.notes,
          selectedWords: selectedWords,
          onParagraphTap: onParagraphTap,
          onParagraphDoubleTap: onParagraphDoubleTap,
          onParagraphLongPress: onParagraphLongPress,
          onWordTap: onWordTap,
          onWordDoubleTap: onWordDoubleTap,
          onWordLongPress: onWordLongPress,
          onToggleExpanded: onToggleExpanded,
          onToggleCapitalNotes: onToggleCapitalNotes,
          onClearSelection: onClearSelection,
          onClearSelectionLongPress: onClearSelectionLongPressV2,
          onClearParagraphSelection: onClearParagraphSelection,
          onLinkWithPrevious: onLinkWithPrevious,
          onUnlinkWithPrevious: onUnlinkWithPrevious,
          onChangeColor: onChangeColor,
          onNoteLongPress: onNoteLongPress,
          onNoteDoubleTap: onNoteDoubleTapV2,
          onNoteTap: onNoteTap,
          onKeywordsTap: onKeywordsTap,
          onAddActionTap: onAddActionTap,
          onAddAsKeywords: onAddAsKeywords,
          addAction: keywordsLocked.value
              ? AddAction.keyword
              : noteWordsLocked.value
                  ? AddAction.note
                  : addAction.value,
          addActionLock: addActionLock.value,
          onAddAsNote: onAddAsNote,
          onAddQuestion: onEditNoteSheet,
          onPhotoTap: onPhotoTap,
          onPhotoSizeTap: onPhotoSizeTap,
          onShowAnswer: onShowAnswer,
          onNotesIndexChanged: onNotesIndexChanged,
          bookNoteSyncMoveList: bookNoteSyncMoveList,
          activatedSentenceOfNote:
              activatedNote.value.isNullNote() ? null : activatedNote.value,
          lockStatus: lockStatus.value,
          onTransparentIndexChanged: onTransparentIndexChanged,
        );
      }),
    );
  }

  // region Action methods

  ///UndoAction
  void onUndoTap() async {
    closeShiftingMode();

    switch (lastAction.value) {
      case LastAction.deleteImageFromNote:
        if (lastDeletedNoteIndex != null &&
            lastDeletedNoteParagraphIndex != null) {
          chapter.paragraphs[lastDeletedNoteParagraphIndex!]
              .notes[lastDeletedNoteIndex!].imageData = lastDeletedImage;
        }
        break;
      case LastAction.deleteKeywordsFromNote:
        if (lastDeletedNoteIndex != null &&
            lastDeletedNoteParagraphIndex != null) {
          chapter.paragraphs[lastDeletedNoteParagraphIndex!]
              .notes[lastDeletedNoteIndex!].keywords
              .addAll(lastDeletedKeywords);
        }
        break;
      case LastAction.deleteNote:
        if (lastDeletedNote != null &&
            lastDeletedNoteIndex != null &&
            lastDeletedNoteParagraphIndex != null) {
          chapter.paragraphs[lastDeletedNoteParagraphIndex!].notes
              .insert(lastDeletedNoteIndex!, lastDeletedNote!);
        }

        if (!(lastDeletedNoteIndex ==
            chapter.paragraphs[lastDeletedNoteParagraphIndex!].notes.length -
                1)) {
          await fixNotesIndex();
        }

        break;
      case LastAction.deleteNoteWordsFromNote:
        if (lastDeletedNoteIndex != null &&
            lastDeletedNoteParagraphIndex != null) {
          chapter.paragraphs[lastDeletedNoteParagraphIndex!]
              .notes[lastDeletedNoteIndex!].notewords
              .addAll(lastDeletedKeywords);
          chapter.paragraphs[lastDeletedNoteParagraphIndex!]
              .notes[lastDeletedNoteIndex!].note = lastDeletedNoteTitle;
        }
        break;
      case LastAction.addKeyword:
        if (lastNoteAdded != null) {
          int noteIndex = paragraph.value.notes.indexOf(lastNoteAdded!);
          selectedWords.addAll(
              paragraph.value.notes[noteIndex].keywords.map((e) => Keyword(
                    e.word,
                    e.pos,
                    e.normalCase,
                    capital: e.capital,
                  )));
          paragraph.value.notes[noteIndex].keywords.clear();
          calculateNextAction();
        }
        break;
      case LastAction.addNoteWord:
        if (lastNoteAdded != null) {
          int noteIndex = paragraph.value.notes.indexOf(lastNoteAdded!);
          selectedWords.addAll(paragraph.value.notes[noteIndex].notewords.map(
              (e) => Keyword(e.word, e.pos, e.normalCase, capital: e.capital)));
          paragraph.value.notes[noteIndex].notewords.clear();

          paragraph.value.notes[noteIndex].note = '';
          calculateNextAction();
        }
        break;
      case LastAction.wordSelected:
        selectedWords.removeLast();
        break;
      case LastAction.noAction:

        ///Do nothing
        break;
      case LastAction.addKeywordCreateNote:
        if (lastNoteAdded != null) {
          int noteIndex = paragraph.value.notes.indexOf(lastNoteAdded!);
          selectedWords.addAll(
              paragraph.value.notes[noteIndex].keywords.map((e) => Keyword(
                    e.word,
                    e.pos,
                    e.normalCase,
                    capital: e.capital,
                  )));

          scrollDown(lastNoteAdded?.noteHeight ?? 0);
          paragraph.value.notes.removeAt(noteIndex);
          calculateNextAction();

          if (!(noteIndex == paragraph.value.notes.length)) {
            await fixNotesIndex();
          }
        }

        break;
      case LastAction.addNoteWordCreateNote:
        if (lastNoteAdded != null) {
          int noteIndex = paragraph.value.notes.indexOf(lastNoteAdded!);
          selectedWords.addAll(
              paragraph.value.notes[noteIndex].notewords.map((e) => Keyword(
                    e.word,
                    e.pos,
                    e.normalCase,
                    capital: e.capital,
                  )));
          scrollDown(lastNoteAdded?.noteHeight ?? 0);
          paragraph.value.notes.removeAt(noteIndex);
          calculateNextAction();

          if (!(noteIndex == paragraph.value.notes.length)) {
            await fixNotesIndex();
          }
        }
        break;
      case LastAction.manyWordsSelected:
        if (lastSelectedWords.isNotEmpty) {
          for (Keyword selectedWord in lastSelectedWords) {
            if (lastSelectedWords.indexOf(selectedWord) == 0) continue;
            selectedWords
                .removeWhere((element) => element.word == selectedWord.word);
          }
          lastSelectedWords.clear();
        }
        break;
      case LastAction.multipleDeletionOfNotes:
        paragraph.value.notes = List.from(lastDeletedNotes ?? []);
        lastDeletedNotes?.clear;
        lastAction.value = LastAction.noAction;
        calculateNextAction();
        break;
    }

    setState(() {});

    hasSelectedWords.value = selectedWords.isNotEmpty;
    lastNoteAdded = null;
    lastAction.value = LastAction.noAction;
    // updateAddActionValueV2();
  }

  void calculateNextAction() {
    if (paragraph.value.notes.length == 1) {
      if (paragraph.value.notes.first.isNullNoteV2) {
        paragraph.value.notes.clear();
      }
    }

    List<BookNote> notes = List.from(paragraph.value.notes);
    notes.removeWhere((n) => n.isNullNoteV2);
    if (notes.isNotEmpty) {
      isNextKeyword.value =
          notes.last.notewords.isNotEmpty || notes.last.imageData.isNotEmpty;
      if (notes.last.noteIndex != NoteConstant.keyAndNoteIndex) {
        isNextKeyword.value = notes.last.noteIndex == NoteConstant.justKeyIndex;
      }
      if (notes.last.noteIndex == NoteConstant.justNoteIndex) {
        isNextKeyword.value = false;
      }
    } else {
      isNextKeyword.value = true;
    }
  }

  void fixParagraphContainsOnlyNullValuesOrNullValuesInTheEnd() {
    bool hasNotNullFlag = false;
    if (paragraph.value.notes.isNotEmpty) {
      while (paragraph.value.notes.isNotEmpty &&
          paragraph.value.notes.last.isNullNoteV2) {
        paragraph.value.notes.removeLast();
      }
    }
    for (var note in paragraph.value.notes) {
      if (!note.isNullNoteV2) {
        hasNotNullFlag = true;
      }
    }
    if (!hasNotNullFlag) {
      paragraph.value.notes.clear();
    }
  }

  ///[BookNotesParagraphBottomBar] actions
  void onKeyButtonLongPress() {
    // keywordsLocked.value = !keywordsLocked.value;
    // if (keywordsLocked.value && noteWordsLocked.value) {
    //   noteWordsLocked.value = false;
    // }
    if (shiftingStatus.value != ShiftingStatus.none) {
      noteShiftingStatusTimer?.cancel();
      keyShiftingStatusTimer?.cancel();
      shiftingStatus.value = ShiftingStatus.none;
      return;
    }

    if (selectedWords.isEmpty) {
      return;
    }

    if (!isNextKeyword.value) {
      isNextKeyword.value = true;
      for (var element in selectedWords) {
        element.capital = keywordsCapital.value;
      }
    }
    noteShiftingStatusTimer?.cancel();
    shiftingStatus.value = ShiftingStatus.keyCapital;
    if (!(keyShiftingStatusTimer?.isActive ?? false)) {
      keyShiftingStatusTimer =
          Timer.periodic(const Duration(milliseconds: timerPeriod), (timer) {
        shiftingStatus.value = shiftingStatus.value == ShiftingStatus.keyCapital
            ? ShiftingStatus.keyLower
            : ShiftingStatus.keyCapital;
      });
    }
  }

  void onNoteButtonLongPress() {
    if (shiftingStatus.value != ShiftingStatus.none) {
      noteShiftingStatusTimer?.cancel();
      keyShiftingStatusTimer?.cancel();
      shiftingStatus.value = ShiftingStatus.none;
      return;
    }

    if (selectedWords.isEmpty) {
      return;
    }

    keyShiftingStatusTimer?.cancel();
    if (isNextKeyword.value) {
      isNextKeyword.value = false;
      for (var element in selectedWords) {
        element.capital = noteWordsCapital.value;
      }
    }

    shiftingStatus.value = ShiftingStatus.noteCapital;
    noteShiftingStatusTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
      shiftingStatus.value = shiftingStatus.value == ShiftingStatus.noteCapital
          ? ShiftingStatus.noteLower
          : ShiftingStatus.noteCapital;
    });
  }

  void onBinPress() {
    closeShiftingMode();
    binActivated.value = !binActivated.value;
  }

  void onBinLongPress() {
    closeShiftingMode();

    isNextKeyword.value = true;

    lastAction.value = LastAction.multipleDeletionOfNotes;

    lastDeletedNotes = List.from(paragraph.value.notes);

    paragraph.value.notes.clear();

    setState(() {});
  }

  /// Navigate to a specific chapter
  void goToChapter(int index) {
    if (index >= 0 && index < widget.book.allChapters.length) {
      chapter = widget.book.allChapters[index];
    }

    scrollToTop();
  }

  /// Navigate to the next chapter
  void goToNextChapter() async {
    Navigator.of(context).pop(ForceChapterModel(
        book: widget.book, forceChapterType: ForceChapterType.forceNext));
  }

  /// Navigate to the previous chapter
  void goToPreviousChapter() async {
    Navigator.of(context).pop(ForceChapterModel(
        book: widget.book, forceChapterType: ForceChapterType.forcePrevious));
  }

  ///Start or stops the rotation of the gear, if rotation is alive, the user can change the status of a key bar;
  void onGearTap() async {
    toggleGearRotationMode();
  }

  ///Changes the value of the rotation mode, if its value is none, it starts the time, at any other scenario, stops the timer;
  void toggleGearRotationMode() {
    if (gearRotationMode.value == GearRotationMode.none) {
      gearRotationMode.value = GearRotationMode.rotated;
      startGearRotationTimer();
    } else {
      stopGearRotationTimer();
    }
  }

  ///initiates and starts the gear rotation timer;
  void startGearRotationTimer() {
    gearRotationTimer =
        Timer.periodic(const Duration(milliseconds: timerPeriod), (timer) {
      gearRotationMode.value =
          gearRotationMode.value == GearRotationMode.rotated
              ? GearRotationMode.initialPosition
              : GearRotationMode.rotated;
    });
  }

  ///stops the gear rotation timer; Re-Initiates the gear rotation mode;
  void stopGearRotationTimer() {
    gearRotationTimer?.cancel();
    gearRotationMode.value = GearRotationMode.none;
  }

  ///Triggered when the gear button pressed for a few seconds
  ///Navigates the user to edit screen
  void onGearLongPress() async {
    await save();

    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      RouteConstant.bookChapters,
      ModalRoute.withName(RouteConstant.libraries),
      arguments: BookToSetUp(
          book: app.books.firstWhere((b) => b.uuid == widget.book.uuid),
          chapterUuid: widget.chapter?.uuid),
    );
  }

  /// Selects/unselects the given word in current paragraph
  void toggleWord(String word, int cnt,
      [bool isTap = true, bool? forceSelected]) {
    if (selectedWords.containsKeyword(word, cnt)) {
      // If it's not a single tap (e.g. if selecting a phrase),
      // remove the selection like usual and return

      /// Current paragraph's last book note
      BookNote? lastNote =
          !paragraph.value.isNullParagraph && paragraph.value.notes.isNotEmpty
              ? paragraph.value.notes.last
              : null;

      if (keywordsLocked.value) {
        addAsKeywords(null, capital: notesCapital, clearSelection: true);
        lastNoteSelectionMode = noteModeNoteword;
        return;
      }
      if (noteWordsLocked.value) {
        if ((lastNote?.notewords ?? []).isNotEmpty ||
            (lastNote?.imageData != null &&
                (lastNote?.imageData ?? '').isNotEmpty)) {
          addAsNotes(null, clearSelection: true, capital: notesCapital);
          lastNoteSelectionMode = noteModeNoteword;
          return;
        }
        addAsNotes(lastNote, clearSelection: true, capital: notesCapital);
        lastNoteSelectionMode = noteModeNoteword;
        return;
      }

      if (isNextKeyword.value) {
        List<BookNote> notes = List.from(paragraph.value.notes);
        notes.removeWhere((n) => n.isNullNoteV2);
        addAsKeywords(null,
            capital: notesCapital,
            clearSelection: true,
            noteIndex: (notes.isEmpty ? null : notes.last.noteIndex) ??
                NoteConstant.keyAndNoteIndex);
        lastNoteSelectionMode = noteModeNoteword;
      } else {
        if ((lastNote?.notewords ?? []).isNotEmpty ||
            (lastNote?.imageData != null &&
                (lastNote?.imageData ?? '').isNotEmpty)) {
          List<BookNote> notes = List.from(paragraph.value.notes);
          notes.removeWhere((n) => n.isNullNoteV2);

          addAsNotes(null,
              clearSelection: true,
              capital: notesCapital,
              noteIndex: (notes.isEmpty ? null : notes.last.noteIndex) ??
                  NoteConstant.keyAndNoteIndex);
          lastNoteSelectionMode = noteModeNoteword;
        }
        addAsNotes(lastNote, clearSelection: true, capital: notesCapital);
        lastNoteSelectionMode = noteModeNoteword;
      }
      if (paragraph.value.notes.isNotEmpty) {
        if (paragraph.value.notes.last.noteIndex ==
            NoteConstant.justNoteIndex) {
          isNextKeyword.value = false;
        } else if (paragraph.value.notes.last.noteIndex ==
            NoteConstant.justKeyIndex) {
          isNextKeyword.value = true;
        }
      }

      return;
    } else {
      if (lastNoteSelectionMode != noteModeNone) {
        hasSelectedWords.value = false;
        hasSelectedWords.value = false;
      }

      lastNoteSelectionMode = noteModeNone;
      hasSelectedWords.value = true;
      selectedWords.add(Keyword(word, cnt, word,
          capital: isNextKeyword.value
              ? keywordsCapital.value
              : noteWordsCapital.value));
      lastAction.value = LastAction.wordSelected;
      setState(() {
        // Start new notes selection, if note state is set
      });
    }
  }

  /// Selects the given phrase in current paragraph
  void selectPhrase(int from, int to) {
    var words = paragraph.value.text.asWords();

    // region Ensure we're on the limits and in correct order
    if (from > words.length - 1) from = words.length - 1;
    if (to > words.length - 1) to = words.length - 1;
    if (from > to) {
      var tmp = to;
      to = from;
      from = tmp;
    }
    // endregion

    for (var cnt = from + 1; cnt <= to; cnt++) {
      toggleWord(words[cnt], cnt, false, true);
      lastSelectedWords.add(Keyword(words[cnt], cnt, words[cnt],
          capital: isNextKeyword.value
              ? keywordsCapital.value
              : noteWordsCapital.value));
    }
    lastAction.value = LastAction.manyWordsSelected;
  }

  /// Clears the selected words
  void clearWordSelection() {
    setState(() {
      selectedWords.clear();
      hasSelectedWords.value = false;
    });
  }

  /// Deselects any currently selected paragraph
  void clearParagraphSelection() {
    if (!paragraph.value.isNullParagraph) {
      BookParagraphGroup? group = chapter.groups
          .firstWhereOrNull((element) => element.contains(paragraph.value));
      if (group != null) {
        if (group.notes.isEmpty) {
          group.expanded = true;
          setState(() {});
        }
      }
    }

    setState(() {
      paragraph.value = BookParagraph();
      selectedWords.clear();
      hasSelectedWords.value = false;
    });
  }

  /// Adds the selected words as keywords
  void addAsKeywords(
    BookNote? note, {
    bool? capital = true,
    bool clearSelection = true,
    bool isNew = false,
    int noteIndex = NoteConstant.keyAndNoteIndex,
    bool fromTappingOnNote = false,
  }) {
    shiftingStatus.value = ShiftingStatus.none;
    keyShiftingStatusTimer?.cancel();
    noteShiftingStatusTimer?.cancel();

    capital = keywordsCapital.value;
    if (selectedWords.isEmpty || paragraph.value.isNullParagraph) return;

    thereIsNewNote = true;

    if (note == null) {
      note = BookNote(
        paragraphUuid: paragraph.value.uuid,
        keywords: selectedWords
            .map((k) => Keyword(
                  k.word,
                  k.pos,
                  k.normalCase,
                  capital: k.capital,
                ))
            .toList(),
        notewords: [],
        uuid: const Uuid().v4(),
      );
      note.noteIndex = noteIndex;

      note.calculateStartAndEndIndex(paragraph.value);
      scrollUp();
      paragraph.value.notes.add(note);

      if (lockStatus.value == LockStatus.locked) decideLockNextAction();

      lastAction.value = LastAction.addKeywordCreateNote;
      lastNoteAdded = note;
    } else {
      note.name = '';
      note.keywords = selectedWords
          .map((k) => Keyword(
                capital ?? true ? k.word.toUpperCase() : k.word,
                k.pos,
                k.normalCase,
                capital: k.capital,
              ))
          .toList();
      lastAction.value =
          isNew ? LastAction.addKeywordCreateNote : LastAction.addKeyword;
      lastNoteAdded = note;
      note.calculateStartAndEndIndex(paragraph.value);
    }

    // Generate note's name, if empty
    if (note.name.isEmpty) {
      note.name = getNoteName(fromTappingOnNote, capital);
    }

    if (!keywordsLocked.value && !noteWordsLocked.value) {
      isNextKeyword.value = false;
    }

    if (clearSelection) clearWordSelection();

    setState(() => bookChanged = true);
  }

  String getNoteName(bool isFromTappingOnNote, bool capital) {
    if (isFromTappingOnNote && isNextKeyword.value) {
      return selectedWords
          .map((e) => capital
              ? cleanKeywordTextFromSymbols(e.word.toUpperCase(),
                  strict: true, uppercase: true)
              : e.word)
          .join(' ');
    }
    return isFromTappingOnNote
        ? selectedWords
            .map((e) => capital
                ? cleanKeywordTextFromSymbols(e.word.toUpperCase(),
                    strict: true, uppercase: true)
                : e.word)
            .join(' ')
        : selectedWords
            .map((k) => k.capital
                ? cleanKeywordTextFromSymbols(k.word.toUpperCase(),
                    strict: true, uppercase: true)
                : k.word)
            .join(' ');
  }

  /// Cleans a keyword from special characters and removes tones from Greek capital letters
  String cleanKeywordTextFromSymbols(String key,
      {bool uppercase = false, bool strict = true}) {
    // Clear from special characters
    key = key.replaceAll(
        strict ? RegExp(r'[`()\[\]!",.?|]') : RegExp(r'[`,.]'), '');
    key = key.replaceAll(RegExp(r'[\s]+'), ' ').trim();

    if (uppercase) {
      key = key.toUpperCase();
      key = key.replaceAll(RegExp(r'[Ά]'), 'Α');
      key = key.replaceAll(RegExp(r'[Έ]'), 'Ε');
      key = key.replaceAll(RegExp(r'[Ή]'), 'Η');
      key = key.replaceAll(RegExp(r'[Ί]'), 'Ι');
      key = key.replaceAll(RegExp(r'[Ό]'), 'Ο');
      key = key.replaceAll(RegExp(r'[Ύ]'), 'Υ');
      key = key.replaceAll(RegExp(r'[Ώ]'), 'Ω');
      key = key.replaceAll(RegExp(r'[ΐ]'), 'Ϊ');
      key = key.replaceAll(RegExp(r'[ΰ]'), 'Ϋ');
    }

    return key;
  }

  /// Adds the selected words as notewords
  void addAsNotes(
    BookNote? note, {
    bool capital = true,
    bool clearSelection = true,
    bool isNew = false,
    int noteIndex = NoteConstant.keyAndNoteIndex,
    bool fromTappingOnNoteBar = false,
  }) {
    shiftingStatus.value = ShiftingStatus.none;
    keyShiftingStatusTimer?.cancel();
    noteShiftingStatusTimer?.cancel();

    capital = noteWordsCapital.value;
    if (selectedWords.isEmpty || paragraph.value.isNullParagraph) return;

    thereIsNewNote = true;

    if (note == null) {
      note = BookNote(
        paragraphUuid: paragraph.value.uuid,
        keywords: [],
        notewords: selectedWords
            .map(
                (k) => Keyword(k.word, k.pos, k.normalCase, capital: k.capital))
            .toList(),
        uuid: const Uuid().v4(),
      );
      note.calculateStartAndEndIndex(paragraph.value);
      note.noteIndex = noteIndex;
      scrollUp();
      paragraph.value.notes.add(note);
      if (lockStatus.value == LockStatus.locked) decideLockNextAction();
      lastAction.value = LastAction.addNoteWordCreateNote;
      lastNoteAdded = note;
    } else if (fromTappingOnNoteBar) {
      note.notewords = selectedWords
          .map((k) => Keyword(
                k.word,
                k.pos,
                k.word,
                capital: capital,
              ))
          .toList();
      lastNoteAdded = note;
      note.calculateStartAndEndIndex(paragraph.value);
      lastAction.value =
          isNew ? LastAction.addNoteWordCreateNote : LastAction.addNoteWord;
    } else {
      note.notewords = selectedWords
          .map((k) => Keyword(
                k.word,
                k.pos,
                k.word,
                capital: k.capital,
              ))
          .toList();
      lastNoteAdded = note;
      note.calculateStartAndEndIndex(paragraph.value);
      lastAction.value =
          isNew ? LastAction.addNoteWordCreateNote : LastAction.addNoteWord;
    }

    // Generate note's name, if empty
    if (note.note.isEmpty) {
      note.note = getNoteText(fromTappingOnNoteBar, capital);
    }

    if (!keywordsLocked.value && !noteWordsLocked.value) {
      isNextKeyword.value = true;
    }

    if (clearSelection) clearWordSelection();

    setState(() => bookChanged = true);
  }

  String getNoteText(bool isFromTappingOnNoteBar, bool capital) {
    return isFromTappingOnNoteBar
        ? selectedWords
            .map((k) => k.capital
                ? cleanKeywordTextFromSymbols(k.word.toUpperCase(),
                    strict: false, uppercase: true)
                : k.word)
            .join(' ')
        : selectedWords
            .map((k) => k.capital
                ? cleanKeywordTextFromSymbols(k.word.toUpperCase(),
                    strict: false, uppercase: true)
                : k.word)
            .join(' ');
  }

  ///This method is used to fix the paragraph's notes index problem caused by a change in notes list;
  Future<void> fixNotesIndex() async {
    final BookParagraph currentParagraph = paragraph.value;

    paragraph.value = BookParagraph();
    setState(() {});

    List<Keyword> currentSelectedWords = List.from(selectedWords);
    await Future.delayed(const Duration(milliseconds: 100));

    selectParagraph(currentParagraph);
    selectedWords = List.from(currentSelectedWords);
    setState(() {});
  }

  /// Expands/collapses the given paragraph group (clearing any selections if group is active)
  void toggleExpanded(BookParagraphGroup group) {
    setState(() => group.expanded = !group.expanded);

    if (!group.expanded && group.paragraphs.contains(paragraph.value)) {
      setState(() {
        // Clear any word selections if collapsed the active group
        selectedWords.clear();
        hasSelectedWords.value = false;
      });
    }
  }

  /// Toggles the default case of new notes
  void toggleCapitalNotes() {
    setState(() => app.settings['notesCapital'] =
        !(app.settings['notesCapital'] ?? false));
  }

  void onLockTap() {
    lockStatus.value = lockStatus.value.onTapNextStatus();
    decideLockNextAction();
  }

  void decideLockNextAction() {
    switch (lockStatus.value) {
      case LockStatus.locked:
        bookNoteSyncMoveList = [];
        initializeSyncMoveListPerParagraph();
        break;
      default:
        bookNoteSyncMoveList = [];
    }

    setState(() {});
  }

  void initializeSyncMoveListPerParagraph() {
    BookChapter? chapter = widget.book.allChapters
        .firstWhereOrNull((element) => element.uuid == this.chapter.uuid);
    if (chapter == null) return;
    for (BookParagraphGroup g in (chapter.groups)) {
      addBookNoteSyncMoveItems(g);
    }
  }

  void addBookNoteSyncMoveItems(BookParagraphGroup group) {
    bookNoteSyncMoveList.addAll([
      BookNoteSyncMove(
        paragraphUuid:
            group.paragraphs.isNotEmpty ? group.paragraphs.first.uuid : '',
        notes: findNotesWithIndex(group.notes, NoteConstant.justKeyIndex),
        swiperController: SwiperController(),
      ),
      BookNoteSyncMove(
        paragraphUuid:
            group.paragraphs.isNotEmpty ? group.paragraphs.first.uuid : '',
        notes: findNotesWithIndex(group.notes, NoteConstant.keyAndNoteIndex),
        swiperController: SwiperController(),
      ),
      BookNoteSyncMove(
        paragraphUuid:
            group.paragraphs.isNotEmpty ? group.paragraphs.first.uuid : '',
        notes: findNotesWithIndex(group.notes, NoteConstant.justNoteIndex),
        swiperController: SwiperController(),
      ),
    ]);
  }

  List<BookNote> findNotesWithIndex(List<BookNote> notes, int index) {
    return notes.where((element) => element.noteIndex == index).toList();
  }

  void addParagraphToSyncList(BookParagraph paragraph) {
    int index = findParagraphIndexInSyncList(paragraph.uuid);
    if (index >= 0) {}
  }

  int findParagraphIndexInSyncList(String paragraphUuid) {
    return bookNoteSyncMoveList
        .indexWhere((p) => p.paragraphUuid == paragraphUuid);
  }

  void onLockLongPress() {
    lockStatus.value = lockStatus.value.onTapNextStatus();
    decideLockNextAction();
  }

  /// Expands all paragraph groups in the chapter
  void expandAll() {
    for (var element in chapter.paragraphs.paragraphs) {
      element.uiOptions["expanded"] = true;
    }
    paragraphsExpanded.value = true;

    setState(() {});
  }

  /// Collapses all paragraph groups in the chapter
  void collapseAll() {
    // Clear any word selections

    for (var element in chapter.paragraphs.paragraphs) {
      element.uiOptions["expanded"] = false;
    }
    selectedWords.clear();
    clearParagraphSelection();

    paragraphsExpanded.value = false;

    setState(() {});
  }

  ///Collapse all paragraphs till the one that does not have notes;
  void collapseAllTillNoteFinished() {
    if (collapseAction == CollapseAction.collapseTillNoNotes) {
      for (var element in chapter.paragraphs.paragraphs) {
        element.uiOptions["expanded"] = false;
      }
      for (int index = chapter.paragraphs.paragraphs.length - 1;
          index >= 0;
          index--) {
        if (chapter.paragraphs.paragraphs[index].notes.isNotEmpty) break;
        chapter.paragraphs.paragraphs[index].uiOptions["expanded"] = true;
      }
      collapseAction = collapseAction.next;
    } else {
      expandAll();
      for (BookParagraph paragraph in chapter.paragraphs.paragraphs) {
        if (paragraph.containsActualNotes()) {
          paragraph.uiOptions["expanded"] = false;
        }
      }

      collapseAction = collapseAction.next;
    }

    selectedWords.clear();

    clearParagraphSelection();

    setState(() {});
  }

  /// Selects the given paragraph
  Future<void> selectParagraph(BookParagraph paragraph) async {
    stopGearRotationTimer();
    if (this.paragraph.value == paragraph) return;

    cropActivated.value = false;

    lastDeletedNotes = [];

    if (!this.paragraph.value.isNullParagraph) {
      BookParagraphGroup? group = chapter.groups.firstWhereOrNull(
          (element) => element.contains(this.paragraph.value));
      if (group != null) {
        if (group.notes.isEmpty) {
          group.expanded = true;
          setState(() {});
        }
      }
    }

    lastNoteAdded = null;
    lastAction.value = LastAction.noAction;
    binActivated.value = false;

    if (thereIsNewNote && !onSaving) {
      onSaving = true;
      thereIsNewNote = false;
      widget.book.replaceChapter(chapter);
      await app.justSaveBook(widget.book);
      onSaving = false;
    }

    this.paragraph.value = paragraph;
    if (!keywordsLocked.value && !noteWordsLocked.value) {
      if (this.paragraph.value.notes.isNotEmpty &&
          this.paragraph.value.notes.last.notewords.isNotEmpty) {
        isNextKeyword.value = true;
      } else if (this.paragraph.value.notes.isEmpty) {
        isNextKeyword.value = true;
      } else {
        isNextKeyword.value = false;
      }
    }
    if (paragraph.notes.isNotEmpty) {
      if (paragraph.notes.last.noteIndex == NoteConstant.justNoteIndex) {
        isNextKeyword.value = false;
      } else if (paragraph.notes.last.noteIndex == NoteConstant.justKeyIndex) {
        isNextKeyword.value = true;
      }
    }
    selectedWords.clear();
    hasSelectedWords.value = false;
    // if (lockStatus.value == LockStatus.strictlyLocked) {
    //   reviseNoteIndex();
    // }
    setState(() {});
  }

  /// Sets a paragraph's color and all the remaining of the same group
  void setParagraphColor(BookParagraph? paragraph, String color) {
    if (paragraph == null) return;

    var group = chapter.findGroupByParagraph(paragraph);
    if (group == null) return;

    int idx = group.indexOf(paragraph);
    for (int num = idx; num < group.length; num++) {
      group[num].color = color;
    }

    // Trigger re-render

    setState(() => bookChanged = true);
  }

  /// Links a paragraph with the previous group by matching its color
  void linkParagraphWithPrevious(BookParagraph paragraph) {
    var index = chapter.getParagraphIndexViaUuid(paragraph.uuid);
    if (index == 0) return;

    paragraph = chapter.paragraphs[index];
    setParagraphColor(paragraph, chapter.paragraphs[index - 1].color);
  }

  /// Unlinks a paragraph from its group by unmatching its color
  void unlinkParagraphWithPrevious(BookParagraph paragraph) {
    var index = chapter.paragraphs.indexOf(paragraph);

    if (index == 0) return;

    BookParagraphGroup group =
        chapter.groups.firstWhere((g) => g.paragraphs.contains(paragraph));

    if (!group.expanded) {
      if (!groupHasOtherNotes(group, paragraph)) {
        group.expanded = true;

        setState(() {});
      }
    }

    setParagraphColor(paragraph,
        BookParagraph.getColorAfterUnlink(index, chapter.paragraphs));
  }

  bool groupHasOtherNotes(
      BookParagraphGroup group, BookParagraph currentParagraph) {
    return group.paragraphs.firstWhereOrNull((element) =>
            element.notes.isNotEmpty &&
            element.uuid != currentParagraph.uuid) !=
        null;
  }

  /// Creates a new note from the selected words in current paragraph
  void createNoteFromSelected() {
    if (paragraph.value.isNullParagraph) return;
    if (selectedWords.isEmpty) return;

    paragraph.value.addNote(selectedWords);

    // Force rebuild

    setState(() => bookChanged = true);

    selectedWords.clear();
    hasSelectedWords.value = false;
  }

  /// Opens note's question editor bottom sheet
  void showEditNoteSheet(BookNote note) {
    Rx<NoteNoteBarSize> noteBarSize = note.noteBarSize.obs;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext bc) {
        return Obx(
          () => NoteEditSheet(
            onChangeSize: (NoteNoteBarSize size) =>
                onChangeNoteBarSize(size, note, noteBarSize),
            noteBarSize: noteBarSize.value,
            onSelectSymbol: (String keyText, noteText, String questionText) =>
                selectSymbol(
              note,
              keyText,
              noteText,
              questionText,
            ),
          ),
        );
      },
    );

    // Trigger re-render

    setState(() {});
  }

  void onChangeNoteBarSize(
      NoteNoteBarSize size, BookNote note, Rx<NoteNoteBarSize> noteBarSize) {
    note.noteBarSize = size;
    noteBarSize.value = size;
    setState(() {});
  }

  /// Opens note's keyword editor bottom sheet
  void editKeyword(BookNote note) {
    showEditNoteSheet(note);

    // Trigger re-render

    setState(() {});
  }

  void editNote({BookNote? note}) {
    note ??= this.note;
    var p = chapter.paragraphs.firstWhere((p) => p.notes.contains(note));
    var g = chapter.groups.firstWhere((g) => g.paragraphs.contains(p));
    switch (g.notesIndex) {
      case 0:
        onEditNoteSheet(note!);
        break;

      case 1:
      case 2:
        onEditNoteSheet(note!);
        break;
    }
  }

  /// Previews given note's photo in an enlarged dialog
  void previewPhoto(BookNote note) async {
    BookParagraph currentParagraph =
        chapter.paragraphs.firstWhereOrNull((p) => p.notes.contains(note)) ??
            paragraph.value;
    Rx<NotePhotoSize> photoSize = note.photoSize.obs;
    final bgColor = BookParagraph.colors[currentParagraph.color]
        ?[BookParagraph.colorBackKeywords];
    final bgIconColor = BookParagraph.colors[currentParagraph.color]
        ?[BookParagraph.colorTextPrimary];

    ui.Size size = note.hasAsset
        ? ImageUtil.fetchAppropriateSize(context)
        : await ImageUtil.fetchAppropriateSizeForImage(
            note.imageData, context, mounted);

    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) => Obx(() => note.hasAsset
            ? SizedBox(
                child: PreviewSvgSheet(
                    onChangeSize: (size) =>
                        onChangePhotoSize(size, note, photoSize),
                    onReplace: () => onReplacePhoto(note),
                    onDelete: () => onDeletePhoto(note),
                    width: size.width,
                    height: size.height,
                    bgIconColor: bgIconColor ?? Colors.white,
                    bgColor: bgColor ?? Colors.white,
                    imageData: note.imageData,
                    photoSize: photoSize.value),
              )
            : PreviewPhotoSheet(
                onChangeSize: (size) =>
                    onChangePhotoSize(size, note, photoSize),
                onReplace: () => onReplacePhoto(note),
                onDelete: () => onDeletePhoto(note),
                width: size.width,
                height: size.height,
                bgIconColor: bgIconColor ?? Colors.white,
                bgColor: bgColor ?? Colors.white,
                imageData: note.imageData,
                photoSize: photoSize.value)));
  }

  void onDeletePhoto(BookNote note) {
    note.hasAsset = false;
    setState(() => note.imageData = '');

    Navigator.pop(context);
  }

  void onReplacePhoto(BookNote note) {
    Navigator.pop(context);

    selectPhoto(note);
  }

  void onChangePhotoSize(
      NotePhotoSize size, BookNote note, Rx<NotePhotoSize> photoSize) {
    note.photoSize = size;
    photoSize.value = size;
    setState(() {});
  }

  /// Opens the photo selection bottom sheet to select a photo or capture from device's camera
  void selectPhoto(BookNote note) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext bc) {
        NotePhotoSelectController controller = NotePhotoSelectController.find;
        BookParagraph currentParagraph = chapter.paragraphs
                .firstWhereOrNull((p) => p.notes.contains(note)) ??
            paragraph.value;
        controller.initialize(
          paragraph: currentParagraph,
          onCompleted: (data) => onPhotoSelectionCompleted(
            note,
            data,
            controller.photoSize.value,
          ),
          onCompletedAsset: (data) => onSvgSelectionCompleted(
            note,
            data,
            controller.photoSize.value,
          ),
        );
        return const NotePhotoSelectSheetV2();
      },
    );
    // Trigger re-render

    setState(() {});
  }

  void selectSymbol(
    BookNote note,
    String keyText,
    String noteText,
    String questionText,
  ) {
    Get.back();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext bc) {
        NoteSymbolSelectController controller = NoteSymbolSelectController.find;
        BookParagraph currentParagraph = chapter.paragraphs
                .firstWhereOrNull((p) => p.notes.contains(note)) ??
            paragraph.value;
        controller.initialize(
          onDeleteSymbol: () {
            note.name = keyText;
            note.note = noteText;
            note.question = questionText;
            Get.back();
            setState(() {
              note.symbolAssetPath = '';
            });
          },
          paragraph: currentParagraph,
          onCompletedAsset: (assetPath) {
            note.name = keyText;
            note.note = noteText;
            note.question = questionText;
            onSelectNoteSymbolComplete(assetPath, note);
          },
        );
        return const NoteSymbolSelectSheet();
      },
    );
    // Trigger re-render

    setState(() {});
  }

  void onSelectNoteSymbolComplete(String assetPath, BookNote note) {
    setState(() {
      note.symbolAssetPath = assetPath;
    });
    Get.back();
  }

  void onPhotoSelectionCompleted(
      BookNote note, String data, NotePhotoSize size) {
    note.photoSize = size;
    note.hasAsset = false;
    setState(() {
      note.imageData = data;
      // save();
    });
    Navigator.of(context).pop();
  }

  void onSvgSelectionCompleted(BookNote note, String data, NotePhotoSize size) {
    note.photoSize = size;
    setState(() {
      note.imageData = data;
      note.hasAsset = true;
      // save();
    });
    Navigator.of(context).pop();
  }

  /// Saves note changes made to the book
  Future<void> save({bool intermediate = false}) async {
    var status = await app.saveBook(widget.book,
        intermediateSave: intermediate, applyJson: false);
    if (status.isOK) setState(() => bookChanged = false);
  }

  /// Marks the current chapter as studied and stores the new read status
  void markAsRead() async {
    bool changed = false;

    // Level up to the next study state
    if ([
      StudyEligibilityState.none,
      StudyEligibilityState.onTime,
      StudyEligibilityState.late
    ].contains(lastStudyEligibilityState)) {
      // Change study state only if study eligibility time is no late
      if (lastStudyEligibilityState != StudyEligibilityState.late) {
        chapter.studyState = chapter.studyState.next;

        // Reset repetitions counter as chapter is being moved to the next state
        chapter.repetitions = 0;
      } else if (chapter.repetitions < 5) {
        chapter.studyState = chapter.studyState.next;
        // Increase repetitions counter
        chapter.repetitions = 0;
      }

      chapter.lastRead = DateTime.now();

      // Mark chapter as changed so book gets saved before leaving
      changed = true;
    } else if (lastStudyEligibilityState == StudyEligibilityState.early) {
      if (chapter.repetitions < 5) {
        // Increase repetitions counter
        chapter.repetitions++;

        // Mark chapter as changed so book gets saved before leaving
        changed = true;
      } else {
        Navigator.of(context).maybePop();
      }
    } else {
      // When study stage is early, don't do anything
      Navigator.of(context).maybePop();
    }

    if (changed) {
      widget.book.replaceChapter(chapter);
      Navigator.of(context).pop(widget.book);
    }
  }

  Future<void> scrollToTop() async {
    await _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  Future<void> scrollUp() async {
    _scrollController.jumpTo(_scrollController.offset + BookNote.rowHeight);
  }

  Future<void> scrollDown(double noteSize) async {
    _scrollController.jumpTo(_scrollController.offset - noteSize);
  }

  // endregion

  // region Event methods
  void onToggleExpanded(BookParagraph paragraph) {
    var group =
        chapter.groups.firstWhere((g) => g.paragraphs.contains(paragraph));
    toggleExpanded(group);
  }

  void onToggleCapitalNotes() {
    toggleCapitalNotes();
  }

  void onClearSelection() {
    // If there are words selected, clear words; otherwise deselect the paragraph
    closeShiftingMode();
    if (selectedWords.isNotEmpty) {
      clearWordSelection();
    } else {
      activatedNote.value = BookNote(
          paragraphUuid: '',
          keywords: [],
          notewords: [],
          uuid: const Uuid().v4());
      if (paragraph.value.notes.isEmpty) {
        BookParagraphGroup? selectedGroup = chapter.groups
            .firstWhereOrNull((element) => element.contains(paragraph.value));
        if (selectedGroup != null) {
          int paragraphIndex = selectedGroup.indexOf(paragraph.value);
          if (paragraphIndex > 0) {
            paragraph.value.uiOptions["expanded"] = selectedGroup
                .elementAt(paragraphIndex - 1)
                .uiOptions["expanded"];
          }
        }
      }

      clearParagraphSelection();
    }
  }

  void onClearSelectionLongPressV2() {
    // If there are words selected, clear words; otherwise deselect the paragraph
    BookParagraphGroup? selectedGroup = chapter.groups
        .firstWhere((element) => element.contains(paragraph.value));
    if ((selectedGroup.notes).isNotEmpty) {
      activatedNote.value = BookNote(
          paragraphUuid: paragraph.value.uuid,
          keywords: [],
          notewords: [],
          uuid: const Uuid().v4());
      for (var p in selectedGroup.paragraphs) {
        p.uiOptions["expanded"] = false;
      }
      clearParagraphSelection();
    }
  }

  void onClearSelectionLongPress() {
    // If there are words selected, clear words; otherwise deselect the paragraph
    BookParagraphGroup? selectedGroup = chapter.groups
        .firstWhere((element) => element.contains(paragraph.value));
    if ((selectedGroup.notes).isNotEmpty) {
      onNoteDoubleTap(selectedGroup.notes.first);
      clearParagraphSelection();
    }
  }

  void onClearParagraphSelection() {
    clearParagraphSelection();
  }

  void onChangeColor(BookParagraph paragraph, String color) async {
    // Close the pop-over to avoid rendering exceptions
    // reviseNoteIndex();
    Navigator.of(context).pop();
    await Future.delayed(const Duration(milliseconds: 250));
    BookParagraphGroup group =
        chapter.groups.firstWhere((g) => g.paragraphs.contains(paragraph));

    if (!group.expanded) {
      if (!groupHasOtherNotes(group, paragraph)) {
        group.expanded = true;

        setState(() {});
      }
    }

    setParagraphColor(paragraph, color);
  }

  void onChangeColorNoParagraph(String color) async {
    // Close the pop-over to avoid rendering exceptions
    Navigator.of(context).pop();
    await Future.delayed(const Duration(milliseconds: 250));

    BookParagraphGroup group = chapter.groups
        .firstWhere((g) => g.paragraphs.contains(paragraph.value));

    if (!group.expanded) {
      if (!groupHasOtherNotes(group, paragraph.value)) {
        group.expanded = true;

        setState(() {});
      }
    }

    setParagraphColor(paragraph.value, color);
  }

  void onLinkWithPrevious(BookParagraph paragraph) {
    closeShiftingMode();
    linkParagraphWithPrevious(paragraph);
  }

  void onUnlinkWithPrevious(BookParagraph paragraph) {
    closeShiftingMode();
    unlinkParagraphWithPrevious(paragraph);
  }

  void closeShiftingMode() {
    keyShiftingStatusTimer?.cancel();
    noteShiftingStatusTimer?.cancel();
    shiftingStatus.value = ShiftingStatus.none;
  }

  void onAddAsKeywords(BookNote? note, bool? capital) {
    addAsKeywords(note, capital: capital);
  }

  void onAddActionTap(BookNote? note, bool? capital, {bool? longpress}) {
    if ((longpress ?? false) && !(addActionLock.value)) {
      addActionLock.value = true;
      return;
    }

    if (addActionLock.value) {
      addActionLock.value = false;
    }

    addAction.value = addAction.value == AddAction.keyword
        ? AddAction.note
        : AddAction.keyword;
  }

  void onAddAsNote(BookNote? note) {
    // If paragraph's last note has no notewords, automatically add the selected words into the last paragraph note
    if (note == null &&
        !paragraph.value.isNullParagraph &&
        paragraph.value.notes.isNotEmpty &&
        paragraph.value.notes.last.notewords.isEmpty &&
        paragraph.value.notes.last.imageData.isEmpty) {
      note = paragraph.value.notes.last;
    }

    addAsNotes(note, capital: notesCapital);
  }

  void onEditNoteSheet(BookNote note) {
    BookParagraph? paragraph = findParagraphFromNote(note);
    if (paragraph == null) return;

    Get.lazyReplace(
      () => NoteEditController(
          paragraph: paragraph,
          note: note,
          onDeleteTap: () {
            Get.back();
            paragraph.notes.remove(note);

            setState(() {});
          },
          onCancel: Get.back,
          onSave: (name, noteStr, question) {
            Get.back();
            note.name = name;
            note.note = noteStr;
            note.question = question;

            setState(() {});
          }),
    );
    showEditNoteSheet(note);
  }

  void onTapDeleteNote(BookNote note, DeleteFromNote value) {
    BookParagraphGroup? group = chapter.groups
        .firstWhereOrNull((element) => element.contains(paragraph.value));
    if (group == null) return;

    int paragraphIndex = chapter.paragraphs.indexOf(
        group.firstWhereOrNull((element) => element.notes.contains(note)) ??
            BookParagraph());

    if (paragraphIndex < 0) return;

    int noteIndex = chapter.paragraphs[paragraphIndex].notes.indexOf(note);

    if (noteIndex < 0) return;
    if (note.imageData.isNotEmpty && value == DeleteFromNote.image) {
      lastDeletedImage = note.imageData;
      chapter.paragraphs[paragraphIndex].notes[noteIndex].imageData = '';
      lastAction.value = LastAction.deleteImageFromNote;
    } else if (note.hasKeywords &&
        (note.hasNotewords || note.imageData.isNotEmpty) &&
        value == DeleteFromNote.key) {
      lastDeletedKeywords
        ..clear()
        ..addAll(group.notes[noteIndex].keywords);
      chapter.paragraphs[paragraphIndex].notes[noteIndex].keywords.clear();
      lastAction.value = LastAction.deleteKeywordsFromNote;
    } else if (note.hasKeywords &&
        note.hasNotewords &&
        value == DeleteFromNote.note) {
      lastDeletedKeywords
        ..clear()
        ..addAll(chapter.paragraphs[paragraphIndex].notes[noteIndex].notewords);
      lastDeletedNoteTitle =
          chapter.paragraphs[paragraphIndex].notes[noteIndex].note;
      chapter.paragraphs[paragraphIndex].notes[noteIndex].notewords.clear();
      chapter.paragraphs[paragraphIndex].notes[noteIndex].note = '';
      lastAction.value = LastAction.deleteNoteWordsFromNote;
    } else {
      lastDeletedNote = note;
      lastAction.value = LastAction.deleteNote;
      lastDeletedNotes ??= [];
      lastDeletedNotes!
          .add(chapter.paragraphs[paragraphIndex].notes.elementAt(noteIndex));
      scrollDown(lastDeletedNote?.noteHeight ?? 0);
      chapter.paragraphs[paragraphIndex].notes.removeAt(noteIndex);
      chapter.paragraphs[paragraphIndex].notes
          .insert(noteIndex, BookNote.nullNote);

      if (chapter.paragraphs[paragraphIndex].notes.last.isNullNoteV2) {
        chapter.paragraphs[paragraphIndex].notes
            .remove(chapter.paragraphs[paragraphIndex].notes.last);
      }
    }
    lastDeletedNoteParagraphIndex = paragraphIndex;
    lastDeletedNoteIndex = noteIndex;
    calculateNextAction();
    try {
      chapter.paragraphs[paragraphIndex].notes[noteIndex]
          .calculateStartAndEndIndex(paragraph.value);
    } catch (_) {}

    setState(() {});
    fixParagraphContainsOnlyNullValuesOrNullValuesInTheEnd();
    return;
  }

  void onPhotoTap(BookNote note) {
    if (binActivated.value) {
      onTapDeleteNote(note, DeleteFromNote.image);
      return;
    }

    // Adding photos is available only on notes empty note words
    if (note.hasNotewords) return;

    if (note.imageData.isNotEmpty && selectedWords.isEmpty) {
      previewPhoto(note);
    } else {
      if (hasSelectedWords.value) {
        note.noteIndex == 0 ? onKeywordsTap(note) : onNoteTap(note);
      }
      selectPhoto(note);
    }
  }

  void onPhotoSizeTap(BookNote note, bool increase) {
    var newSize = note.photoSize;

    if (increase) {
      switch (note.photoSize) {
        case NotePhotoSize.small:
          newSize = NotePhotoSize.medium;
          break;
        case NotePhotoSize.medium:
          newSize = NotePhotoSize.large;
          break;
        default:
          break;
      }
    } else {
      switch (note.photoSize) {
        case NotePhotoSize.large:
          newSize = NotePhotoSize.medium;
          break;
        case NotePhotoSize.medium:
          newSize = NotePhotoSize.small;
          break;
        default:
          break;
      }
    }

    if (newSize != note.photoSize) {
      // If note's photo view size was changed, re-render

      setState(() => note.photoSize = newSize);
    }
  }

  void onShowAnswer(BookNote note) {
    // Trigger re-render

    setState(() {
      note.showAnswer = !note.showAnswer;
    });
  }

  void onParagraphTap(BookParagraph paragraph) {
    selectParagraph(paragraph);
  }

  void onParagraphDoubleTap(BookParagraph paragraph) {}

  void onParagraphLongPress(BookParagraph paragraph) {}

  void onCropLongPress(BookParagraph paragraph) {
    paragraph.cropUntilIndex = null;

    setState(() {});
  }

  void onWordTap(BookParagraph paragraph, String word, int cnt) async {
    if (selectedWords.isEmpty) calculateNextAction();
    if (selectedWords.containsKeyword(word, cnt)) {
      if (binActivated.value) {
        selectedWords.removeWhere(
            (element) => element.word == word && element.pos == cnt);
        setState(() {});
        return;
      }

      if (shiftingStatus.value != ShiftingStatus.none) {
        selectedWords[selectedWords.indexOf(selectedWords.firstWhere(
                (element) => element.word == word && element.pos == cnt))]
            .capital = !(selectedWords[selectedWords.indexOf(
                selectedWords.firstWhere(
                    (element) => element.word == word && element.pos == cnt))]
            .capital);
        return;
      }
    }

    shiftingStatus.value = ShiftingStatus.none;
    keyShiftingStatusTimer?.cancel();
    noteShiftingStatusTimer?.cancel();

    binActivated.value = false;
    if (cropActivated.value && paragraph == this.paragraph.value) {
      paragraph.cropUntilIndex = null;
      for (int index = cnt - 1; index >= 0; index--) {
        if (paragraph.text.asWords()[index].containsEndingSymbol) {
          paragraph.cropUntilIndex = index;
          break;
        }
      }

      // if (lockStatus.value == LockStatus.strictlyLocked) {
      //   reviseNoteIndex();
      // }
      setState(() {});

      cropActivated.value = false;
      if (paragraph.cropUntilIndex != null) return;
    }

    lastDeletedNotes = [];

    if (paragraph != this.paragraph.value) {
      await selectParagraph(paragraph);
      toggleWord(word, cnt);
      updateAddActionValue();
    } else {
      toggleWord(word, cnt);
      updateAddActionValue();
    }
  }

  void updateAddActionValueV2() {
    if (paragraph.value.isNullParagraph) return;
    if (paragraph.value.notes.isEmpty) {
      addAction.value = AddAction.keyword;
      return;
    }

    if (paragraph.value.notes.last.notewords.isNotEmpty) {
      addAction.value = AddAction.keyword;
    } else {
      addAction.value = AddAction.note;
    }
  }

  void updateAddActionValue() {
    if (addActionLock.value) return;
    if (lastNoteSelectionMode != noteModeNone) {
      addAction.value = lastNoteSelectionMode == noteModeKeyword
          ? AddAction.note
          : AddAction.keyword;
      return;
    }
    BookNote? lastNote =
        !paragraph.value.isNullParagraph && paragraph.value.notes.isNotEmpty
            ? paragraph.value.notes.last
            : null;

    if (lastNote == null) {
      addAction.value = AddAction.keyword;
      return;
    }

    if (lastNote.notewords.isEmpty && lastNote.imageData.isEmpty) {
      addAction.value = AddAction.note;
    } else {
      addAction.value = AddAction.keyword;
    }
  }

  void onWordDoubleTap(BookParagraph paragraph, String word, int cnt) {
    selectParagraph(paragraph);
  }

  void onWordLongPress(BookParagraph paragraph, String word, int cnt) async {
    // Reset last note's selection mode

    lastNoteSelectionMode = noteModeNone;

    // There's nothing to do if no word has been tapped previously
    if (selectedWords.isEmpty) {
      return;
    }

    if (selectedWords.containsKeyword(word, cnt)) {
      fixParagraphContainsOnlyNullValuesOrNullValuesInTheEnd();

      if (isNextKeyword.value) {
        for (var element in selectedWords) {
          element.capital = noteWordsCapital.value;
        }

        BookNote? preexistedNote;
        if (paragraph.notes.isNotEmpty) {
          if (paragraph.notes.last.notewords.isEmpty &&
              paragraph.notes.last.imageData.isEmpty) {
            preexistedNote = paragraph.notes.last;
          }
        }
        addAsNotes(preexistedNote,
            capital: noteWordsCapital.value, clearSelection: true);
      } else {
        for (var element in selectedWords) {
          element.capital = keywordsCapital.value;
        }

        addAsKeywords(null,
            capital: keywordsCapital.value, clearSelection: true);
      }
      return;
    }

    // If current paragraph is different, then clear selection and act as a single-tap
    if (paragraph != this.paragraph.value) {
      clearWordSelection();
      await selectParagraph(paragraph);
      toggleWord(word, cnt);
      return;
    }

    var lastWordCnt = selectedWords.positions.last;

    // If long-tapped on the last selected word, act as a single-tap
    if (lastWordCnt == cnt) {
      toggleWord(word, cnt);

      return;
    }

    selectPhrase(lastWordCnt, cnt);
  }

  void onNoteLongPress(BookNote note) async {
    if (binActivated.value) {
      BookParagraph? currentParagraph = chapter.paragraphs
          .firstWhereOrNull((element) => element.notes.contains(note));
      BookParagraphGroup? currentGroup = chapter.groups.firstWhereOrNull(
          (element) => element.paragraphs.contains(paragraph.value));
      if (currentParagraph == null || currentGroup == null) return;
      if (!currentGroup.paragraphs.containsUuid(currentParagraph.uuid)) return;

      int noteIndex = currentParagraph.notes.indexOf(note);

      if (noteIndex < 0) return;
      lastDeletedNoteParagraphIndex =
          chapter.paragraphs.indexOf(currentParagraph);
      lastDeletedNoteIndex = noteIndex;
      lastDeletedNote = note;
      lastAction.value = LastAction.deleteNote;
      scrollDown(lastDeletedNote?.noteHeight ?? 0);
      currentParagraph.notes.removeAt(noteIndex);
      currentParagraph.notes.insert(noteIndex, BookNote.nullNote);

      if (currentParagraph.notes.last.isNullNoteV2) {
        currentParagraph.notes.remove(currentParagraph.notes.last);
      }

      setState(() {});
    } else {
      editNote(note: note);
    }
  }

  ///[onNoteDoubleTapV2] closes just the paragraph and the paragraphs below it that does not contain notes;
  void onNoteDoubleTapV2(BookNote note) {
    note.swiperController.index = 2;
    setState(() {});

    // Find the group the note belongs to and ensure the group is expanded
    BookParagraph paragraph =
        chapter.paragraphs.firstWhere((p) => p.notes.containsUuid(note.uuid));

    activatedNote.value = BookNote(
        paragraphUuid: paragraph.uuid,
        keywords: [],
        notewords: [],
        uuid: const Uuid().v4());

    paragraph.uiOptions["expanded"] = !paragraph.uiOptions["expanded"];

    BookParagraphGroup group =
        chapter.groups.firstWhere((g) => g.paragraphs.contains(paragraph));
    //
    int paragraphGroupIndex = group.indexOf(paragraph);

    int index = paragraphGroupIndex + 1;

    while (index < group.length) {
      if (group.paragraphs.elementAt(index).notes.isNotEmpty) break;
      group.paragraphs.elementAt(index).uiOptions["expanded"] =
          paragraph.uiOptions["expanded"];
      index++;
    }

    if (paragraph.uiOptions["expanded"]) {
      selectParagraph(paragraph);
    }

    if (!this.paragraph.value.uiOptions["expanded"]) {
      clearParagraphSelection();
    }

    setState(() {});
    // toggleExpanded(group);
  }

  void onNoteDoubleTap(BookNote note) async {
    // Find the group the note belongs to and ensure the group is expanded
    var paragraph =
        chapter.paragraphs.firstWhere((p) => p.notes.containsUuid(note.uuid));
    activatedNote.value = BookNote(
        paragraphUuid: paragraph.uuid,
        keywords: [],
        notewords: [],
        uuid: const Uuid().v4());
    var group =
        chapter.groups.firstWhere((g) => g.paragraphs.contains(paragraph));

    toggleExpanded(group);
  }

  void onNoteTap(BookNote note) async {
    bool insertOther = true;
    if (binActivated.value) {
      onTapDeleteNote(note, DeleteFromNote.note);
    }

    openSentencesOfNote(note,
        onSelectedParagraph: !paragraph.value.notes.containsUuid(note.uuid));

    if (activatedNote.value.isNullNote()) {
      selectParagraphOnNoteTap(note);
    }

    if (selectedWords.isEmpty) return;

    bool isNew = false;
    // Check if the tapped note belongs to the active paragraph
    if (paragraph.value !=
        chapter.paragraphs.firstWhere((p) => p.notes.contains(note))) return;

    if (note.hasNotewords || note.imageData.isNotEmpty) {
      // Insert a new note in the position of the tapped note

      BookNote newNote = BookNote(
        paragraphUuid: paragraph.value.uuid,
        note: getNoteName(true, noteWordsCapital.value),
        notewords: selectedWords
            .map((k) => !isNextKeyword.value
                ? Keyword(
                    k.capital ? k.word.toUpperCase() : k.word,
                    k.pos,
                    k.normalCase,
                    capital: noteWordsCapital.value,
                  )
                : Keyword(
                    noteWordsCapital.value ? k.word.toUpperCase() : k.word,
                    k.pos,
                    k.normalCase,
                    capital: noteWordsCapital.value,
                  ))
            .toList(),
        keywords: [],
        uuid: const Uuid().v4(),
      );

      insertNoteAndRefresh(
        newNote,
        note,
        LastAction.addNoteWordCreateNote,
      );

      isNew = true;
      insertOther = false;
      selectedWords.clear();
      calculateNextAction();
    }

    // Add selected words as notes to the tapped note
    if (insertOther) {
      addAsNotes(note,
          clearSelection: true,
          capital: noteWordsCapital.value,
          isNew: isNew,
          fromTappingOnNoteBar: true);
    }
  }

  void changeKeyBarStatusOnSyncedNotes(BookNote note) {
    BookNoteSyncMove bookNoteSyncMove =
        bookNoteSyncMoveList[findBookNoteSyncMoveIndex(note)];

    for (BookNote n in bookNoteSyncMove.notes) {
      n.keyBarStatus = n.keyBarStatus.nextStatus;
    }
  }

  void changeKeyBarStatus(BookNote note) {
    note.keyBarStatus = note.keyBarStatus.nextStatus;
  }

  void onKeywordsTap(BookNote note) async {
    bool insertOther = true;
    if (gearRotationMode.value != GearRotationMode.none) {
      if (lockStatus.value == LockStatus.locked) {
        changeKeyBarStatusOnSyncedNotes(note);
      } else {
        changeKeyBarStatus(note);
      }
      setState(() {});
      return;
    }
    if (binActivated.value) {
      onTapDeleteNote(note, DeleteFromNote.key);
    }

    openSentencesOfNote(note,
        onSelectedParagraph: !paragraph.value.notes.containsUuid(note.uuid));

    if (activatedNote.value.isNullNote()) {
      selectParagraphOnNoteTap(note);
    }

    bool isNew = false;
    if (selectedWords.isEmpty) return;

    // Check if the tapped note belongs to the active paragraph
    if (paragraph.value !=
        chapter.paragraphs.firstWhere((p) => p.notes.contains(note))) return;

    if (note.hasKeywords) {
      // Insert a new note in the position of the tapped note

      BookNote newNote = BookNote(
          paragraphUuid: paragraph.value.uuid,
          name: getNoteName(true, keywordsCapital.value),
          keywords: selectedWords
              .map((k) => Keyword(
                    k.capital ? k.word.toUpperCase() : k.word,
                    k.pos,
                    k.normalCase,
                    capital: keywordsCapital.value,
                  ))
              .toList(),
          notewords: [],
          uuid: const Uuid().v4());

      insertNoteAndRefresh(
        newNote,
        note,
        LastAction.addKeywordCreateNote,
      );

      isNew = true;
      insertOther = false;
      selectedWords.clear();
    }

    // Add selected words as keywords to the tapped note
    if (insertOther) addAsKeywords(note, isNew: isNew, fromTappingOnNote: true);
    // calculateNextAction();
  }

  void insertNoteAndRefresh(
    BookNote newNote,
    BookNote note,
    LastAction lastActionValue,
  ) async {
    int keptIndex = paragraph.value.notes.indexOf(note);
    newNote.calculateStartAndEndIndex(paragraph.value);
    newNote.noteIndex = note.noteIndex;
    scrollUp();
    paragraph.value.notes.insert(
      keptIndex,
      newNote,
    );

    BookParagraph keptParagraph = paragraph.value;

    setState(() {});

    paragraph.value = BookParagraph();

    await Future.delayed(const Duration(milliseconds: 100));

    selectParagraph(keptParagraph);

    setState(() {});

    lastNoteAdded = newNote;
    lastAction.value = lastActionValue;
  }

  void changeNoteSize(BookNote note) {
    if (binActivated.value) return;
    note.noteBarSize = note.noteBarSize.next;
    setState(() {});
  }

  void openSentencesOfNote(BookNote note, {bool onSelectedParagraph = false}) {
    BookParagraph? clickedParagraph = findParagraphFromNote(note);

    if (clickedParagraph != null && !clickedParagraph.uiOptions["expanded"]) {
      if (activatedNote.value == note && selectedWords.isEmpty) {
        activatedNote.value = BookNote(
            keywords: [],
            notewords: [],
            uuid: const Uuid().v4(),
            paragraphUuid: clickedParagraph.uuid);
        return;
      }
      activatedNote.value = note;
      selectParagraph(clickedParagraph);
    } else if (selectedWords.isEmpty) {
      if (!onSelectedParagraph) changeNoteSize(note);
    }
  }

  void onNotesIndexChanged(
      BookNote note, int page, List<BookNote>? notesToChange) async {
    closeShiftingMode();

    bool isNowNextKeyword = isNextKeyword.value;
    note.noteIndex = page;
    if (!paragraph.value.isNullParagraph &&
        paragraph.value.notes.last == note) {
      if (note.noteIndex == NoteConstant.justNoteIndex) {
        isNextKeyword.value = false;
      } else if (note.noteIndex == NoteConstant.justKeyIndex) {
        isNextKeyword.value = true;
      }
      if (note.noteIndex == NoteConstant.keyAndNoteIndex) {
        isNextKeyword.value = note.hasNotewords;
      }
    }

    if (isNowNextKeyword != isNextKeyword.value) {
      updateWordsCapital(
          isNextKeyword.value ? keywordsCapital.value : noteWordsCapital.value);
    }
  }

  void updateWordsCapital(bool capital) {
    for (var keyword in selectedWords) {
      keyword.capital = capital;
    }
    setState(() {});
  }

  void onTransparentIndexChanged(
      BookNote note, int page, List<BookNote>? notes) async {
    BookNoteSyncMove bookNoteSyncMove =
        bookNoteSyncMoveList[findBookNoteSyncMoveIndex(note)];
    List<BookNote> currentNotes = bookNoteSyncMove.notes;
    changeLockTransparentControllers(currentNotes, true);
    synchronouslyMoveNoteBars(currentNotes, page, bookNoteSyncMove);
    changeLockTransparentControllers(currentNotes, false);
  }

  void changeLockTransparentControllers(List<BookNote> notes, bool lock) {
    for (var n in notes) {
      n.transparentController.isBlocked = lock;
    }
  }

  void synchronouslyMoveNoteBars(
      List<BookNote> notes, int index, BookNoteSyncMove bookNoteSyncMove) {
    synchronouslyMoveNoteBarsByController(notes, index, SwiperController());
    synchronouslyMoveNoteBarsByController(
        notes, index, CustomSwiperController());
  }

  void synchronouslyMoveNoteBarsByController(
      List<BookNote> notes, int index, SwiperController controller) {
    for (BookNote n in notes) {
      moveItem(
          index,
          controller is CustomSwiperController
              ? n.transparentController
              : n.swiperController);
    }
  }

  void moveItem(int index, SwiperController swiperController) {
    swiperController.move(index);
  }

  int findBookNoteSyncMoveIndex(BookNote note) {
    bookNoteSyncMoveList.firstWhere((e) => e.notes.containsUuid(note.uuid));

    return bookNoteSyncMoveList
        .indexWhere((p) => p.notes.containsUuid(note.uuid));
  }

// endregion

  void selectParagraphOnNoteTap(BookNote note) {
    BookParagraphGroup? group = chapter.groups
        .firstWhereOrNull((element) => element.notes.contains(note));
    if (group != null) {
      int paragraphIndex = chapter.paragraphs.indexOf(
          group.firstWhereOrNull((element) => element.notes.contains(note)) ??
              BookParagraph());
      if (paragraphIndex >= 0) {
        if (chapter.paragraphs
            .elementAt(paragraphIndex)
            .uiOptions["expanded"]) {
          selectParagraph(chapter.paragraphs.elementAt(paragraphIndex));
        } else {
          clearParagraphSelection();
        }
      }
    }
  }

  BookParagraph? findParagraphFromNote(BookNote note) {
    BookParagraphGroup? group = chapter.groups
        .firstWhereOrNull((element) => element.notes.contains(note));
    if (group != null) {
      int paragraphIndex = chapter.paragraphs.indexOf(
          group.firstWhereOrNull((element) => element.notes.contains(note)) ??
              BookParagraph());
      if (paragraphIndex >= 0) {
        return chapter.paragraphs.elementAt(paragraphIndex);
      }
    }
    return null;
  }
}

enum CollapseAction {
  collapseTillNoNotes,
  collapseOnlyWhereNotes;

  CollapseAction get next {
    switch (this) {
      case CollapseAction.collapseTillNoNotes:
        return CollapseAction.collapseOnlyWhereNotes;
      case CollapseAction.collapseOnlyWhereNotes:
        return CollapseAction.collapseTillNoNotes;
    }
  }
}
