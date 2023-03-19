

import 'package:flutter/material.dart';
import 'package:notebars/classes/book_note.dart';
import 'package:notebars/classes/book_paragraph.dart';
import 'package:notebars/common/theme_constant.dart';
import 'package:notebars/extensions.dart';

class BookNotesParagraphBottomBar extends StatelessWidget {

  const BookNotesParagraphBottomBar({Key? key, required this.capital, required this.paragraph, required this.onToggleCapitalNotes, required this.colorMap, required this.keywordsLocked, required this.noteWordsLocked, required this.onKeyButtonLongPress, required this.onNoteButtonLongPress, required this.onClearSelection, required this.onClearSelectionLongPress, required this.onAddAsKeywords, required this.onAddAsNote,}) : super(key: key);

  final bool capital;
  final BookParagraph paragraph;
  final Function() onToggleCapitalNotes;
  final Function() onKeyButtonLongPress;
  final Function(BookNote? note, bool capital) onAddAsKeywords;
  final Function(BookNote? note) onAddAsNote;
  final Function() onNoteButtonLongPress;
  final Function() onClearSelection;
  final Function() onClearSelectionLongPress;
  final BookColorMap colorMap;
  final bool keywordsLocked;
  final bool noteWordsLocked;


  @override
  Widget build(BuildContext context) {

    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            color: colorMap[BookParagraph.colorBackKeywords],
            tooltip: 'Merge selected books',
            icon: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: colorMap[BookParagraph.colorTextPrimary],
              ),
              width: ThemeConstant.smallIconSize,
              height: ThemeConstant.smallIconSize,
              alignment: Alignment.center,
              child: Text(
                'σ',
                style: TextStyle(
                  color: colorMap[BookParagraph.colorBackKeywords],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onPressed: () {},
          ),
          IconButton(
            color: colorMap[BookParagraph.colorBackKeywords],
            tooltip: 'Merge selected books',
            icon: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: colorMap[BookParagraph.colorTextPrimary],
              ),
              width: ThemeConstant.smallIconSize,
              height: ThemeConstant.smallIconSize,
              alignment: Alignment.center,
              child: Text(
                'T',
                style: TextStyle(
                  color: colorMap[BookParagraph.colorBackKeywords],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(capital ? Icons.font_download : Icons.font_download_off_outlined, size: ThemeConstant.smallIconSize,),
            color: colorMap[BookParagraph.colorTextPrimary],
            tooltip: 'Change the text case of new notes...',
            onPressed: onToggleCapitalNotes,
          ),
          const SizedBox(width: 50,),
          GestureDetector(
            onLongPress: onKeyButtonLongPress,
            child: IconButton(
              onPressed: () {
                onAddAsKeywords(null, true);
              },
              icon: Icon(
                Icons.vpn_key_outlined,
                size: keywordsLocked ? ThemeConstant.enabledIconSize : ThemeConstant.smallIconSize,
                color: colorMap[BookParagraph.colorTextPrimary],
              ),
            ),
          ),
          GestureDetector(
            onLongPress: onNoteButtonLongPress,
            child: IconButton(
              icon: Icon(
                Icons.description_outlined,
                color: colorMap[BookParagraph.colorTextPrimary],
                size: noteWordsLocked ? ThemeConstant.enabledIconSize : ThemeConstant.smallIconSize,
              ),
              onPressed: () {
                onAddAsNote(null);
              },
            ),
          ),
          GestureDetector(
            onLongPress: onClearSelectionLongPress,
            child: IconButton(
              icon: const Icon(Icons.clear),
              color: colorMap[BookParagraph.colorTextPrimary],
              onPressed: onClearSelection,
            ),
          )
,
        ],
      ),
    );
  }
}
