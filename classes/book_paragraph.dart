/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'dart:ui';

import 'package:aneya_core/core.dart';
import 'package:aneya_json/json.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart' as material;
import 'package:notebars/extensions.dart';
import 'package:uuid/uuid.dart';

import '../../../global.dart';
import 'book_note.dart';
import 'keyword.dart';

class BookParagraph {
  // region Constants
  static const String colorBackKeywords = 'b1';
  static const String colorBackNotes = 'b2';
  static const String colorBackParagraph = 'b3';
  static const String colorTextPrimary = 't1';
  static const String colorTextSecondary = 't2';
  static const String colorKeyBackground = 'b4';

  static const colorNamePurple = 'purple';
  static const colorNameRed = 'red';
  static const colorNameGreen = 'green';
  static const colorNameBlue = 'blue';
  static const colorNameYellow = 'yellow';
  static const colorNamePink = 'pink';
  static const colorNameKhaki = 'khaki';
  static const colorNameLime = 'lime';
  static const colorNameOrange = 'orange';
  static const colorNameTurquoise = 'turquoise';
  static const colorNameGrey = 'grey';
  static const colorNameOcean = 'ocean';
  static const colorNameBrown = 'brown';
  static const colorNameApp = 'app';
  static const colorNameDarkPurple = 'darkPurple';
  static const colorNameDarkGreen = 'darkGreen';
  static const colorNameDarkRed = 'darkRed';
  static const colorNameDarkKhaki = 'darkKhaki';
  static const colorNameDarkTurquoise = 'darkTurquoise';

  static material.TextStyle get titleTextStyle => const material.TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18
  );

  static material.TextStyle paragraphTextStyle(bool large, bool bold, bool italic){
    return material.TextStyle(
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      fontWeight: bold? FontWeight.bold : FontWeight.normal,
      fontSize: large ? 18 : null,
    );
  }

  static const Map<String, BookColorMap> colors = {
    colorNamePurple: purple,
    colorNameRed: red,
    colorNameGreen: green,
    colorNameBlue: blue,
    colorNameYellow: yellow,
    colorNamePink: pink,
    colorNameKhaki: khaki,
    colorNameLime: lime,
    colorNameOrange: orange,
    colorNameTurquoise: turquoise,
    colorNameGrey: grey,
    colorNameOcean: ocean,
    colorNameBrown: brown,
    colorNameApp: ui,
    colorNameDarkPurple: darkPurple,
    colorNameDarkGreen: darkGreen,
    colorNameDarkRed: darkRed,
    colorNameDarkKhaki: darkKhaki,
    colorNameDarkTurquoise: darkTurquoise,
  };

  static const BookColorMap purple = {
    'b1': Color(0xffeee1ff),
    'b2': Color(0xfff1f1ff),
    'b3': Color(0xfffdf7ff),
    colorKeyBackground: Color(0xffDEC5FF),
    't1': Color(0xff7b03b3),
    't2': Color(0xff7b03b3),
  };
  static const BookColorMap red = {
    'b1': Color(0xffffe1e1),
    'b2': Color(0xfffff1f1),
    'b3': Color(0xfffff7f7),
    colorKeyBackground: Color(0xffFFC9C9),
    't1': Color(0xffb60000),
    't2': Color(0xffb60000),
  };
  static const BookColorMap green = {
    'b1': Color(0xffb7e4c7),
    'b2': Color(0xffd7f3dc),
    'b3': Color(0xfff3fbf4),
    colorKeyBackground: Color(0xff9BD9B1),
    't1': Color(0xff008000),
    't2': Color(0xff008000),
  };
  static const BookColorMap blue = {
    'b1': Color(0xffb9e4ff),
    'b2': Color(0xffddf2ff),
    'b3': Color(0xffedfbfd),
    colorKeyBackground: Color(0xff8FD3F1),
    't1': Color(0xff0070c0),
    't2': Color(0xff0070c0),
  };
  static const BookColorMap yellow = {
    'b1': Color(0xfff9ffab),
    'b2': Color(0xfffbffcd),
    'b3': Color(0xfffefff7),
    colorKeyBackground: Color(0xfffdf65c),
    't1': Color(0xff8c8901),
    't2': Color(0xff8c8901),
  };
  static const BookColorMap pink = {
    'b1': Color(0xffffd5fa),
    'b2': Color(0xffffe7fd),
    'b3': Color(0xfffff7ff),
    colorKeyBackground: Color(0xffFFB9F7),
    't1': Color(0xffd000b7),
    't2': Color(0xffd000b7),
  };
  static const BookColorMap khaki = {
    'b1': Color(0xffdbe6b8),
    'b2': Color(0xffecf2da),
    'b3': Color(0xfff6f9ed),
    colorKeyBackground: Color(0xffCEDD9F),
    't1': Color(0xff615f35),
    't2': Color(0xff615f35),
  };
  static const BookColorMap lime = {
    'b1': Color(0xffc8ffb9),
    'b2': Color(0xffe4ffdd),
    'b3': Color(0xfff2ffef),
    colorKeyBackground: Color(0xff9FFF85),
    't1': Color(0xff1f9200),
    't2': Color(0xff1f9200),
  };
  static const BookColorMap orange = {
    'b1': Color(0xfff3d4b5),
    'b2': Color(0xffffedd9),
    'b3': Color(0xfffff7ef),
    colorKeyBackground: Color(0xffEDBE8F),
    't1': Color(0xff884502),
    't2': Color(0xff884502),
  };
  static const BookColorMap turquoise = {
    'b1': Color(0xffc1feff),
    'b2': Color(0xffe1fbff),
    'b3': Color(0xfff7feff),
    colorKeyBackground: Color(0xff9CF9FE),
    't1': Color(0xff007e69),
    't2': Color(0xff007e69),
  };
  static const BookColorMap grey = {
    'b1': Color(0xffd1ddeb),
    'b2': Color(0xffeaeff6),
    'b3': Color(0xfff4f6fa),
    colorKeyBackground: Color(0xffBFCFE3),
    't1': Color(0xff426998),
    't2': Color(0xff426998),
  };

  ///It is classified as dark color
  static const BookColorMap ocean = {
    'b1': Color(0xff203864),
    'b2': Color(0xff203864),
    // 'b2': Color(0xff2f5597),
    'b3': Color(0xffe2e9f6),
    colorKeyBackground: Color(0xff203864),
    't1': Color(0xffe2e9f6),
    't2': Color(0xff3762af),
  };

  ///It is classified as dark color
  static const BookColorMap brown = {
    'b1': Color(0xff843c0c),
    'b2': Color(0xff843c0c),
    'b3': Color(0xfffbe5d6),
    colorKeyBackground: Color(0xff843c0c),
    't1': Color(0xfffbe5d6),
    't2': Color(0xffed7d31),
  };


  static const BookColorMap ui = {
    'b1': material.Colors.deepPurpleAccent,
    'b2': Color(0xff875cff),
    'b3': Color(0xffedfbfd),
    't1': material.Colors.white,
    't2': Color(0xffedfbfd),
  };
  static const BookColorMap darkPurple = {
    'b1': Color(0xff551e66),
    'b2': Color(0xff551e66),
    // 'b2': Color(0xff8c32a8),
    'b3': Color(0xfff1dfee),
    colorKeyBackground: Color(0xff551e66),
    't1': Color(0xfffacef8),
    't2': Color(0xff551e66),
  };
  static const BookColorMap darkGreen = {
    'b1': Color(0xff16561e),
    'b2': Color(0xff16561e),
    // 'b2': Color(0xff269233),
    'b3': Color(0xffd1f3d5),
    colorKeyBackground: Color(0xff16561e),
    't1': Color(0xffcafecf),
    't2': Color(0xff16561e),
  };
  static const BookColorMap darkRed = {
    'b1': Color(0xff8c0606),
    'b2': Color(0xff8c0606),
    // 'b2': Color(0xffe80a0a),
    'b3': Color(0xffffe1e1),
    colorKeyBackground: Color(0xff8c0606),
    't1': Color(0xffffdddd),
    't2': Color(0xff8c0606),
  };

  static const BookColorMap darkKhaki = {
    'b1': Color(0xff7e7b00),
    'b2': Color(0xff7e7b00),
    // 'b2': Color(0xffa4a000),
    'b3': Color(0xfff1fAc6),
    colorKeyBackground: Color(0xff7e7b00),
    't1': Color(0xfffaffbd),
    't2': Color(0xff7e7b00),
  };

  static const BookColorMap darkTurquoise = {
    'b1': Color(0xff00809a),
    'b2': Color(0xff00809a),
    'b3': Color(0xffb0eafe),
    colorKeyBackground: Color(0xff00809a),
    't1': Color(0xffc1feff),
    't2': Color(0xff00809a),
  };



  static const Map<String, Map<String, Color>> lightColors = {
    colorNamePurple: purple,
    colorNameRed: red,
    colorNameGreen: green,
    colorNameBlue: blue,
    colorNameYellow: yellow,
    colorNamePink: pink,
    colorNameKhaki: khaki,
    colorNameLime: lime,
    colorNameOrange: orange,
    colorNameTurquoise: turquoise,
    colorNameGrey: grey,
  };

  static const Map<String, Map<String, Color>> darkColors = {
    colorNameOcean: ocean,
    colorNameBrown: brown,
    colorNameDarkPurple: darkPurple,
    colorNameDarkGreen: darkGreen,
    colorNameDarkRed: darkRed,
    colorNameDarkKhaki: darkKhaki,
    colorNameDarkTurquoise: darkTurquoise,
  };

  static const Map<String, List<String>> matchedColors = {
    colorNamePurple: [colorNameDarkPurple],
    colorNameRed: [colorNameDarkRed,],
    colorNameGreen: [colorNameDarkGreen],
    colorNameBlue: [colorNameOcean],
    colorNameYellow: [colorNameDarkKhaki],
    colorNamePink: [colorNameDarkPurple],
    colorNameKhaki: [colorNameDarkKhaki],
    colorNameLime: [colorNameDarkGreen],
    colorNameOrange: [colorNameBrown,],
    colorNameTurquoise: [colorNameDarkTurquoise],
    colorNameGrey: [colorNameOcean],
  };

  static const Map<String, List<String>> matchedLightColors = {
    colorNameOcean: [colorNameBlue, colorNameOcean],
    colorNameBrown: [colorNameOrange,],
    colorNameDarkPurple: [colorNamePurple, colorNamePink],
    colorNameDarkGreen: [colorNameGreen, colorNameLime],
    colorNameDarkRed: [colorNameRed],
    colorNameDarkKhaki: [colorNameYellow, colorNameKhaki],
    colorNameDarkTurquoise: [colorNameTurquoise],
  };

  static const Map<String, List<String>> similarColors = {
    colorNamePurple: [colorNamePink],
    colorNamePink: [colorNamePurple],
    colorNameBlue: [colorNameTurquoise],
    colorNameTurquoise: [colorNameBlue],
    colorNameGreen: [colorNameLime],
    colorNameLime: [colorNameGreen],
  };
  // endregion

  ///Region of static algorithms
  static String getRandomColor(Map<String, Map<String,Color>> revisedList){
    return revisedList.keys.toList().random();
  }

  static Map<String, Map<String,Color>> calculateRevisedList(int paragraphIndex, List<BookParagraph> paragraphs, {bool afterLink = false}){

    List<BookParagraph> newParagraphs = [];
    newParagraphs = paragraphs.where((element) => element.text.asWords().length > 10 || element == paragraphs[paragraphIndex] || lightColors.containsKey(element.color)).toList();

    int newParagraphIndex = newParagraphs.indexOf(paragraphs[paragraphIndex]);

    return calculateRevisedListV2(newParagraphIndex, newParagraphs);

  }

  static String getColorAfterUnlink(int paragraphIndex, List<BookParagraph> paragraphs){
    BookParagraph? previous = paragraphs.previous(paragraphIndex);

    if(previous != null){
      if((matchedLightColors[previous.color] ?? []).isNotEmpty){
        return (matchedLightColors[previous.color] ?? []).random();
      }
    }

    return getRandomColor(calculateRevisedList(paragraphIndex, paragraphs));
  }

  static Map<String, Map<String,Color>> calculateRevisedListV2(int paragraphIndex,List<BookParagraph> paragraphs){
    Map<String, Map<String,Color>> revisedColors = Map.from(lightColors);

    int iterates = 0;
    int previousIndex = paragraphIndex;
    int nextIndex = paragraphIndex;
    bool seeNextFlag = true;
    bool hasPreviousFlag = true;
    bool hasNextFlag = true;

    while(true){
      if(iterates == 16) break;
      if(revisedColors.length == 1) break;
      if(!hasPreviousFlag && !hasNextFlag) break;

      if(seeNextFlag && hasNextFlag){
        BookParagraph? next = paragraphs.next(nextIndex);
        nextIndex ++;
        if(next!=null){
          revisedColors.remove(next.color);
          if(similarColors[next.color] != null){
            for(String color in similarColors[next.color]!){
              if(revisedColors.length == 1) continue;
              revisedColors.remove(color);
            }
          }
        }else{
          hasNextFlag = false;
        }
      }else if (hasPreviousFlag){

        BookParagraph? previous = paragraphs.previous(previousIndex);
        previousIndex -= 1;
        if(previous != null){
          revisedColors.remove(previous.color);
          if(similarColors[previous.color] != null){
            for(String color in similarColors[previous.color]!){
              if(revisedColors.length == 1) continue;
              revisedColors.remove(color);
            }
          }
        }else{
          hasPreviousFlag = false;
        }
      }

      seeNextFlag = !seeNextFlag;
      iterates ++;
    }


    return revisedColors;
  }

  bool hasSameFormat(BookParagraph otherParagraph) => isTitle == otherParagraph.isTitle && isItalic == otherParagraph.isItalic && isBold == otherParagraph.isBold && hasBackground == otherParagraph.hasBackground;

  bool get isJustItalic => isItalic && !isBold && !isLarge;

  int get countOfDots => '.'.allMatches(text).length;

  static String getTitleColor(int paragraphIndex, List<BookParagraph> paragraphs,){
    if(paragraphIndex != 0){
      if(paragraphs[paragraphIndex - 1].text.asWords().length < 10 || (paragraphs[paragraphIndex].countOfDots < 2 && !paragraphs[paragraphIndex].isTitle && !paragraphs[paragraphIndex].isLarge)){
        return paragraphs[paragraphIndex - 1].color;
      }
    }
    String returnedColor = darkColors.keys.toList().random();

    BookParagraph? actualParagraph = paragraphs.firstWhereOrNull((element) => element.text.asWords().length > 10 && paragraphs.indexOf(element) > paragraphIndex);

    if(actualParagraph?.color == null) return returnedColor;

    return actualParagraph == null || actualParagraph.color.isEmpty ? returnedColor : matchedColors[actualParagraph.color]!.random();
  }

  ///endRegion of static algorithms

  // region Properties
  String text;
  String color;
  late String uuid;
  late List<BookNote> notes;
  late Json uiOptions;
  final SwiperController swiperController = SwiperController();

  static String _lastColor = '';
  // endregion

  //functionality;

  int? cropUntilIndex;
  bool hasBackground = false;
  bool isTitle = false;
  bool isBold = false;
  bool isLarge = false;
  bool isItalic = false;
  bool hasAppliedStyling = false;

  //end of functionality;


  // region Getters/setters
  static List<String> get palette => colors.keys.where((c) => c != 'app').toList();
  static TextAlign get textAlign => app.settings['textAlign'] == 'justify' ? TextAlign.justify : TextAlign.left;
  // endregion

  // region Constructors & initialization
  BookParagraph({this.text = '', this.color = '',}) {
    notes = [];
    uiOptions = {'selected': false, 'expanded': true, 'notesIndex': 2};
    uuid = const Uuid().v4();
    // Group all paragraphs with the same color, by default
    // if (color.isEmpty) color = 'purple';
  }

  bool get isExpanded => uiOptions["expanded"] ?? false;

  static Map<String, int> keptIndexes = {};

  int revisedIndex = 0;

  factory BookParagraph.fromJson(Json cfg) => BookParagraph().applyCfg(cfg);
  factory BookParagraph.fromText({required String text}) => BookParagraph()..text = text;

  Json toJson() {
    notes.removeWhere((n) => n.isNullNoteV2 || n.isTemporary);
    return {
        'text': text,
        'color': color,
        'uiOptions': {'selected': uiOptions['selected'], 'expanded': uiOptions['expanded'], 'notesIndex': uiOptions['notesIndex']},
        'notes': notes.map((note) => note.toJson()).toList(),
        'has_background': hasBackground,
        'is_title': isTitle,
        'is_large': isLarge,
        'is_bold': isBold,
        'is_italic' : isItalic,
        'has_applied_styling' : hasAppliedStyling,
      };
  }

  bool containsActualNotes(){
    return notes.where((n) => !n.isNullNoteV2).isNotEmpty;
  }

  bool isTitleParagraph() {
    return text.asWords().length <= 10;
  }

  applyCfg(Json cfg, [bool strict = false]) {
    isTitle = cfg.getBool('is_title', false);
    isLarge = cfg.getBool('is_large', false);
    isBold = cfg.getBool('is_bold', false);
    isItalic = cfg.getBool('is_italic', false);
    hasBackground = cfg.getBool('has_background', false);
    hasAppliedStyling = cfg.getBool('has_applied_styling', false);
    if (strict == true) {
      text = cfg.getString('text', '');
      color = cfg.getString('color', '');

      if (cfg.containsKey('notes')) {
        if (cfg['notes'] is List<BookNote>) {
          notes
            ..clear()
            ..addAll((cfg['notes'] as List<BookNote>));
        } else if (cfg['notes'] is List) {
          notes
            ..clear()
            ..addAll((cfg['notes'] as List).map((cfg) => BookNote.fromJsonWithParagraph(Json.from(cfg), this)));
        } else {
          notes.clear();
        }
      } else {
        notes.clear();
      }

      if (cfg.containsKey('uiOptions') && cfg['uiOptions'] is Map) {
        uiOptions = {
          'selected': cfg.containsKey('selected') && cfg['selected'] is bool ? cfg['selected'] : false,
          'expanded': cfg.containsKey('expanded') && cfg['expanded'] is bool ? cfg['expanded'] : true,
          'notesIndex': cfg.containsKey('notesIndex') && cfg['notesIndex'] is int ? cfg['notesIndex'] : 2
        };
      } else {
        uiOptions = {'selected': false, 'expanded': true, 'notesIndex': 2};
      }
    } else {
      text = cfg.getString('text', text);
      color = cfg.getString('color', color);
      if (cfg.containsKey('notes')) {
        if (cfg['notes'] is List<BookNote>) {
          notes
            ..clear()
            ..addAll((cfg['notes'] as List<BookNote>));
        } else if (cfg['notes'] is List) {
          notes
            ..clear()
            ..addAll((cfg['notes'] as List).map((cfg) => BookNote.fromJsonWithParagraph(Json.from(cfg), this)));
        }
      }
    }
    if (cfg.containsKey('uiOptions') && cfg['uiOptions'] is Map) {
      if (cfg['uiOptions'].containsKey('selected') && cfg['uiOptions']['selected'] is bool) uiOptions['selected'] = cfg['uiOptions']['selected'];
      if (cfg['uiOptions'].containsKey('expanded') && cfg['uiOptions']['expanded'] is bool) uiOptions['expanded'] = cfg['uiOptions']['expanded'];
      if (cfg['uiOptions'].containsKey('notesIndex') && cfg['uiOptions']['notesIndex'] is int) uiOptions['notesIndex'] = cfg['uiOptions']['notesIndex'];
    }

    return this;
  }
  // endregion

  // region Methods
  BookNote addNote(List<Keyword> keywords, {String name = '', String note = ''}) {
    if (name.isEmpty) name = keywords.words.join(' ');

    var bookNote = BookNote.fromWords(keywords: keywords, notewords: [], name: name, note: note);
    notes.add(bookNote);

    return bookNote;
  }
  // endregion

  // region Static methods
  static String randomColor({String exclude = ''}) => _lastColor = (palette.toList()..remove(exclude.isNotEmpty ? exclude : _lastColor)).random();
  // endregion

  static List<BookParagraph> fromListString(List<String> lines, {bool colorize = false}) {
    int idx = 0;
    // Ignore the last two colors of the palette, which are dark background colors
    return lines.map((text) => BookParagraph(text: text, color: colorize ? BookParagraph.palette[idx++ % (BookParagraph.palette.length - 2)] : '')).toList();
  }
}
