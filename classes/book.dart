/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:aneya_core/core.dart';
import 'package:aneya_json/json.dart';
import 'package:flutter/material.dart';
import 'package:notebars/widgets/library/book_button.dart';

import '../../../extensions.dart';
import 'book_chapter.dart';

enum BookRenderMode { process, notes, read }

class Book {
  // region Constants
  static const String renderProcess = 'process';
  static const String renderNotes = 'notes';
  static const String renderRead = 'read';

  static const int maxChapterLength = 100000;
  // endregion

  // region Properties
  String uuid;
  String driveId;
  String libraryUuid;
  String name;
  late List<String> authors;
  String isbn;
  String version;
  String textHash;
  bool keepNotes;
  late DateTime created;
  DateTime? modified;
  DateTime? accessed;
  late List<BookChapter> chapters;
  late Map<String, dynamic> uiOptions;
  String? lastVisitedChapter;
  String? bookIcon;
  // endregion

  // region Constructor & initialization
  Book(
      {required this.name,
      this.uuid = '',
      this.driveId = '',
      required this.libraryUuid,
      this.isbn = '',
      this.version = '',
      this.textHash = '',
      this.keepNotes = true,
        this.lastVisitedChapter,
        this.bookIcon,
      }) {
    chapters = [];
    authors = [];
    created = DateTime.now();
  }

  List<BookChapter> get allChapters {
    List<BookChapter> allChapters = [];
    for (BookChapter chapter in chapters){
      allChapters.add(chapter);
      for(BookChapter subChapter in chapter.subChapters){
        allChapters.add(subChapter);
        for(BookChapter unit in subChapter.units){
          allChapters.add(unit);
        }
      }
    }
    return allChapters;
  }

  factory Book.fromJson(Map<String, dynamic> cfg) => Book(name: '', libraryUuid: cfg['libraryUuid']).applyCfg(cfg);
  factory Book.fromText({required String libraryUuid, required String text, String name = '', bool colorize = true}) => Book(name: name, libraryUuid: libraryUuid).parseText(text, colorize: colorize);

  Json toJson() => {
        "uuid": uuid,
        "driveId": driveId,
        "libraryUuid": libraryUuid,
        "textHash": textHash,
        "name": name,
        "isbn": isbn,
        "version": version,
        "authors": authors,
        "chapters": chapters.map((e) => e.toJson()).toList(),
        "keepNotes": keepNotes,
        "lastVisitedChapter": lastVisitedChapter,
        "created": created.toIso8601String(),
        "modified": modified?.toIso8601String(),
        "accessed": accessed?.toIso8601String(),
    if(bookIcon != null) "book_icon": bookIcon,
      };

  applyCfg(Json cfg, [bool strict = false]) {
    if (strict == true) {
      uuid = cfg.getString('uuid', '');
      driveId = cfg.getString('driveId', '');
      libraryUuid = cfg.getString('libraryUuid', '');
      name = cfg.getString('name', '');
      isbn = cfg.getString('isbn', '');
      version = cfg.getString('version', '');
      textHash = cfg.getString('textHash', '');
      lastVisitedChapter = cfg.getString('lastVisitedChapter', '');
      keepNotes = cfg.getBool('keepNotes', true);
      authors = cfg.getList<String>('authors', []);

      created = cfg.getDateTime('created', DateTime.now());
      modified = cfg.getDateTimeOrNull('modified');
      accessed = cfg.getDateTimeOrNull('accessed');
      bookIcon = cfg.getString("book_icon", '').isNotEmpty ? cfg.getString("book_icon", '') : null;

      if (cfg.containsKey('chapters')) {
        if (cfg['chapters'] is List<BookChapter>) {
          chapters
            ..clear()
            ..addAll((cfg['chapters'] as List<BookChapter>));
        } else if (cfg['chapters'] is List) {
          chapters
            ..clear()
            ..addAll((cfg['chapters'] as List).map((cfg) => BookChapter.fromJson(Json.from(cfg))));
        } else {
          chapters.clear();
        }
      } else {
        chapters.clear();
      }
    } else {
      uuid = cfg.getString('uuid', uuid);
      driveId = cfg.getString('driveId', '');
      libraryUuid = cfg.getString('libraryUuid', libraryUuid);
      name = cfg.getString('name', name);
      isbn = cfg.getString('isbn', isbn);
      version = cfg.getString('version', version);
      textHash = cfg.getString('textHash', textHash);
      keepNotes = cfg.getBool('keepNotes', keepNotes);
      authors = cfg.getList<String>('authors', authors);
      lastVisitedChapter = cfg.getString('lastVisitedChapter', '');
      created = cfg.getDateTime('created', created);
      modified = cfg.getDateTimeOrNull('modified', modified);
      accessed = cfg.getDateTimeOrNull('accessed', accessed);
      bookIcon = cfg.getString("book_icon", '').isNotEmpty ? cfg.getString("book_icon", '') : null;

      if (cfg.containsKey('chapters')) {
        if (cfg['chapters'] is List<BookChapter>) {
          chapters
            ..clear()
            ..addAll((cfg['chapters'] as List<BookChapter>));
        } else if (cfg['chapters'] is List) {
          chapters
            ..clear()
            ..addAll((cfg['chapters'] as List).map((cfg) => BookChapter.fromJson(Json.from(cfg))));
        }
      }
    }

    return this;
  }
  // endregion

  // region Getters
  /// Returns full plain text after compiling all chapters and paragraphs
  String get fulltext => textHash;

  /// Returns true if the book contains at least one chapter that is eligible for studying
  bool get eligibleForStudying => chapters.any((chapter) => chapter.eligibleForStudying);

  ///Returns the color that the bell of the [BookButton] should be
  Color get bellColor => allChapters.any((chapter) => chapter.studyEligibilityState == StudyEligibilityState.late) ? StudyEligibilityState.late.color : allChapters.any((chapter) => chapter.studyEligibilityState == StudyEligibilityState.onTime) ? StudyEligibilityState.onTime.color : allChapters.any((chapter) => chapter.studyEligibilityState == StudyEligibilityState.early && chapter.eligibleForStudying) ? StudyEligibilityState.early.color : Colors.transparent;

  /// Returns the chapters that are eligible for studying
  List<BookChapter> get eligibleChaptersForStudying => chapters.where((chapter) => chapter.eligibleForStudying).toList();

  /// Returns the chapters that are on-time for studying
  List<BookChapter> get onTimeChaptersForStudying {
    List<BookChapter> chaptersForStudying = [];

    for (BookChapter chapter in chapters) {
      if([StudyEligibilityState.onTime, StudyEligibilityState.late].contains(chapter.studyEligibilityState)){
        chaptersForStudying.add(chapter);
      }
      for (var subchapter in chapter.subChapters) {
        if([StudyEligibilityState.onTime, StudyEligibilityState.late].contains(subchapter.studyEligibilityState)){
          chaptersForStudying.add(subchapter);
        }
        for (var unit in subchapter.units) {
          if([StudyEligibilityState.onTime, StudyEligibilityState.late].contains(unit.studyEligibilityState)){
            chaptersForStudying.add(unit);
          }
        }
      }
    }

    return chaptersForStudying;
  }
  // endregion

  // region Methods
  Book parseTextIntoParagraphs(String text){

    List<String> lines = text.asLines();
    List<String> paragraphs = [];

    lines.removeWhere((element) => element.isEmpty);

    for(String line in lines){

      if(paragraphs.isNotEmpty){
        if(paragraphs.last.endsWith('.') || line.startsWithUpperCase){
          paragraphs.add('\n');
          paragraphs.add(line);
        }else if(paragraphs.last != '\n'){
          paragraphs.last = '${paragraphs.last } $line';
        }else{
          paragraphs.add(line);
        }
      }else{
        paragraphs.add(line);
      }

    }

    return this;
  }

  Book parseText(String text, {bool colorize = true}) {

    chapters
      ..clear()
      ..add(BookChapter.parseTextAsChapter(text, colorize: colorize));

    return this;
  }

  void replaceChapter(BookChapter newChapter){

    //if the chapter is a unit;
    if(newChapter.parentSubchapterUuid != null && (newChapter.parentSubchapterUuid?.isNotEmpty ?? false)){
      //we need to ensure that everything is right
      if(newChapter.parentChapterUuid != null && (newChapter.parentChapterUuid?.isNotEmpty ?? false)){
        int chapterIndex = chapters.indexOf(chapters.firstWhere((element) => element.uuid == newChapter.parentChapterUuid));
        int subChapterIndex = chapters[chapterIndex].subChapters.indexOf(chapters[chapterIndex].subChapters.firstWhere((element) => element.uuid == newChapter.parentSubchapterUuid));
        int unitIndex = chapters[chapterIndex].subChapters[subChapterIndex].units.indexOf(chapters[chapterIndex].subChapters[subChapterIndex].units.firstWhere((element) => element.uuid == newChapter.uuid));
        if(chapters[chapterIndex].subChapters[subChapterIndex].units[unitIndex].paragraphs.firstWhereOrNull((element) => element.notes.isNotEmpty) != null){
          newChapter.paragraphs = chapters[chapterIndex].subChapters[subChapterIndex].units[unitIndex].paragraphs;
        }
        chapters[chapterIndex].subChapters[subChapterIndex].units[unitIndex] = newChapter;
      }
      //if the chapter is a subchapter;
    }else if(newChapter.parentChapterUuid != null && (newChapter.parentChapterUuid?.isNotEmpty ?? false)){
      int chapterIndex = chapters.indexOf(chapters.firstWhere((element) => element.uuid == newChapter.parentChapterUuid));
      int subChapterIndex = chapters[chapterIndex].subChapters.indexOf(chapters[chapterIndex].subChapters.firstWhere((element) => element.uuid == newChapter.uuid));
      if(chapters[chapterIndex].subChapters[subChapterIndex].paragraphs.firstWhereOrNull((element) => element.notes.isNotEmpty) != null){
        newChapter.paragraphs = chapters[chapterIndex].subChapters[subChapterIndex].paragraphs;
      }
      chapters[chapterIndex].subChapters[subChapterIndex] = newChapter;
      //if the chapter is just a chapter;
    }else {
      int chapterIndex = chapters.indexOf(chapters.firstWhere((element) => element.uuid == newChapter.uuid));
      chapters[chapterIndex]= newChapter;
    }

  }

  BookChapter findChapterById(String uuid, int depth, {String? parentChapterUuid, String? parentSubChapterUuid}){
    if(depth == 0){
      return chapters.firstWhere((element) => element.uuid == uuid);
    }else if(depth == 1){
      return chapters.firstWhere((element) => element.uuid == parentChapterUuid).subChapters.firstWhere((element) => element.uuid == uuid);
    }else if(depth == 2){
      return chapters.firstWhere((element) => element.uuid == parentChapterUuid).subChapters.firstWhere((element) => element.uuid == parentSubChapterUuid).units.firstWhere((element) => element.uuid == uuid);
    }


    return BookChapter(name: 'name');
  }

  // endregion
}
