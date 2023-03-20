

import 'package:flutter/material.dart';
import 'package:notebars/classes/book_paragraph.dart';
import 'package:notebars/common/theme_constant.dart';
import 'package:notebars/extensions.dart';
import 'package:notebars/widgets/common/overlay_button.dart';
import 'package:popover/popover.dart';

class BookNotesSelectedParagraphBottom extends StatelessWidget {

  const BookNotesSelectedParagraphBottom({Key? key, required this.linkedWithPrevious, required this.binActivated, required this.paragraph, required this.onBinPress, required this.onLinkWithPrevious, required this.onUnlinkWithPrevious, required this.onClearSelection, required this.onClearSelectionLongPress, required this.colorMap, required this.onChangeColor,}) : super(key: key);

  final bool linkedWithPrevious;
  final bool binActivated;
  final BookParagraph paragraph;
  final Function() onBinPress;
  final Function() onClearSelection;
  final Function() onClearSelectionLongPress;
  final Function(String color) onChangeColor;
  final Function(BookParagraph) onLinkWithPrevious;
  final Function(BookParagraph) onUnlinkWithPrevious;
  final BookColorMap colorMap;


  @override
  Widget build(BuildContext context) {

    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          OverlayButton(
            tooltip: 'Change color...',
            icon: Icon(Icons.palette_outlined, color: colorMap[BookParagraph.colorTextPrimary]),
            direction: PopoverDirection.top,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Wrap(
                children: BookParagraph.palette
                    .map(
                      (color) => InkWell(
                    onTap: () {
                      onChangeColor(color);
                    },
                    child: Container(
                      color: BookParagraph.colors[color]![BookParagraph.colorBackKeywords],
                      width: ThemeConstant.colorBoxSize,
                      height: ThemeConstant.colorBoxSize,
                      margin: const EdgeInsets.all(4),
                    ),
                  ),
                )
                    .toList(),
              ),
            ),
          ),
          GestureDetector(
            onLongPress: () {},
            child: IconButton(
              onPressed: linkedWithPrevious ? () {
                onUnlinkWithPrevious(paragraph);
              } :  () {
                onLinkWithPrevious(paragraph);
              },
              icon: Icon(linkedWithPrevious ? Icons.link_off : Icons.link, size: ThemeConstant.smallIconSize, color: colorMap[BookParagraph.colorTextPrimary],),
            ),
          ),
          GestureDetector(
            onLongPress: () {},
            child: IconButton(
              onPressed: null,
              icon: Icon(Icons.crop, size: ThemeConstant.smallIconSize, color: colorMap[BookParagraph.colorTextPrimary],),
            ),
          ),
          // const Spacer(),
          const SizedBox(width: 50,),
          // SizedBox(),
          GestureDetector(
            onLongPress: () {},
            child: IconButton(
              onPressed: null,
              icon: Icon(Icons.visibility, size: ThemeConstant.smallIconSize, color: colorMap[BookParagraph.colorTextPrimary],),
            ),
          ),
          GestureDetector(
            onLongPress: () {},
            child: IconButton(
              icon: Icon(
                Icons.delete,
                color: colorMap[BookParagraph.colorTextPrimary],
                size: binActivated ? ThemeConstant.enabledIconSize : ThemeConstant.smallIconSize,
              ),
              onPressed: onBinPress,
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
