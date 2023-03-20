/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'dart:convert';

import 'package:aneya_core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/route_manager.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:notebars/classes/book_to_setup.dart';
import 'package:notebars/classes/book_chapter_for_study.dart';
import 'package:notebars/dialogs/chapter_new_from_source_sheet.dart';
import 'package:notebars/dialogs/editing_paragraph_dialog.dart';
import 'package:notebars/dialogs/paragraph_edit_sheet.dart';
import 'package:notebars/getx/controller/editing_paragraph_controller.dart';
import 'package:notebars/views/book_notes_view.dart';
import 'package:notebars/widgets/book/chapter/creating_chapter_mode_widget.dart';
import 'package:notebars/widgets/notes/book_notes_widget_toolbar.dart';
import 'package:uuid/uuid.dart';

import '../classes/book.dart';
import '../classes/book_chapter.dart';
import '../classes/book_paragraph.dart';
import '../dialogs/book_edit_sheet.dart';
import '../dialogs/chapter_edit_sheet.dart';
import '../extensions.dart';
import '../global.dart';
import '../widgets/book/chapters_list_toolbar.dart';

class BookSetupView extends StatefulWidget {
  const BookSetupView({Key? key, required this.bookToSetup}) : super(key: key);

  final BookToSetUp bookToSetup;

  @override
  BookSetupViewState createState() => BookSetupViewState();
}

class BookSetupViewState extends State<BookSetupView> {
  // region Properties
  late Book _book;
  final ScrollController _scrollController = ScrollController();

  ///if current chapter is a subChapter we need to keep the parentChapter.
  BookChapter? parentChapter;

  ///Also, if the current chapter is a unit, we need to keep the parentSubChapter too.
  BookChapter? parentSubChapter;

  /// The currently selected/being edited chapter
  int currentChapterIndex = 0;

  /// The currently activated chapter
  String currentChapterUuid = '';

  /// True if book has changed since it was loaded in the view
  bool bookChanged = false;

  /// True if paragraphs should expand to show their full content
  bool expanded = true;

  /// If true, paragraphs can be deleted when tapped
  EditMode editMode = EditMode.none;

  // endregion

  // region Getters
  /// True if book has issues (e.g. large chapters)
  bool get hasIssues =>
      _book.chapters.any((ch) => ch.length > Book.maxChapterLength);

  BookChapter get currentChapter => findChapterByUuid(currentChapterUuid);



  BookChapter findChapterByUuid(String uuid) {
    parentChapter = null;
    parentSubChapter = null;
    for (BookChapter chapter in _book.chapters) {
      if (chapter.uuid == currentChapterUuid) {
        return chapter;
      }
      for (BookChapter subChapter in chapter.subChapters) {
        if (subChapter.uuid == currentChapterUuid) {
          parentChapter = chapter;
          return subChapter;
        }
        for (BookChapter unit in subChapter.units) {
          if (unit.uuid == currentChapterUuid) {
            parentChapter = chapter;
            parentSubChapter = subChapter;
            return unit;
          }
        }
      }
    }
    return _book.chapters.first;
  }

  // endregion

  void updateColors() {
    for(int chapterIndex = 0; chapterIndex < _book.chapters.length; chapterIndex ++){
      for(int paragraphIndex = 0; paragraphIndex < _book.chapters[chapterIndex].paragraphs.length; paragraphIndex ++){
        if(_book.chapters[chapterIndex].paragraphs[paragraphIndex].color.isEmpty){
          if((_book.chapters[chapterIndex].paragraphs[paragraphIndex].text.asWords().length > 10 && !_book.chapters[chapterIndex].paragraphs[paragraphIndex].isLarge && !_book.chapters[chapterIndex].paragraphs[paragraphIndex].isTitle) && !_book.chapters[chapterIndex].paragraphs[paragraphIndex].hasBackground){
            Map<String, Map<String,Color>> revisedColors = BookParagraph.calculateRevisedList(paragraphIndex, _book.chapters[chapterIndex].paragraphs);
            _book.chapters[chapterIndex].paragraphs[paragraphIndex].color = BookParagraph.getRandomColor(revisedColors);
          }
        }
      }
    }

    for(int chapterIndex = 0; chapterIndex < _book.chapters.length; chapterIndex ++){
      for(int paragraphIndex = 0; paragraphIndex < _book.chapters[chapterIndex].paragraphs.length; paragraphIndex ++){
        if(_book.chapters[chapterIndex].paragraphs[paragraphIndex].color.isEmpty){
          if((_book.chapters[chapterIndex].paragraphs[paragraphIndex].text.asWords().length <= 10 || _book.chapters[chapterIndex].paragraphs[paragraphIndex].isLarge || _book.chapters[chapterIndex].paragraphs[paragraphIndex].isTitle) && !_book.chapters[chapterIndex].paragraphs[paragraphIndex].hasBackground){
            _book.chapters[chapterIndex].paragraphs[paragraphIndex].color = BookParagraph.getTitleColor(paragraphIndex, _book.chapters[chapterIndex].paragraphs);
          }
        }
      }
    }
  }

  // region Action methods
  /// Saves changes and navigates back to the previous view
  Future<void> save() async {
    updateColors();
    var status = await app.saveBook(_book, saveInLocalModifications: true);
    if (status.isOK) {
      _book = await app.fetchBookById(_book.uuid);
      setState(() {
        bookChanged = false;
      });
      if (!mounted) return;
    } else {
      if (!mounted) return; // Ensure context is valid across async gaps
      app.showStatusSnackBar(context, status);
    }
  }

  /// Navigates back to the previous view, confirming first if changes are made
  Future<void> back() async {
    if (!bookChanged) {
      Navigator.pop(context);
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Confirmation'),
            content: const Text('Leave without saving changes?'),
            actions: <Widget>[
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                child: const Text('Yes'),
                onPressed: () async {
                  Navigator.pop(context);
                  Navigator.of(context).popAndPushNamed('/libraries');
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> scrollToTop() async {
    await _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  Future<void> scrollToBottom() async {
    await _scrollController.animateTo(999999999999999,
        duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  /// Toggles [expanded] state to true or false
  void toggleExpand() {
    setState(() {
      expanded = !expanded;

      // Automatically deactivate edit mode when collapsing paragraphs
      if (!expanded) setEditMode(EditMode.none);
    });
  }

  /// Toggles the state of the edit mode
  void setEditMode(EditMode editMode) => setState(() =>
      this.editMode = this.editMode == editMode ? EditMode.none : editMode);

  /// Splits given paragraph into two, at the given word and position
  void splitParagraphOnWord(BookParagraph paragraph, String word, int pos) {
    var np = BookParagraph(
        text: paragraph.text.asWords().sublist(pos).join(' ').trim(),
        color: '');

    if (np.text.isEmpty) return;

    setState(() {
      if (paragraph == currentChapter.paragraphs.last) {
        currentChapter.paragraphs.add(np);
      } else {
        currentChapter.paragraphs
            .insert(currentChapter.paragraphs.indexOf(paragraph) + 1, np);
      }
      paragraph.text =
          paragraph.text.asWords().sublist(0, pos).join(' ').trim();

      // Discard any existing notes in the split paragraph
      paragraph.notes = [];

      bookChanged = true;
    });
  }

  /// Deletes the given paragraph from the current chapter
  void deleteParagraph(BookParagraph paragraph) {
    setState(() {
      currentChapter.paragraphs.remove(paragraph);
      bookChanged = true;
    });
  }

  /// Merges the given paragraph placing it at the end of the previous paragraph
  void mergeParagraphWithPrevious(BookParagraph paragraph) {
    var idx = currentChapter.paragraphs.indexOf(paragraph);
    if (idx <= 0) return;

    setState(() {
      currentChapter.paragraphs[idx - 1].text += ' ${paragraph.text}';
      currentChapter.paragraphs[idx - 1].text =
          currentChapter.paragraphs[idx - 1].text.trim();

      // Delete the merged paragraph
      currentChapter.paragraphs.remove(paragraph);

      bookChanged = true;
    });
  }

  /// Pastes the clipboard text content at the position of the given paragraph,
  /// or at the end of the chapter, if no paragraph is provided.
  void  pasteContent([BookParagraph? paragraph]) async {
    ClipboardData? clip = await Clipboard.getData(Clipboard.kTextPlain);

    if (clip == null || clip.text == null || clip.text!.isEmpty) {
      if (!mounted) return; // Ensure context is valid across async gaps
      app.showStatusSnackBar(
          context,
          const Status(false,
              message: 'No text contents found in the clipboard...'));
      return;
    }

    var book =
        Book.fromText(name: 'Untitled', libraryUuid: '', text: clip.text ?? '', colorize: false);

    if (paragraph != null) {
      // Insert the pasted paragraphs at the index of the tapped paragraph
      int tappedParagraphIndex = currentChapter.paragraphs.indexOf(paragraph);

      if(tappedParagraphIndex != 0){
        if(currentChapter.paragraphs[tappedParagraphIndex - 1].text.endsWith('.') || (clip.text.startsWithUpperCase)){
          currentChapter.paragraphs.insertAll(
              currentChapter.paragraphs.indexOf(paragraph),
              book.chapters.first.paragraphs);
        }else{
          currentChapter.paragraphs[tappedParagraphIndex - 1].text += ' ${book.chapters.first.paragraphs.first.text.substring(0,1).toLowerCase() + book.chapters.first.paragraphs.first.text.substring(1)}';
          currentChapter.paragraphs.insertAll(
              currentChapter.paragraphs.indexOf(paragraph),
              book.chapters.first.paragraphs.sublist(1));
        }
      }else {
        currentChapter.paragraphs.insertAll(0, book.chapters.first.paragraphs);

        currentChapter.name = currentChapter.generatedName;
      }


    } else {
      // Add the pasted paragraphs at the end of the chapter
      if(currentChapter.paragraphs.last.text.endsWith('.') && !clip.text.startsWithUpperCase){
        currentChapter.paragraphs.addAll(book.chapters.first.paragraphs);
      }else if(clip.text.startsWithUpperCase){
        currentChapter.paragraphs.addAll(book.chapters.first.paragraphs);
      } else{
        currentChapter.paragraphs.last.text += ' ${book.chapters.first.paragraphs.first.text.substring(0,1).toLowerCase() + book.chapters.first.paragraphs.first.text.substring(1)}';
        if(book.chapters.first.paragraphs.length > 1){
          currentChapter.paragraphs.addAll(book.chapters.first.paragraphs.sublist(1));
        }

      }

    }

    setState(() {
      bookChanged = true;
    });

    setState(() {
      editMode = EditMode.none;
    });
  }

  /// Cuts the chapter into two from the paragraph
  void cutChaptersIntoTwo(BookParagraph paragraph, {String? breakTitleWord}) {
    int depth = currentChapter.depth;
    if(depth == 0){
      _cutChapterIntoTwo(paragraph, breakTitleWord: breakTitleWord);
    }else if(depth == 1){
      _cutSubChapterIntoTwo(paragraph, breakTitleWord: breakTitleWord);
    }else if(depth == 2){
      _cutUnitIntoTwo(paragraph, breakTitleWord: breakTitleWord);
    }

    scrollToTop();
  }

  /// Create a new chapter and move all paragraphs from the index to the end, into it
  void _cutChapterIntoTwo(BookParagraph paragraph, {String? breakTitleWord}){
    int index = _book.chapters.indexOf(currentChapter);
    int paragraphIndex = _book.chapters[index].paragraphs.indexOf(paragraph);
    BookChapter chapter = BookChapter(name: '', uuid: const Uuid().v4());
    chapter.paragraphs
        .addAll(_book.chapters[index].paragraphs.sublist(paragraphIndex));

    //removes from the current chapter the paragraphs added into new chapter
    _book.chapters[index].paragraphs.removeRange(
        paragraphIndex, _book.chapters[index].paragraphs.length);
    chapter.subChapters = List.of(_book.chapters[index].subChapters);
    for (int index = 0; index < chapter.subChapters.length; index++) {
        chapter.subChapters[index].parentChapterUuid = chapter.uuid;
    }
    _book.chapters[index].subChapters.clear();
    chapter.name = breakTitleWord != null ? chapter.generateNameTillWord(breakTitleWord) : chapter.generatedName;
    _book.chapters.insert(index + 1, chapter);
    currentChapterUuid = chapter.uuid;
    setState(() {
      bookChanged = true;
    });
  }

  void _cutSubChapterIntoTwo(BookParagraph paragraph, {String? breakTitleWord}){
    if(parentChapter == null){
      if (!mounted) return; // Ensure context is valid across async gaps
      app.showStatusSnackBar(
          context,
          const Status(false,
              message: 'Unable to cut the chapter'));
      return;
    }
    int chapterIndex = _book.chapters.indexOf(parentChapter!);
    int subChapterIndex = parentChapter!.subChapters.indexOf(currentChapter);
    int paragraphIndex = _book.chapters[chapterIndex].subChapters[subChapterIndex].paragraphs.indexOf(paragraph);
    BookChapter chapter = BookChapter(name: '', uuid: const Uuid().v4(), depth: 1);
    chapter.paragraphs
        .addAll(_book.chapters[chapterIndex].subChapters[subChapterIndex].paragraphs.sublist(paragraphIndex));
    chapter.name = breakTitleWord != null ? chapter.generateNameTillWord(breakTitleWord) : chapter.generatedName;
    chapter.units = List.of(_book.chapters[chapterIndex].subChapters[subChapterIndex].units);
    chapter.parentChapterUuid = _book.chapters[chapterIndex].uuid;
    for(int index = 0; index < chapter.units.length; index++){
      chapter.units[index].parentChapterUuid = chapter.parentChapterUuid;
      chapter.units[index].parentSubchapterUuid = chapter.uuid;
    }
    chapter.parentChapterUuid = _book.chapters[chapterIndex].subChapters[subChapterIndex].parentChapterUuid;
    _book.chapters[chapterIndex].subChapters[subChapterIndex].units.clear();
    _book.chapters[chapterIndex].subChapters[subChapterIndex].paragraphs.removeRange(paragraphIndex, _book.chapters[chapterIndex].subChapters[subChapterIndex].paragraphs.length);
    _book.chapters[chapterIndex].subChapters.insert(subChapterIndex + 1, chapter);
    currentChapterUuid = chapter.uuid;
    setState(() {
      bookChanged = true;
    });
  }

  void _cutUnitIntoTwo(BookParagraph paragraph, {String? breakTitleWord}){
    if(parentChapter == null || parentSubChapter == null){
      if (!mounted) return; // Ensure context is valid across async gaps
      app.showStatusSnackBar(
          context,
          const Status(false,
              message: 'Unable to cut the chapter'));
      return;
    }

    int chapterIndex = _book.chapters.indexOf(parentChapter!);
    int subChapterIndex = parentChapter!.subChapters.indexOf(parentSubChapter!);
    int unitIndex = parentSubChapter!.units.indexOf(currentChapter);
    int paragraphIndex = _book.chapters[chapterIndex].subChapters[subChapterIndex].units[unitIndex].paragraphs.indexOf(paragraph);
    BookChapter chapter = BookChapter(name: '', uuid: const Uuid().v4(), depth: 2);
    chapter.paragraphs
        .addAll(_book.chapters[chapterIndex].subChapters[subChapterIndex].units[unitIndex].paragraphs.sublist(paragraphIndex));
    chapter.name = breakTitleWord != null ? chapter.generateNameTillWord(breakTitleWord) : chapter.generatedName;
    chapter.parentChapterUuid = _book.chapters[chapterIndex].subChapters[subChapterIndex].units[unitIndex].parentChapterUuid;
    chapter.parentSubchapterUuid = _book.chapters[chapterIndex].subChapters[subChapterIndex].units[unitIndex].parentSubchapterUuid;
    _book.chapters[chapterIndex].subChapters[subChapterIndex].units[unitIndex].paragraphs.removeRange(paragraphIndex, _book.chapters[chapterIndex].subChapters[subChapterIndex].units[unitIndex].paragraphs.length);
    _book.chapters[chapterIndex].subChapters[subChapterIndex].units.insert(unitIndex + 1, chapter);
    currentChapterUuid = chapter.uuid;
    setState(() {
      bookChanged = true;
    });
  }

  /// Pastes the clipboard text content into a new chapter that is added in the book
  void pasteContentIntoNewChapter() async {
    ClipboardData? clip = await Clipboard.getData(Clipboard.kTextPlain);

    if (clip == null || clip.text == null || clip.text!.isEmpty) {
      if (!mounted) return; // Ensure context is valid across async gaps
      app.showStatusSnackBar(
          context,
          const Status(false,
              message: 'No text contents found in the clipboard...'));
      return;
    }

    var tmpBook =
        Book.fromText(name: 'Untitled', libraryUuid: '', text: clip.text ?? '');
    var chapter = BookChapter(name: '', uuid: const Uuid().v4());

    setState(() {
      chapter.paragraphs.addAll(tmpBook.chapters.first.paragraphs);

      // Auto-generate chapter's name
      chapter.name = chapter.generatedName;

      _book.chapters.add(chapter);

      // Go to the newly added chapter
      currentChapterUuid = chapter.uuid;

      bookChanged = true;
    });

    scrollToTop();
  }

  void addSubchapterFromClipboard() async {
    ClipboardData? clip = await Clipboard.getData(Clipboard.kTextPlain);

    if (clip == null || clip.text == null || clip.text!.isEmpty) {
      if (!mounted) return; // Ensure context is valid across async gaps
      app.showStatusSnackBar(
          context,
          const Status(false,
              message: 'No text contents found in the clipboard...'));
      return;
    }

    _book.chapters[currentChapterIndex].addSubchapter(clip.text ?? '');
  }

  // endregion

  // region Event methods
  void onBookTitleEditTap() {
    /// Opens book editor bottom sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext bc) {
        return BookEditSheet(
          book: _book,
          onCancel: () => Navigator.of(context).pop(),
          onSave: (Book b) {
            setState(() {
              _book.name = b.name;
              _book.bookIcon = b.bookIcon;
              bookChanged = true;
            });
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void onChapterEditProperties(BookChapter chapter) {
    /// Opens chapter editor bottom sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext bc) {
        return ChapterEditSheet(
          chapter: chapter,
          onCancel: () => Navigator.of(context).pop(),
          onSave: (BookChapter c) {
            setState(() {
              chapter.name = c.name;
              bookChanged = true;
            });
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void onChapterDelete(
    BookChapter chapter,
    ChapterType type,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Text('Delete selected chapter (${chapter.name})?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: const Text('Yes'),
              onPressed: () async {
                // Fix current chapter index when deleting the last chapter
                switch (type) {
                  case ChapterType.chapter:
                    if (currentChapterIndex > 0 &&
                        currentChapterIndex == _book.chapters.length - 1) {
                      currentChapterIndex--;
                    }

                    setState(() {
                      _book.chapters.remove(chapter);
                      bookChanged = true;
                    });

                    break;
                  case ChapterType.subChapter:
                    BookChapter? parentChapter =
                        findChapterOfSubChapter(chapter);
                    if (parentChapter == null) {
                      return;
                    }
                    parentChapter.subChapters.remove(chapter);
                    currentChapterUuid = parentChapter.uuid;
                    setState(() {
                      bookChanged = true;
                    });

                    break;
                  case ChapterType.unit:
                    BookChapter? subChapter = findSubChapterOfUnit(chapter);
                    if (subChapter == null) {
                      return;
                    }
                    subChapter.units.remove(chapter);
                    currentChapterUuid = subChapter.uuid;
                    setState(() {
                      bookChanged = true;
                    });
                    break;
                }

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void onChapterButtonTap(BookChapter chapter) {
    setState(() {
      currentChapterUuid = chapter.uuid;
    });

    scrollToTop();
  }

  void onUnitMergeUp(BookChapter unit) {
    BookChapter? subChapter = findSubChapterOfUnit(unit);
    if (subChapter == null) {
      app.showStatusSnackBar(
        context,
        const Status(false,
            message: 'Unable to merge chapters. Please, Try again later...'),
      );
    }
    BookChapter? chapter = findChapterOfSubChapter(subChapter!);
    if (chapter == null) {
      app.showStatusSnackBar(
        context,
        const Status(false,
            message: 'Unable to merge chapters. Please, Try again later...'),
      );
    }
    int unitIndex = subChapter.units.indexOf(unit);
    int subChapterIndex = chapter!.subChapters.indexOf(subChapter);
    int chapterIndex = _book.chapters.indexOf(chapter);

    if (unitIndex == 0) {
      _book.chapters[chapterIndex].subChapters[subChapterIndex].paragraphs
          .addAll(unit.paragraphs);
      currentChapterUuid =
          _book.chapters[chapterIndex].subChapters[subChapterIndex].uuid;
    } else {
      _book.chapters[chapterIndex].subChapters[subChapterIndex]
          .units[unitIndex - 1].paragraphs
          .addAll(unit.paragraphs);
      currentChapterUuid = _book.chapters[chapterIndex]
          .subChapters[subChapterIndex].units[unitIndex - 1].uuid;
    }

    _book.chapters[chapterIndex].subChapters[subChapterIndex].units
        .remove(unit);

    setState(() {
      bookChanged = true;
    });
  }

  void onEdit(BookChapter chapter){
    BookChapter ch = _book.allChapters.firstWhere((c) => c.uuid == chapter.uuid);
    Navigator.of(context)
        .pushNamed('/study', arguments: BookChapterForStudy(book: _book, chapter: ch)).then((value) async {
      if(value is Book){

        value.lastVisitedChapter = ch.uuid;
        bookChanged = true;
        _book = value;
        save.call();
      }else {
        widget.bookToSetup.book.lastVisitedChapter = ch.uuid;
        await app.saveBook(widget.bookToSetup.book, saveInLocalModifications: true);
      }
    });
  }

  void onUnitMergeDown(BookChapter unit) {
    BookChapter? subChapter = findSubChapterOfUnit(unit);
    if (subChapter == null) {
      app.showStatusSnackBar(
        context,
        const Status(false,
            message: 'Unable to merge chapters. Please, Try again later...'),
      );
    }
    BookChapter? chapter = findChapterOfSubChapter(subChapter!);
    if (chapter == null) {
      app.showStatusSnackBar(
        context,
        const Status(false,
            message: 'Unable to merge chapters. Please, Try again later...'),
      );
    }
    int unitIndex = subChapter.units.indexOf(unit);
    int subChapterIndex = chapter!.subChapters.indexOf(subChapter);
    int chapterIndex = _book.chapters.indexOf(chapter);

    if (unitIndex == subChapter.units.length - 1) {
      if (chapterIndex + 1 == _book.chapters.length &&
          subChapterIndex + 1 == chapter.subChapters.length) {
        app.showStatusSnackBar(
          context,
          const Status(false,
              message:
                  'There is no next chapter to merge the current chapter with'),
        );
        return;
      }
      if (subChapterIndex + 1 != chapter.subChapters.length) {
        _book.chapters[chapterIndex].subChapters[subChapterIndex + 1].paragraphs
            .addAll(unit.paragraphs);
        currentChapterUuid =
            _book.chapters[chapterIndex].subChapters[subChapterIndex + 1].uuid;
      } else {
        _book.chapters[chapterIndex + 1].paragraphs.addAll(unit.paragraphs);
        currentChapterUuid = _book.chapters[chapterIndex + 1].uuid;
      }
    } else {
      _book.chapters[chapterIndex].subChapters[subChapterIndex]
          .units[unitIndex + 1].paragraphs
          .addAll(unit.paragraphs);
      currentChapterUuid = _book.chapters[chapterIndex]
          .subChapters[subChapterIndex].units[unitIndex + 1].uuid;
    }

    _book.chapters[chapterIndex].subChapters[subChapterIndex].units
        .remove(unit);

    setState(() {
      bookChanged = true;
    });
  }

  void onSubChapterMergeUp(BookChapter subChapter) {
    BookChapter? chapter = findChapterOfSubChapter(subChapter);
    if (chapter == null) {
      app.showStatusSnackBar(
        context,
        const Status(false,
            message: 'Unable to merge chapters. Please, Try again later...'),
      );
    }
    int subChapterIndex = chapter!.subChapters.indexOf(subChapter);
    int chapterIndex = _book.chapters.indexOf(chapter);

    if (subChapterIndex == 0) {
      _book.chapters[chapterIndex].paragraphs.addAll(subChapter.paragraphs);
      for (var element in subChapter.units) {
        element.depth = 1;
      }
      _book.chapters[chapterIndex].subChapters.addAll(subChapter.units);
      currentChapterUuid = chapter.uuid;
    } else {
      _book.chapters[chapterIndex].subChapters[subChapterIndex - 1].paragraphs
          .addAll(subChapter.paragraphs);
      chapter.subChapters[subChapterIndex - 1].units.addAll(subChapter.units);
      currentChapterUuid = chapter.subChapters[subChapterIndex - 1].uuid;
    }

    _book.chapters[chapterIndex].subChapters.remove(subChapter);
    setState(() {
      bookChanged = true;
    });
  }

  void onSubChapterMergeDown(BookChapter subChapter) {
    BookChapter? chapter = findChapterOfSubChapter(subChapter);
    if (chapter == null) {
      app.showStatusSnackBar(
        context,
        const Status(false,
            message: 'Unable to merge chapters. Please, Try again later...'),
      );
    }
    int subChapterIndex = chapter!.subChapters.indexOf(subChapter);
    int chapterIndex = _book.chapters.indexOf(chapter);

    if (subChapterIndex == chapter.subChapters.length - 1) {
      if (chapterIndex + 1 == _book.chapters.length) {
        app.showStatusSnackBar(
          context,
          const Status(false,
              message:
                  'There is no next chapter to merge the current chapter with'),
        );
        return;
      }
      _book.chapters[chapterIndex + 1].paragraphs.addAll(subChapter.paragraphs);
      for (var element in subChapter.units) {
        element.depth = 1;
      }
      _book.chapters[chapterIndex + 1].subChapters.addAll(subChapter.units);
      currentChapterUuid = _book.chapters[chapterIndex + 1].uuid;
    } else {
      _book.chapters[chapterIndex].subChapters[subChapterIndex + 1].paragraphs
          .addAll(subChapter.paragraphs);
      chapter.subChapters[subChapterIndex + 1].units.addAll(subChapter.units);
      currentChapterUuid = chapter.subChapters[subChapterIndex + 1].uuid;
    }

    _book.chapters[chapterIndex].subChapters.remove(subChapter);
    setState(() {
      bookChanged = true;
    });
  }

  BookChapter? findChapterOfSubChapter(BookChapter subChapter) {
    return _book.chapters.firstWhereOrNull(
        (element) => element.subChapters.contains(subChapter));
  }

  BookChapter? findSubChapterOfUnit(BookChapter unit) {
    for (var chapter in _book.chapters) {
      for (var subChapter in chapter.subChapters) {
        if (subChapter.units.contains(unit)) {
          return subChapter;
        }
      }
    }
    return null;
  }

  void onChapterMergeUp(BookChapter chapter) {
    if (chapter == _book.chapters.first) return;

    var idx = _book.chapters.indexOf(chapter);
    var previous = _book.chapters[idx - 1];
    previous.paragraphs.addAll(chapter.paragraphs);

    bool needsScroll = (currentChapter == chapter);
    if (currentChapterIndex == _book.chapters.length - 1) {
      setState(() => currentChapterIndex--);
    }

    if (needsScroll) scrollToTop();

    setState(() {
      _book.chapters.remove(chapter);
      bookChanged = true;
    });
  }

  void onChapterMergeDown(BookChapter chapter) {
    if (chapter == _book.chapters.last) return;

    var idx = _book.chapters.indexOf(chapter);
    var next = _book.chapters[idx + 1];
    next.paragraphs.insertAll(0, chapter.paragraphs);

    if (currentChapter == chapter) {
      scrollToTop();
    }

    setState(() {
      if (currentChapterIndex == _book.chapters.length - 1) {
        currentChapterIndex--;
      }

      _book.chapters.remove(chapter);
      bookChanged = true;
    });
  }

  void onParagraphDoubleTap(BookParagraph paragraph) {

  }

  void onParagraphTap(BookParagraph paragraph) {
    switch (editMode) {
      case EditMode.delete:
        deleteParagraph(paragraph);
        break;
      case EditMode.merge:
        mergeParagraphWithPrevious(paragraph);
        break;
      case EditMode.paste:
        pasteContent(paragraph);
        break;
      case EditMode.cutChapterIntoTwo:
        cutChaptersIntoTwo(paragraph);
        break;
      case EditMode.editParagraph:
        onEditingParagraph(paragraph);
        break;
      default:
        break;
    }
  }

  void onWordTap(BookParagraph paragraph, String word, int pos) {
    switch (editMode) {
      case EditMode.delete:
      case EditMode.merge:
      case EditMode.paste:
        onParagraphTap(paragraph);
        break;

      case EditMode.enter:
        splitParagraphOnWord(paragraph, word, pos);
        break;
      case EditMode.cutChapterIntoTwo:
        cutChaptersIntoTwo(paragraph, breakTitleWord: word);
        break;
      case EditMode.editParagraph:
        onEditingParagraph(paragraph);
        break;
      default:
        break;
    }
  }

  void onEditingParagraph(BookParagraph paragraph){
    final controller = EditingParagraphController.find;
    controller.initialize(
        paragraph, () {
      bookChanged = true;
      paragraph.isTitle = controller.isTitle.value;
      paragraph.isLarge = controller.isLarge.value;
      paragraph.isBold = controller.isBold.value;
      paragraph.isItalic = controller.isItalic.value;
      paragraph.hasBackground = controller.selectedBackgroundColor.value != 'no_color_selected';
      if(!paragraph.hasBackground){
        paragraph.color = '';
      }
      paragraph.hasAppliedStyling = true;
      if(paragraph.hasBackground){
        paragraph.color = controller.selectedBackgroundColor.value;
      }

      Get.back();
      setState(() {
      });
    }, () {
      Get.back();
    });
    showDialog(context: context, builder: (context){
      return const EditingParagraphDialog();
    });
  }

  void openFixerSheet(BookParagraph paragraph, String word, int pos){
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext bc) {
        return ParagraphEditSheet(
          paragraph: paragraph,
          onCancel: () => Navigator.of(context).pop(),
          onSave: (BookParagraph p) {
            currentChapter.paragraphs[currentChapter.paragraphs.indexOf(paragraph)] = p;
            setState(() {
              bookChanged = true;
            });
            Navigator.of(context).pop();
          }, pos: pos,
          word: word,
        );
      },
    );

  }

  // endregion

  @override
  void initState() {
    super.initState();
    _book = Book.fromJson(widget.bookToSetup.book.toJson());

    currentChapterUuid = (widget.bookToSetup.chapterUuid ?? _book.chapters.first.uuid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffdbe2e7),
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
        leading:
            IconButton(icon: const Icon(Icons.arrow_back), onPressed: back),
        title: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onBookTitleEditTap,
                child: Text(_book.name, textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Container(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => onChapterEditProperties(currentChapter),
                    child: Text(
                      currentChapter.name,
                      style: const TextStyle(
                          color: Color(0xffa1fbfe),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                if (currentChapter.length > Book.maxChapterLength) ...[
                  const SizedBox(width: 5),
                  const Icon(Icons.warning, color: Colors.pinkAccent, size: 16),
                  const SizedBox(width: 5),
                  Text(
                      'Split by ${(currentChapter.length / Book.maxChapterLength).ceil()}',
                      style: const TextStyle(color: Colors.pinkAccent)),
                ]
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: bookChanged && !hasIssues ? const Icon(Icons.save) : const Icon(Icons.edit),
            onPressed: bookChanged && !hasIssues ? save : () {
              onEdit(currentChapter);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent,
        onPressed: !hasIssues ? toggleExpand : null,
        child: Icon(
          Icons.visibility_outlined,
          color: expanded ? Colors.tealAccent : null,
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(top: 10, right: 10, bottom: 10),
        child: editMode == EditMode.creatingChapters
            ? CreatingChapterModeWidget(
                book: _book,
                bookChanged: () {
                  setState(() {
                    bookChanged = true;
                  });
                },
                currentIndexChanged: (int newIndex) {
                  currentChapterIndex = newIndex;
                },
                addChapter: openChapterImportSheet,
              )
            : Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ChaptersListToolbar(
                    book: _book,
                    bookChanged: bookChanged,
                    currentChapter: currentChapter,
                    onTapChapter: onChapterButtonTap,
                    onMergeUp: onChapterMergeUp,
                    onMergeUpSubChapter: onSubChapterMergeUp,
                    onMergeUpUnit: onUnitMergeUp,
                    onMergeDown: onChapterMergeDown,
                    onMergeDownSubChapter: onSubChapterMergeDown,
                    onMergeDownUnit: onUnitMergeDown,
                    onEdit: onEdit,
                    onDelete: onChapterDelete,
                    addChapter: openChapterImportSheet,
                  ),
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: currentChapter.render(
                          lockedIndexes: const {},
                          customGroups: [],
                          lockStatus: LockStatus.unlocked,
                          onTransparentIndexChanged: (_, __, ___)  {},
                          onNotesIndexChanged: (_, __, ___) {},
                          shiftingStatus: ShiftingStatus.none,
                          addActionLock: false,
                          onEdit: onChapterEditProperties,
                          mode: BookRenderMode.process,
                          onlyFirstWords: !expanded,
                          onParagraphDoubleTap: (p) {
                            final controller = EditingParagraphController.find;
                            if(controller.hasBeenInitialized){
                              p.isBold = controller.isBold.value;
                              p.isTitle = controller.isTitle.value;
                              p.isItalic = controller.isItalic.value;
                              p.hasBackground = controller.hasBackground.value;
                              if(controller.selectedBackgroundColor.value != 'no_color_selected'){
                                p.color = controller.selectedBackgroundColor.value;
                              }
                              setState(() {
                              });
                            }
                          },
                          onParagraphTap: onParagraphTap,
                          onWordLongPress: openFixerSheet,
                          addAction: AddAction.keyword,
                          onWordTap: onWordTap,
                        )..add(
                            editMode == EditMode.paste
                                ? InkWell(
                                    onTap: () {
                                      editMode = EditMode.none;
                                      pasteContent();
                                    },
                                    child: const ListTile(
                                      leading: Icon(
                                        Icons.add,
                                      ),
                                      title: Text('Add Text Here'),
                                    ),
                                  )
                                : const SizedBox(),
                          ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.deepPurpleAccent,
        shape: const CircularNotchedRectangle(),
        child: IconTheme(
          data:
              IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ToggleButtons(
                isSelected: [
                  editMode == EditMode.enter,
                ],
                onPressed: expanded & !hasIssues
                    ? (index) =>
                        setEditMode(EditMode.enter)
                    : null,
                renderBorder: false,
                color: Colors.white,
                selectedColor: Colors.tealAccent,
                fillColor: Colors.deepPurple.withOpacity(.3),
                borderRadius: BorderRadius.circular(10),
                children: const [
                  Icon(Icons.keyboard_return_rounded),
                ],
              ),
              ToggleButtons(
                isSelected: [editMode == EditMode.merge],
                onPressed: (index) => setEditMode(EditMode.merge),
                renderBorder: false,
                color: Colors.white,
                selectedColor: Colors.tealAccent,
                fillColor: Colors.deepPurple.withOpacity(.3),
                borderRadius: BorderRadius.circular(10),
                children: [
                  GestureDetector(
                    child: const Icon(Icons.merge_type_rounded),
                  ),
                ],
              ),
              ToggleButtons(
                isSelected: [editMode == EditMode.paste],
                onPressed: (index) => setEditMode(EditMode.paste),
                renderBorder: false,
                color: Colors.white,
                selectedColor: Colors.tealAccent,
                fillColor: Colors.deepPurple.withOpacity(.3),
                borderRadius: BorderRadius.circular(10),
                children: [
                  GestureDetector(
                    child: const Icon(Icons.paste_rounded),
                  ),
                ],
              ),
              ToggleButtons(
                isSelected: [editMode == EditMode.addPhoto],
                onPressed: (index) => setEditMode(EditMode.addPhoto),
                renderBorder: false,
                color: Colors.white,
                selectedColor: Colors.tealAccent,
                fillColor: Colors.deepPurple.withOpacity(.3),
                borderRadius: BorderRadius.circular(10),
                children: [
                  GestureDetector(
                    child: const Icon(Icons.photo_camera_outlined),
                  ),
                ],
              ),
              ToggleButtons(
                isSelected: [editMode == EditMode.editParagraph],
                onPressed: (index) {
                  setState(() {
                    editMode = editMode == EditMode.editParagraph
                        ? EditMode.none
                        : EditMode.editParagraph;
                  });
                },
                renderBorder: false,
                color: Colors.white,
                selectedColor: Colors.tealAccent,
                fillColor: Colors.deepPurple.withOpacity(.3),
                borderRadius: BorderRadius.circular(10),
                children: const [
                  Icon(Icons.format_size),
                ],
              ),
              ToggleButtons(
                isSelected: [editMode == EditMode.cutChapterIntoTwo],
                onPressed: (index) {
                  setState(() {
                    editMode = editMode == EditMode.cutChapterIntoTwo
                        ? EditMode.none
                        : EditMode.cutChapterIntoTwo;
                  });
                },
                renderBorder: false,
                color: Colors.white,
                selectedColor: Colors.tealAccent,
                fillColor: Colors.deepPurple.withOpacity(.3),
                borderRadius: BorderRadius.circular(10),
                children: const [
                  Icon(Icons.dns_outlined)
                ],
              ),
              ToggleButtons(
                isSelected: [editMode == EditMode.creatingChapters],
                onPressed: (index) {
                  setState(() {
                    editMode = editMode == EditMode.creatingChapters
                        ? EditMode.none
                        : EditMode.creatingChapters;
                  });
                },
                renderBorder: false,
                color: Colors.white,
                selectedColor: Colors.tealAccent,
                fillColor: Colors.deepPurple.withOpacity(.3),
                borderRadius: BorderRadius.circular(10),
                children: const [
                  Icon(Icons.swap_horizontal_circle_outlined)
                ],
              ),
              ToggleButtons(
                isSelected: [editMode == EditMode.delete],
                onPressed: (index) => setEditMode(EditMode.delete),
                renderBorder: false,
                color: Colors.white,
                selectedColor: Colors.tealAccent,
                fillColor: Colors.deepPurple.withOpacity(.3),
                borderRadius: BorderRadius.circular(10),
                children: const [Icon(Icons.delete_forever_outlined)],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void openChapterImportSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext bc) {
        return ChapterNewFromSourceSheet(
          book: _book,
          onCancel: _onDismissSheet,
          onImportFromClipboard: () {
            pasteContentIntoNewChapter();
            Navigator.of(context).pop();
          },
          onImportFromFile: () => {
            //TODO: implement import from file method
          },
          onImportFromUrl: importChapterFromUrl,
        );
      },
    );
  }

  void importChapterFromUrl() async {
    Navigator.of(context).pop();

    final ClipboardData? text = await Clipboard.getData(Clipboard.kTextPlain);

    if (!mounted) return;

    if (text == null || text.text == null || text.text!.isEmpty) {
      app.showStatusSnackBar(
          context,
          const Status(false,
              message: 'No text contents found in the clipboard...'));
      return;
    }

    final String? url = text.text;

    if (url == null || url.trim().isEmpty || !Uri.parse(url).isAbsolute) {
      app.showStatusSnackBar(
          context,
          const Status(false,
              message:
                  'It seems that the url you copied is invalid. Please, copy a file url.(ex: https://mybook.com/chapter1'));
      return;
    }

    try {
      // region Fetch html from URL address
      var response =
          await http.get(Uri.parse(url), headers: {'accept-charset': 'UTF-8'});
      // endregion
      // region Extract plain text from HTML
      final document = parse(utf8.decode(response.bodyBytes));
      final String text =
          parse(document.body?.text ?? '').documentElement!.text;
      // endregion

      var status = await _importChapterFromText(_book, text);
      if (!mounted) return; // Ensure context is valid across async gaps

      if (status.isOK) {
        // Navigator.pop(context);
        // Navigator.of(context).popAndPushNamed('/book/chapters', arguments: status.data);
      } else {
        app.showStatusSnackBar(context, status);
      }
    } catch (e) {
      app.showStatusSnackBar(
          context,
          Status(false,
              message:
                  'Error fetching and parsing the URL contents. Details: ${e.toString()}'));
    } finally {}
  }

  void _onDismissSheet() {
    Navigator.of(context).pop();
  }

  Future<Status<BookChapter>> _importChapterFromText(
      Book book, String text) async {
    if (text.length < 500) {
      return const Status(false,
          message: 'Contents are too small to represent a book...');
    }

    BookChapter chapter = BookChapter.parseTextAsChapter(text);

    // var status = await app.saveBook(book, saveInLocalModifications: true);
    // if (status.isError) {
    //   return Status<BookChapter>(false,
    //       code: status.code, message: status.message);
    // }

    // Trigger reactivity
    book.chapters.add(chapter);

    currentChapterUuid = chapter.uuid;
    setState(() => {});

    return Status(true, data: chapter);
  }
}

enum EditMode { delete, enter, merge, paste, none, creatingChapters, cutChapterIntoTwo, editParagraph, addPhoto}
