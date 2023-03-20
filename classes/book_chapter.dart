/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:aneya_core/core.dart';
import 'package:aneya_json/json.dart';
import 'package:flutter/material.dart';
import 'package:notebars/classes/book.dart';
import 'package:notebars/classes/book_note.dart';
import 'package:notebars/global.dart';
import 'package:uuid/uuid.dart';

import '../../../extensions.dart';
import 'book_paragraph.dart';



class BookChapter {
  // region Properties
  String uuid;
  String? parentChapterUuid;
  String? parentSubchapterUuid;
  String name;
  DateTime lastRead = DateTime(1980);
  StudyState studyState = StudyState.none;
  int repetitions = 0;
  int depth;
  late List<BookChapter> subChapters;
  late List<BookChapter> units;
  late List<BookParagraph> paragraphs;

  // endregion

  // region Getters/setters
  /// Returns the length of all paragraphs in the chapter
  int get length => paragraphs.fold(0, (sum, p) => sum + p.text.length);

  /// Returns an auto-generated name for the chapter, based on the content of its first paragraph
  String get generatedName {
    // Auto-generate chapter's name

    if(app.settings["smartChapterCreation"] ?? true){
      try{
        ///remove all characters until alphabetical character;
        ///first, we need to create the regex
        String regex = r'[^\p{Alphabetic}\p{Mark}\p{Connector_Punctuation}\p{Join_Control}\s]+';
        ///then we get the first line with no symbols and numbers
        String lineReplaced = (paragraphs.first.text.replaceAll(RegExp(regex, unicode: true),'')).trim();
        ///finally, we will start the first line from the position that the symbols and the numerics finished
        paragraphs.first.text = paragraphs.first.text.substring(paragraphs.first.text.indexOf(lineReplaced.first!));
      }catch(_){}

    }


    var words = paragraphs.first.text.asWords();

    String joinedTitle = words.length > 7 ? words.sublist(0,7).sublist(0,7).join(' '): words.join(' ');

    return capitalizeFirstWord(joinedTitle.length > 60? '${joinedTitle.substring(0,60)}...' : joinedTitle);
  }

  static String capitalizeFirstWord(String text){
    List<String> words = text.asWords();

    for(int index = 0; index< words.length; index ++){
      try{
        words[index] = words[index].substring(0,1).toUpperCase() + words[index].substring(1);
      }catch(e){
        continue;
      }

    }

    return words.join(' ');
  }

  String generateNameTillWord(String word){

    if(app.settings["smartChapterCreation"] ?? true){
      try{
        ///remove all characters until alphabetical character;
        ///first, we need to create the regex
        String regex = r'[^\p{Alphabetic}\p{Mark}\p{Connector_Punctuation}\p{Join_Control}\s]+';
        ///then we get the first line with no symbols and numbers
        String lineReplaced = (paragraphs.first.text.replaceAll(RegExp(regex, unicode: true),'')).trim();
        ///finally, we will start the first line from the position that the symbols and the numerics finished
        paragraphs.first.text = paragraphs.first.text.substring(paragraphs.first.text.indexOf(lineReplaced.first!));
      }catch(_){}

    }

    var words = paragraphs.first.text.asWords();

    for(String word in words){
      word = word.substring(0,1).toUpperCase() + word.substring(1);
    }

    int indexOfWord = words.indexOf(word);

    if(indexOfWord < 0 || indexOfWord > 6) {
      return generatedName;
    }

    int totalLength = _totalLengthOfWords(words.sublist(0,indexOfWord + 1));

    return capitalizeFirstWord((totalLength > 60 ? '${words.join(' ').substring(0, 60)}...': words.length > 8 ? words.sublist(0,indexOfWord + 1).join(' ') : words.join(' ')));
  }

  int _totalLengthOfWords(List<String> words){
    int totalLength = 0;

    for(int index = 0; index < words.length; index++){
      if(words[index].length >= 15){
        words[index] = words[index].substring(0,15);
      }
      totalLength += words[index].length;
    }

    return totalLength;
  }

  /// Returns paragraphs in order, grouped by color
  List<BookParagraphGroup> get groups {
    List<BookParagraphGroup> ret = [];
    String lastColor = '-';
    BookParagraphGroup lastGroup = [];

    for (var p in paragraphs) {
      if (p.color == lastColor) {
        lastGroup.add(p);
      } else {
        if (lastGroup.isNotEmpty) ret.add(lastGroup);

        lastColor = p.color;
        lastGroup = [p];
      }
    }

    if (lastGroup.isNotEmpty) ret.add(lastGroup);

    return ret;
  }

  List<BookParagraphGroup> customGroups(BookNote? activatedNote) {
    List<BookParagraphGroup> ret = [];
    String lastColor = '-';
    BookParagraphGroup lastGroup = [];

    bool previousExpanded = false;
    bool previousContainsActivatedNote = false;
    for (var p in paragraphs) {
      if (p.color == lastColor && !previousExpanded && !previousContainsActivatedNote) {
        lastGroup.add(p);
      } else {
        if (lastGroup.isNotEmpty) ret.add(lastGroup);

        lastColor = p.color;
        lastGroup = [p];
      }
      previousExpanded = p.isExpanded;
      previousContainsActivatedNote = p.notes.containsUuid(activatedNote?.uuid ?? 'no_uuid');
    }

    if (lastGroup.isNotEmpty) ret.add(lastGroup);

    return ret;
  }


  /// Returns chapter's study eligibility state
  StudyEligibilityState get studyEligibilityState {
    var now = DateTime.now();
    var dur = now.difference(lastRead);
    switch (studyState) {
      case StudyState.soon:
        if (dur.inMinutes < StudyState.soon.min) {
          return StudyEligibilityState.early;
        } else if (dur.inMinutes > StudyState.soon.max) {
          return StudyEligibilityState.late;
        } else {
          return StudyEligibilityState.onTime;
        }
      case StudyState.hour:
        if (dur.inHours < StudyState.hour.min) {
          return StudyEligibilityState.early;
        } else if (dur.inMinutes > StudyState.hour.max * 60) {
          return StudyEligibilityState.late;
        } else {
          return StudyEligibilityState.onTime;
        }
      case StudyState.day:
        if (dur.inHours < StudyState.day.min) {
          return StudyEligibilityState.early;
        } else if (dur.inHours > StudyState.day.max) {
          return StudyEligibilityState.late;
        } else {
          return StudyEligibilityState.onTime;
        }
      case StudyState.week:
        if (dur.inDays < StudyState.week.min) {
          return StudyEligibilityState.early;
        } else if (dur.inDays > StudyState.week.max) {
          return StudyEligibilityState.late;
        } else {
          return StudyEligibilityState.onTime;
        }
      case StudyState.twoWeeks:
        if (dur.inDays < StudyState.twoWeeks.min) {
          return StudyEligibilityState.early;
        } else if (dur.inDays > StudyState.twoWeeks.max) {
          return StudyEligibilityState.late;
        } else {
          return StudyEligibilityState.onTime;
        }
      case StudyState.month:
        if (dur.inDays < StudyState.month.min) {
          return StudyEligibilityState.early;
        } else if (dur.inDays > StudyState.month.max) {
          return StudyEligibilityState.late;
        } else {
          return StudyEligibilityState.onTime;
        }
      case StudyState.quarter:
        if (dur.inDays < StudyState.quarter.min) {
          return StudyEligibilityState.early;
        } else if (dur.inDays > StudyState.quarter.max) {
          return StudyEligibilityState.late;
        } else {
          return StudyEligibilityState.onTime;
        }
      case StudyState.semester:
        if (dur.inDays < StudyState.semester.min) {
          return StudyEligibilityState.early;
        } else if (dur.inDays > StudyState.semester.max) {
          return StudyEligibilityState.late;
        } else {
          return StudyEligibilityState.onTime;
        }
      case StudyState.none:
      default:
        return StudyEligibilityState.none;
    }
  }

  /// Returns the time elapsed since the last time the chapter was studied.
  Duration get timeSinceLastStudy => DateTime.now().difference(lastRead);

  /// Returns the duration till the next time the chapter should be opened for study
  /// In case of delayed time, the duration is negative.
  Duration get timeToStudy {
    var now = DateTime.now();
    var dur = now.difference(lastRead);
    switch (studyState) {
      case StudyState.soon:
        if (dur.inMinutes < StudyState.soon.min) {
          return lastRead
              .add(Duration(minutes: StudyState.soon.min))
              .difference(now);
        } else {
          return lastRead
              .add(Duration(minutes: StudyState.soon.max))
              .difference(now);
        }
      case StudyState.hour:
        if (dur.inMinutes < StudyState.hour.min * 60) {
          return lastRead
              .add(Duration(hours: StudyState.hour.min))
              .difference(now);
        } else {
          return lastRead
              .add(Duration(hours: StudyState.hour.max))
              .difference(now);
        }
      case StudyState.day:
        if (dur.inHours < StudyState.day.min) {
          return lastRead
              .add(Duration(hours: StudyState.day.min))
              .difference(now);
        } else {
          return lastRead
              .add(Duration(hours: StudyState.day.max))
              .difference(now);
        }
      case StudyState.week:
        if (dur.inDays < StudyState.week.min) {
          return lastRead
              .add(Duration(days: StudyState.week.min))
              .difference(now);
        } else {
          return lastRead
              .add(Duration(days: StudyState.week.max))
              .difference(now);
        }
      case StudyState.twoWeeks:
        if (dur.inDays < StudyState.twoWeeks.min) {
          return lastRead
              .add(Duration(days: StudyState.twoWeeks.min))
              .difference(now);
        } else {
          return lastRead
              .add(Duration(days: StudyState.twoWeeks.max))
              .difference(now);
        }
      case StudyState.month:
        if (dur.inDays < StudyState.month.min) {
          return lastRead
              .add(Duration(days: StudyState.month.min))
              .difference(now);
        } else {
          return lastRead
              .add(Duration(days: StudyState.month.max))
              .difference(now);
        }
      case StudyState.quarter:
        if (dur.inDays < StudyState.quarter.min) {
          return lastRead
              .add(Duration(days: StudyState.quarter.min))
              .difference(now);
        } else {
          return lastRead
              .add(Duration(days: StudyState.quarter.max))
              .difference(now);
        }
      case StudyState.semester:
        if (dur.inDays < StudyState.semester.min) {
          return lastRead
              .add(Duration(days: StudyState.semester.min))
              .difference(now);
        } else {
          return lastRead
              .add(Duration(days: StudyState.semester.max))
              .difference(now);
        }
      case StudyState.none:
      default:
        return const Duration();
    }
  }

  /// Returns true if the time for the next study is less than a day
  bool get eligibleForStudying =>
      studyState != StudyState.none && timeToStudy.inDays < 1;

  // endregion

  // region Constructors and initialization
  BookChapter({required this.name,
    this.uuid = '',
    this.studyState = StudyState.none,
    this.depth = 0}) {
    paragraphs = [];
    subChapters = [];
    units = [];
  }

  static BookChapter parseTextAsChapter(String text, {bool colorize = true}) {
    List<String> lines = text.asLines();
    List<String> paragraphs = [];

    if(app.settings["smartChapterCreation"] ?? true){
      try{
        ///remove all characters until alphabetical character;
        ///first, we need to create the regex
        String regex = r'[^\p{Alphabetic}\p{Mark}\p{Connector_Punctuation}\p{Join_Control}\s]+';
        ///then we get the first line with no symbols and numbers
        String lineReplaced = (lines.first.replaceAll(RegExp(regex, unicode: true),'')).trim();
        ///finally, we will start the first line from the position that the symbols and the numerics finished
        lines.first = lines.first.substring(lines.first.indexOf(lineReplaced.first!));
      }catch(_){}

    }

    lines.removeWhere((element) => element.isEmpty);

    for (String line in lines) {
      if (paragraphs.isNotEmpty) {
        if (paragraphs.last.endsWith('.') || line.startsWithUpperCase) {
          paragraphs.add('\n');
          paragraphs.add(line);
        } else if (paragraphs.last != '\n') {
          paragraphs.last = '${paragraphs.last} $line';
        } else {
          paragraphs.add(line);
        }
      } else {
        paragraphs.add(line);
      }
    }

    paragraphs.removeWhere((element) => element == '\n');

    var words = paragraphs.first.asWords();

    return BookChapter.fromText(
        colorize: colorize,
        uuid: const Uuid().v4(),
        name: capitalizeFirstWord(words.sublist(0, words.length < 6 ? words.length : 5).join(' ')),
        lines: paragraphs,);
  }

  factory BookChapter.fromJson(Json cfg) =>
      BookChapter(name: '', uuid: cfg['uuid']).applyCfg(cfg);

  factory BookChapter.fromText({required String uuid,
    required List<String> lines,
    bool colorize = true,
    int depth = 0,
    String name = ''}) =>
      BookChapter(name: name, uuid: uuid, depth: depth)
          .parseLines(lines, colorize: colorize);

  Json toJson() =>
      {
        'uuid': uuid,
        'name': name,
        'lastRead': lastRead.toIso8601String(),
        'studyState': studyState.code,
        'repetitions': repetitions,
        'depth': depth,
        'parentChapterUuid': parentChapterUuid,
        'parentSubchapterUuid': parentSubchapterUuid,
        'subChapters': subChapters.map((e) => e.toJson()).toList(),
        'units': units.map((e) => e.toJson()).toList(),
        'paragraphs': paragraphs.map((p) => p.toJson()).toList(),
      };

  applyCfg(Json cfg, [bool strict = false]) {
    if (strict == true) {
      uuid = cfg.getString('uuid', '');
      name = cfg.getString('name', '');
      lastRead = cfg.getDateTime('lastRead', DateTime(1980));
      studyState = StudyState.fromString(cfg.getString('studyState', ''));
      repetitions = cfg.getInt('repetitions', 0);
      depth = cfg.getInt('depth', 0);
      parentChapterUuid = cfg.getString('parentChapterUuid', '');
      parentSubchapterUuid = cfg.getString('parentSubchapterUuid', '');

      if (cfg.containsKey('subChapters')) {
        if (cfg['subChapters'] is List<BookChapter>) {
          subChapters
            ..clear()
            ..addAll(cfg['subChapters']);
        } else if (cfg['subChapters'] is List) {
          subChapters
            ..clear()
            ..addAll((cfg['chapters'] as List)
                .map((cfg) => BookChapter.fromJson(Json.from(cfg))));
        } else {
          subChapters.clear();
        }
      } else {
        subChapters.clear();
      }
      if (cfg.containsKey('units')) {
        if (cfg['units'] is List<BookChapter>) {
          units
            ..clear()
            ..addAll(cfg['units']);
        } else if (cfg['units'] is List) {
          units
            ..clear()
            ..addAll((cfg['chapters'] as List)
                .map((cfg) => BookChapter.fromJson(Json.from(cfg))));
        } else {
          units.clear();
        }
      } else {
        units.clear();
      }

      if (cfg.containsKey('paragraphs')) {
        if (cfg['paragraphs'] is List<BookParagraph>) {
          paragraphs
            ..clear()
            ..addAll((cfg['paragraphs'] as List<BookParagraph>));
        } else if (cfg['paragraphs'] is List<String>) {
          parseLines(cfg['paragraphs'] as List<String>);
        } else if (cfg['paragraphs'] is List) {
          paragraphs
            ..clear()
            ..addAll((cfg['paragraphs'] as List)
                .map((cfg) => BookParagraph.fromJson(Json.from(cfg))));
        } else {
          paragraphs.clear();
        }
      } else {
        paragraphs.clear();
      }
    } else {
      uuid = cfg.getString('uuid', uuid);
      name = cfg.getString('name', name);
      lastRead = cfg.getDateTime('lastRead', lastRead);
      studyState =
          StudyState.fromString(cfg.getString('studyState', studyState.code));
      repetitions = cfg.getInt('repetitions', repetitions);
      depth = cfg.getInt('depth', 0);
      parentChapterUuid = cfg.getString('parentChapterUuid', '');
      parentSubchapterUuid = cfg.getString('parentSubchapterUuid', '');

      if (cfg.containsKey('subChapters')) {
        if (cfg['subChapters'] is List<BookChapter>) {
          subChapters
            ..clear()
            ..addAll((cfg['subChapters'] as List<BookChapter>));
        } else if (cfg['subChapters'] is List) {
          subChapters
            ..clear()
            ..addAll((cfg['subChapters'] as List)
                .map((cfg) => BookChapter.fromJson(Json.from(cfg))));
        }
      }

      if (cfg.containsKey('units')) {
        if (cfg['units'] is List<BookChapter>) {
          units
            ..clear()
            ..addAll((cfg['units'] as List<BookChapter>));
        } else if (cfg['units'] is List) {
          units
            ..clear()
            ..addAll((cfg['units'] as List)
                .map((cfg) => BookChapter.fromJson(Json.from(cfg))));
        }
      }

      if (cfg.containsKey('paragraphs')) {
        if (cfg['paragraphs'] is List<BookParagraph>) {
          paragraphs
            ..clear()
            ..addAll((cfg['paragraphs'] as List<BookParagraph>));
        } else if (cfg['paragraphs'] is List<String>) {
          parseLines(cfg['paragraphs'] as List<String>);
        } else if (cfg['paragraphs'] is List) {
          paragraphs
            ..clear()
            ..addAll((cfg['paragraphs'] as List)
                .map((cfg) => BookParagraph.fromJson(Json.from(cfg))));
        }
      }
    }

    return this;
  }

  // endregion

  // region Methods
  BookParagraphGroup? findGroupByParagraph(BookParagraph paragraph) {
    return groups.firstWhere((group) => group.paragraphs.contains(paragraph));
  }

  /// Returns the previous paragraph group's color of the given paragraph
  String? findPreviousColorByParagraph(BookParagraph paragraph) {
    var index = paragraphs.indexOf(paragraph);

    for (int num = index - 1; num >= 0; num--) {
      if (paragraphs[num].color == paragraph.color) continue;
      return paragraphs[num].color;
    }

    return null;
  }

  /// Returns the previous paragraph group's color of the given paragraph
  String? findNextColorByParagraph(BookParagraph paragraph) {
    var index = paragraphs.indexOf(paragraph);

    for (int num = index + 1; num < paragraphs.length; num++) {
      if (paragraphs[num].color == paragraph.color) continue;
      return paragraphs[num].color;
    }

    return null;
  }

  /// Returns a random color for the paragraph that is as distant as possible from its neighbouring paragraphs
  String findRandomColorByParagraph(BookParagraph paragraph) {
    var colorIndex = (BookParagraph.palette.indexOf(paragraph.color) +
        (BookParagraph.palette.length - 2) / 2)
        .round();

    // Cycle through colors, starting with a distant color, until there's no neighbouring color matching the calculated color
    while (findPreviousColorByParagraph(paragraph) == paragraph.color ||
        findNextColorByParagraph(paragraph) == paragraph.color) {
      colorIndex++;
    }

    return BookParagraph
        .palette[colorIndex % (BookParagraph.palette.length - 2)];
  }

  /// Parses the text and imports it into the chapter, splitting different lines into separate paragraphs
  BookChapter parseText(String text) {
    List<String> lines = text.asLines();

    return parseLines(lines, colorize: true);
  }

  /// Parses the list of text and imports it to the chapter as paragraphs, clearing any previous paragraph
  BookChapter parseLines(List<String> text,
      {bool colorize = true, int depth = 0}) {
    paragraphs
      ..clear()
    // Ignore the last two colors of the palette, which are dark background colors
      ..addAll(text.map((text) =>
          BookParagraph(
              text: text,
              color: '')));

    if(colorize){
      colorizeParagraphs();
    }

    return this;
  }

  void colorizeParagraphs(){
    for(int index = 0; index < paragraphs.length; index++ ){
      if(paragraphs[index].text.asWords().length > 10){
        Map<String, Map<String,Color>> revisedColors = BookParagraph.calculateRevisedList(index, paragraphs);
        paragraphs[index].color = BookParagraph.getRandomColor(revisedColors);
      }
    }

    for(int index = 0; index < paragraphs.length; index++ ){
      if(paragraphs[index].text.asWords().length <= 10){
          paragraphs[index].color = BookParagraph.getTitleColor(index, paragraphs);
      }
    }
  }


  /// Resets chapter's study time back to the initial state (unread)
  void resetStudyTime() {
    studyState = StudyState.none;
    lastRead = DateTime(1980);
    repetitions = 0;
  }

  /// Restarts chapter's study time like it was just changed to the current state
  void restartStudyTime() {
    repetitions = 0;
    lastRead = DateTime.now();
  }

// endregion

  /*Subchapters' logic*/
  void addSubchapter(String text) {
    BookChapter subChapter = BookChapter.fromText(
      depth: 1,
      uuid: const Uuid().v4(),
      lines: text.asLines(),
    );

    subChapters.add(subChapter);
  }

  /*End of Subchapters logic*/

  /*Units' logic region*/
  void addUnit(String text) {
    BookChapter unit = BookChapter.fromText(
      depth: 2,
      uuid: const Uuid().v4(),
      lines: text.asLines(),
    );

    units.add(unit);
  }
/*End of units logic region*/
}

enum StudyEligibilityState {
  none(Colors.deepPurpleAccent, 3),
  early(Colors.grey, 2),
  onTime(Colors.lightGreen, 1),
  late(Colors.red, 0);

  final Color color;
  final int precedence;

  const StudyEligibilityState(this.color, this.precedence);

  int compareTo(StudyEligibilityState b) =>
      precedence < b.precedence ? -1 : (precedence > b.precedence ? 1 : 0);
}

enum StudyState {
  none(no: 0,
      min: 0,
      max: 0,
      stars: 0,
      code: 'none'),
  soon(no: 1,
      min: 11,
      max: 40,
      stars: 1,
      code: 'soon'),
  hour(no: 2,
      min: 1,
      max: 3,
      stars: 1,
      code: 'hour'),
  day(no: 3,
      min: 21,
      max: 36,
      stars: 2,
      code: 'day'),
  week(no: 4,
      min: 8,
      max: 11,
      stars: 2,
      code: 'week'),
  twoWeeks(no: 5,
      min: 16,
      max: 19,
      stars: 3,
      code: 'twoWeeks'),
  month(no: 6,
      min: 31,
      max: 36,
      stars: 4,
      code: 'month'),
  quarter(no: 7,
      min: 91,
      max: 98,
      stars: 5,
      code: 'quarter'),
  semester(no: 8,
      min: 181,
      max: 195,
      stars: 5,
      code: 'semester'),
  completed(no: 9,
      min: 0,
      max: 0,
      stars: 5,
      code: 'completed',);

  final int min;
  final int max;
  final int no;
  final int stars;
  final String code;

  const StudyState({required this.no,
    required this.min,
    required this.max,
    required this.stars,
    required this.code});

  static StudyState fromString(String state) {
    switch (state) {
      case 'soon':
        return StudyState.soon;
      case 'hour':
        return StudyState.hour;
      case 'day':
        return StudyState.day;
      case 'week':
        return StudyState.week;
      case 'twoWeeks':
        return StudyState.twoWeeks;
      case 'month':
        return StudyState.month;
      case 'quarter':
        return StudyState.quarter;
      case 'semester':
        return StudyState.semester;
      case 'completed':
        return StudyState.completed;
      case 'none':
      default:
        return StudyState.none;
    }
  }

  StudyState get next {
    switch (this) {
      case StudyState.none:
        return soon;
      case StudyState.soon:
        return hour;
      case StudyState.hour:
        return day;
      case StudyState.day:
        return week;
      case StudyState.week:
        return twoWeeks;
      case StudyState.twoWeeks:
        return month;
      case StudyState.month:
        return quarter;
      case StudyState.quarter:
        return semester;
      case StudyState.semester:
        return completed;
      case StudyState.completed:
        return completed;
    }
  }

  StudyState get previous {
    switch (this) {
      case StudyState.none:
        return none;
      case StudyState.soon:
        return none;
      case StudyState.hour:
        return soon;
      case StudyState.day:
        return hour;
      case StudyState.week:
        return day;
      case StudyState.twoWeeks:
        return week;
      case StudyState.month:
        return twoWeeks;
      case StudyState.quarter:
        return month;
      case StudyState.semester:
        return quarter;
      case StudyState.completed:
        return semester;
    }
  }
}

extension BookChapterExtension on BookChapter {
  String orderOfChapter(Book book) {
    if (depth == 0) {
      if(subChapters.isNotEmpty){
        return '${book.chapters.indexOf(book.chapters.firstWhere((element) => element.uuid == uuid)) + 1}. 1';
      }
      return (book.chapters.indexOf(book.chapters.firstWhere((element) => element.uuid == uuid)) + 1).toString();
    } else if (depth == 1) {
      BookChapter? parentChapter = book.chapters.firstWhereOrNull((
          chapter) => chapter.uuid == parentChapterUuid);
      if (parentChapter == null) return '';

      if(units.isNotEmpty){
        return '${book.chapters.indexOf(parentChapter) + 1}.  ${parentChapter
            .subChapters.indexOf(parentChapter.subChapters.firstWhere((element) => element.uuid == uuid)) + 2} - a';
      }

      return '${book.chapters.indexOf(parentChapter) + 1}.  ${parentChapter
          .subChapters.indexOf(parentChapter.subChapters.firstWhere((element) => element.uuid == uuid)) + 2}';
    } else if (depth == 2) {
      BookChapter? parentChapter = book.chapters.firstWhereOrNull((
          chapter) => chapter.uuid == parentChapterUuid);
      if (parentChapter == null) return '';
      BookChapter? parentSubchapter = parentChapter.subChapters
          .firstWhereOrNull((subchapter) =>
      subchapter.uuid == parentSubchapterUuid);
      if (parentSubchapter == null) return '';
      return '${book.chapters.indexOf(parentChapter) + 1}.  ${parentChapter
          .subChapters.indexOf(parentSubchapter) + 2} - ${String.fromCharCode(parentSubchapter.units.indexOf(parentSubchapter.units.firstWhere((element) => element.uuid == uuid)) + 97 + 1)}';
    }

    return '';
  }

  int getParagraphIndexViaUuid(String uuid){
    return paragraphs.indexOf(paragraphs.firstWhere((element) => element.uuid == uuid));
  }

  int getParagraphIndexViaText(String text, String color){
    return paragraphs.indexOf(paragraphs.firstWhere((element) => element.text.contains(text) && element.color == color));
  }
}
