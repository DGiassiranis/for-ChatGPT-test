/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:aneya_json/json.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:notebars/classes/book_paragraph.dart';
import 'package:notebars/global.dart';
import 'package:uuid/uuid.dart';

import '../../../extensions.dart';
import 'keyword.dart';

part 'package:notebars/classes/key_bar_status_enum.dart';

enum NotePhotoSize {
  small(0, heightMultiplier: 1.5, size: Size(200, 200)),
  medium(1, heightMultiplier: 2, size: Size(400, 400)),
  large(2, heightMultiplier: 3, size: Size(600, 600)),
  larger(3, heightMultiplier: 4, size: Size(800, 800));

  final int no;
  final double heightMultiplier;
  final Size size; // max width
  const NotePhotoSize(this.no,
      {required this.heightMultiplier, required this.size});

  static NotePhotoSize fromNo(int no) {
    switch (no) {
      case 1:
        return NotePhotoSize.medium;
      case 2:
        return NotePhotoSize.large;
      case 0:
      default:
        return NotePhotoSize.small;
    }
  }
}

enum NoteNoteBarSize {
  small(0, 1, 16),
  medium(1, 1.4, 18),
  large(2, 1.8, 20);

  final int no;
  final double heightMultiplier;
  final double fontSize;

  const NoteNoteBarSize(
    this.no,
    this.heightMultiplier,
    this.fontSize,
  );

  NoteNoteBarSize get next {
    switch (this) {
      case NoteNoteBarSize.small:
        return NoteNoteBarSize.medium;
      case NoteNoteBarSize.medium:
        return NoteNoteBarSize.large;
      case NoteNoteBarSize.large:
        return NoteNoteBarSize.small;
    }
  }
}

class BookNote {
  // region Properties
  /// A user-defined name for the note
  String name;
  String note;
  String question;
  String answer;
  String imageData;
  NoteNoteBarSize noteBarSize = NoteNoteBarSize.small;
  NotePhotoSize photoSize = NotePhotoSize.small;
  late DateTime created;
  DateTime? modified;
  bool showAnswer = false;
  late String uuid;
  String? fromDotToDot;
  int? startIndex;
  int? endIndex;
  bool hasAsset = false;
  bool isTemporary = false;
  String symbolAssetPath = '';

  int? get noteIndex => _noteIndex;

  set noteIndex(int? index) {
    _noteIndex = index;
  }

  static double get rowHeight => app.settings['noteRowHeight'];

  double get noteHeight =>
      rowHeight *
      ((imageData.isNotEmpty ? photoSize.heightMultiplier : 1) +
          (noteBarSize.heightMultiplier - 1));

  static BookNote get nullNote {
    BookNote currentNullNote = BookNote(
        keywords: [],
        notewords: [],
        uuid: 'null_note',
        paragraphUuid: 'null_note');
    currentNullNote.isTemporary = true;
    return currentNullNote;
  }

  bool get isNullNoteV2 => uuid == 'null_note' || paragraphUuid == 'null_note';

  int nextIndex() {
    return _noteIndex == 2 ? 0 : _noteIndex! + 1;
  }

  int nextOfNextIndex() {
    return nextIndex() == 2 ? 0 : nextIndex() + 1;
  }

  int previousIndex() {
    return _noteIndex == 0 ? 2 : _noteIndex! - 1;
  }

  int? _noteIndex;
  String paragraphUuid = '';
  final SwiperController swiperController = SwiperController();
  final CustomSwiperController transparentController = CustomSwiperController();

  /// Represents a map of words (keys) and their (zero-based) index inside a paragraph text.
  late List<Keyword> keywords;
  late List<Keyword> notewords;

  KeyBarStatus keyBarStatus;

  // endregion

  // region Getters/setters
  bool get hasKeywords => keywords.isNotEmpty;

  bool get hasNotewords => notewords.isNotEmpty && note.isNotEmpty;

  // endregion

  // region Constructors & initialization
  BookNote(
      {required this.keywords,
      required this.notewords,
      this.name = '',
      this.note = '',
      this.question = '',
      this.answer = '',
      this.imageData = '',
      this.fromDotToDot,
      required this.uuid,
      required this.paragraphUuid,
      this.keyBarStatus = KeyBarStatus.key,
      this.noteBarSize = NoteNoteBarSize.small}) {
    created = DateTime.now();
    uuid = const Uuid().v4();
  }

  BookNote.fromWords({
    required this.keywords,
    required this.notewords,
    this.name = '',
    this.note = '',
    this.question = '',
    this.answer = '',
    this.imageData = '',
    this.keyBarStatus = KeyBarStatus.key,
  }) {
    created = DateTime.now();
    uuid = const Uuid().v4();
  }

  factory BookNote.fromJson(Json cfg) => BookNote(
          keywords: [],
          notewords: [],
          uuid: const Uuid().v4(),
          paragraphUuid: '')
      .applyCfg(cfg);

  factory BookNote.fromJsonWithParagraph(Json cfg, BookParagraph paragraph) =>
      BookNote(
              paragraphUuid: '',
              keywords: [],
              notewords: [],
              uuid: const Uuid().v4())
          .applyCfgFromParagraph(cfg, paragraph);

  Json toJson() => {
        'name': name,
        'note': note,
        'created': created.toIso8601String(),
        'modified': modified?.toIso8601String(),
        'question': question,
        'answer': answer,
        'keywords': keywords.toJson(),
        'notewords': notewords.toJson(),
        'imageData': imageData,
        'photoSize': photoSize.no,
        'note_index': noteIndex,
        'has_asset': hasAsset,
        KeyBarStatus.jsonKey: keyBarStatus.code,
        'note_bar_size': noteBarSize.no,
        'symbol_asset_path': symbolAssetPath,
      };

  applyCfg(Json cfg, [bool strict = false]) {
    if (strict == true) {
      name = cfg.getString('name', '');
      note = cfg.getString('note', '');
      question = cfg.getString('question', '');
      answer = cfg.getString('answer', '');
      imageData = cfg.getString('imageData', '');
      photoSize =
          NotePhotoSize.fromNo(cfg.getInt('photoSize', NotePhotoSize.small.no));

      created = cfg.getDateTime('created', DateTime.now());
      modified = cfg.getDateTimeOrNull('modified');

      keywords = cfg.getList<Keyword>('keywords', []);
      notewords = cfg.getList<Keyword>('notewords', []);
    } else {
      name = cfg.getString('name', name);
      note = cfg.getString('note', note);
      question = cfg.getString('question', question);
      answer = cfg.getString('answer', answer);
      imageData = cfg.getString('imageData', imageData);
      photoSize = NotePhotoSize.fromNo(cfg.getInt('photoSize', photoSize.no));

      created = cfg.getDateTime('created', created);
      modified = cfg.getDateTimeOrNull('modified', modified);
    }

    hasAsset = cfg.getBool('has_asset', false);
    keyBarStatus =
        KeyBarStatus.getStatusFromCode(cfg.getString(KeyBarStatus.jsonKey, ''));
    symbolAssetPath = cfg.getString('symbol_asset_path', '');
    noteBarSize = NoteNoteBarSize.values
            .firstWhereOrNull((s) => s.no == cfg.getInt('note_bar_size', 0)) ??
        NoteNoteBarSize.small;
    if (cfg.containsKey('keywords')) {
      if (cfg['keywords'] is List) {
        List<Keyword> list = List<Keyword>.from(cfg['keywords'].map((e) {
          var m = Map<String, dynamic>.from(e);
          return Keyword(m['word'] as String, m['pos'] as int, m['normal_case'],
              capital: m['capital'] ?? false);
        }).toList());

        keywords
          ..clear()
          ..addAll(list);
      }
    }

    if (cfg.containsKey('notewords')) {
      if (cfg['notewords'] is List) {
        List<Keyword> list = List<Keyword>.from(cfg['notewords'].map((e) {
          var m = Map<String, dynamic>.from(e);
          return Keyword(m['word'] as String, m['pos'] as int, m['normal_case'],
              capital: m['capital'] ?? false);
        }).toList());

        notewords
          ..clear()
          ..addAll(list);
      }
    }

    return this;
  }

  applyCfgFromParagraph(Json cfg, BookParagraph paragraph) {
    paragraphUuid = paragraph.uuid;
    name = cfg.getString('name', name);
    note = cfg.getString('note', note);
    question = cfg.getString('question', question);
    answer = cfg.getString('answer', answer);
    imageData = cfg.getString('imageData', imageData);
    hasAsset = cfg.getBool('has_asset', false);
    noteBarSize = NoteNoteBarSize.values
            .firstWhereOrNull((s) => s.no == cfg.getInt('note_bar_size', 0)) ??
        NoteNoteBarSize.small;
    symbolAssetPath = cfg.getString('symbol_asset_path', '');

    photoSize = NotePhotoSize.fromNo(cfg.getInt('photoSize', photoSize.no));
    noteIndex = cfg.getInt('note_index', 2);
    keyBarStatus =
        KeyBarStatus.getStatusFromCode(cfg.getString(KeyBarStatus.jsonKey, ''));
    created = cfg.getDateTime('created', created);
    modified = cfg.getDateTimeOrNull('modified', modified);
    if (cfg.containsKey('keywords')) {
      if (cfg['keywords'] is List) {
        List<Keyword> list = List<Keyword>.from(cfg['keywords'].map((e) {
          var m = Map<String, dynamic>.from(e);
          return Keyword(m['word'] as String, m['pos'] as int, m['normal_case'],
              capital: m['capital'] ?? false);
        }).toList());

        keywords
          ..clear()
          ..addAll(list);
      }
    }

    if (cfg.containsKey('notewords')) {
      if (cfg['notewords'] is List) {
        List<Keyword> list = List<Keyword>.from(cfg['notewords'].map((e) {
          var m = Map<String, dynamic>.from(e);
          return Keyword(m['word'] as String, m['pos'] as int, m['normal_case'],
              capital: m['capital'] ?? false);
        }).toList());

        notewords
          ..clear()
          ..addAll(list);
      }
    }
    calculateStartAndEndIndex(paragraph);
    return this;
  }

  void onIndexChanged(int index) {}

  void calculateStartAndEndIndex(BookParagraph paragraph) {
    ///find min max
    //Student studentWithMinMarks = students.reduce((a, b) => a.Marks < b.Marks ? a : b);
    Keyword? maxNote = notewords.isNotEmpty
        ? notewords.reduce(
            (value, element) => value.pos > element.pos ? value : element)
        : null;
    Keyword? maxKeyword = keywords.isNotEmpty
        ? keywords.reduce(
            (value, element) => value.pos > element.pos ? value : element)
        : null;
    Keyword? minNote = notewords.isNotEmpty
        ? notewords.reduce(
            (value, element) => value.pos < element.pos ? value : element)
        : null;
    Keyword? minKeyword = keywords.isNotEmpty
        ? keywords.reduce(
            (value, element) => value.pos < element.pos ? value : element)
        : null;

    ///decide which [Keyword] has the minimum position
    int? minPosition;
    if (minNote != null || minKeyword != null) {
      if (minKeyword != null && (minNote != null)) {
        minPosition =
            minKeyword.pos < minNote.pos ? minKeyword.pos : minNote.pos;
      } else if (minKeyword == null) {
        minPosition = minNote!.pos;
      } else {
        minPosition = minKeyword.pos;
      }
    }

    ///decide which [Keyword] has the maximum position
    int? maxPosition;
    if (maxNote != null || maxKeyword != null) {
      if (maxKeyword != null && (maxNote != null)) {
        maxPosition =
            maxKeyword.pos > maxNote.pos ? maxKeyword.pos : maxNote.pos;
      } else if (maxKeyword == null) {
        maxPosition = maxNote!.pos;
      } else {
        maxPosition = maxKeyword.pos;
      }
    }

    ///find the starting and ending indexes;
    int? startingIndex = minPosition;
    int? endingIndex = maxPosition;
    if (minPosition != null && maxPosition != null) {
      startingIndex = findStarting(minPosition, paragraph.text.asWords());
      endingIndex = findEnding(maxPosition, paragraph.text.asWords());
    } else if (minPosition != null) {
      startingIndex = findStarting(minPosition, paragraph.text.asWords());
      endingIndex = findEnding(minPosition, paragraph.text.asWords());
    } else if (maxPosition != null) {
      startingIndex = findStarting(maxPosition, paragraph.text.asWords());
      endingIndex = findEnding(maxPosition, paragraph.text.asWords());
    }

    startingIndex ??= 0;
    endingIndex ??= paragraph.text.asWords().length;

    fromDotToDot =
        paragraph.text.asWords().sublist(startingIndex, endingIndex).join(' ');
    startIndex = startingIndex;
    endIndex = endingIndex;
  }

  int? findStarting(int minIndex, List<String> words) {
    for (int index = minIndex - 1; index >= 0; index--) {
      if (words.elementAt(index).containsEndOfSentenceSymbol) {
        return index + 1;
      }
    }
    return null;
  }

  int? findEnding(int maxIndex, List<String> words) {
    for (int index = maxIndex; index < words.length; index++) {
      if (words.elementAt(index).containsEndOfSentenceSymbol) {
        return index + 1;
      }
    }
    return null;
  }

  bool isNullNote() {
    return name.isEmpty &&
        note.isEmpty &&
        imageData.isEmpty &&
        notewords.isEmpty &&
        keywords.isEmpty;
  }

// endregion
}

class CustomSwiperController extends SwiperController {
  bool isBlocked = false;
}
