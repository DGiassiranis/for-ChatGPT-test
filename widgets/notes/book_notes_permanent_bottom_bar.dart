import 'package:flutter/material.dart';
import 'package:notebars/classes/book_note.dart';
import 'package:notebars/classes/book_paragraph.dart';
import 'package:notebars/common/theme_constant.dart';
import 'package:notebars/extensions.dart';
import 'package:notebars/views/book_notes_view.dart';
import 'package:notebars/widgets/common/overlay_with_long_button.dart';
import 'package:popover/popover.dart';

class BookNotesPermanentBottomBar extends StatelessWidget {
  const BookNotesPermanentBottomBar({
    Key? key,
    required this.capital,
    required this.paragraph,
    required this.onToggleCapitalNotes,
    required this.colorMap,
    required this.keywordsLocked,
    required this.noteWordsLocked,
    required this.keywordsCapital,
    required this.noteWordsCapital,
    required this.onKeyButtonLongPress,
    required this.onNoteButtonLongPress,
    required this.onClearSelection,
    required this.onClearSelectionLongPress,
    required this.onAddAsKeywords,
    required this.onAddAsNote,
    required this.onChangeColor,
    required this.onLinkWithPrevious,
    required this.onUnlinkWithPrevious,
    required this.linkedWithPrevious,
    required this.cropActivated,
    required this.onCropTap,
    required this.onCropLongPress,
    required this.onBinPress,
    required this.onBinLongPress,
    required this.binActivated,
    required this.onKeyIconTap,
    required this.onNoteIconTap,
    required this.shiftingStatus, this.finishShiftingMode,
  }) : super(key: key);

  final bool capital;
  final BookParagraph paragraph;
  final Function() onToggleCapitalNotes;
  final Function() onKeyButtonLongPress;
  final Function(BookNote? note, bool capital) onAddAsKeywords;
  final Function(BookNote? note) onAddAsNote;
  final Function() onNoteButtonLongPress;
  final Function() onClearSelection;
  final Function() onClearSelectionLongPress;
  final Function() onKeyIconTap;
  final Function() onNoteIconTap;
  final Function(String color) onChangeColor;
  final BookColorMap colorMap;
  final bool keywordsLocked;
  final bool noteWordsLocked;
  final bool keywordsCapital;
  final bool noteWordsCapital;
  final Function(BookParagraph) onLinkWithPrevious;
  final Function(BookParagraph) onUnlinkWithPrevious;
  final Function() onCropTap;
  final Function() onCropLongPress;
  final Function() onBinPress;
  final Function() onBinLongPress;
  final bool linkedWithPrevious;
  final bool cropActivated;
  final bool binActivated;
  final ShiftingStatus shiftingStatus;
  final Function()? finishShiftingMode;

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          OverlayWithLongButton(
            finishShiftingMode: finishShiftingMode,
            iconData: Icons.palette_outlined,
            onTap: linkedWithPrevious
                ? () {
                    onUnlinkWithPrevious(paragraph);
                  }
                : () {
                    onLinkWithPrevious(paragraph);
                  },
            iconColor: colorMap[BookParagraph.colorTextPrimary],
            direction: PopoverDirection.top,
            tooltip: '',
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
                          color: BookParagraph
                              .colors[color]![BookParagraph.colorBackKeywords],
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
            onLongPress: onCropLongPress,
            child: IconButton(
              onPressed: onCropTap,
              icon: Icon(
                Icons.crop,
                size: cropActivated
                    ? ThemeConstant.enabledIconSize
                    : ThemeConstant.smallIconSize,
                color: colorMap[BookParagraph.colorTextPrimary],
              ),
            ),
          ),
          GestureDetector(
            onLongPress: onBinLongPress,
            child: IconButton(
              icon: Icon(
                binActivated ? Icons.delete : Icons.delete_outline,
                color: colorMap[BookParagraph.colorTextPrimary],
                size: ThemeConstant.smallIconSize,
              ),
              onPressed: onBinPress,
            ),
          ),
          const SizedBox(
            width: 50,
          ),
          GestureDetector(
            onLongPress: onKeyButtonLongPress,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: onKeyIconTap,
              icon: Container(
                margin: const EdgeInsets.all(5.0),
                padding: const EdgeInsets.all(5),
                decoration: keywordsLocked && colorMap[BookParagraph.colorTextPrimary] != null ? BoxDecoration(
                  border: Border.all(
                    color: colorMap[BookParagraph.colorTextPrimary]!,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ) : null,
                child: shiftingStatus == ShiftingStatus.none || shiftingStatus == ShiftingStatus.noteCapital || shiftingStatus == ShiftingStatus.noteLower? Icon(
                  keywordsCapital ? Icons.vpn_key_rounded : Icons.vpn_key_outlined,
                  size: keywordsCapital
                      ? ThemeConstant.enabledIconSize
                      : ThemeConstant.smallIconSize,
                  color: colorMap[BookParagraph.colorTextPrimary],
                ): Icon(
                  shiftingStatus == ShiftingStatus.keyCapital ? Icons.vpn_key_rounded : Icons.vpn_key_outlined,
                  size: shiftingStatus == ShiftingStatus.keyCapital
                      ? ThemeConstant.enabledIconSize
                      : ThemeConstant.smallIconSize,
                  color: colorMap[BookParagraph.colorTextPrimary],
                ),
              ),
            ),
          ),
          GestureDetector(
            onLongPress: onNoteButtonLongPress,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Container(
                margin: const EdgeInsets.all(5.0),
                padding: const EdgeInsets.all(5),
                decoration: noteWordsLocked && colorMap[BookParagraph.colorTextPrimary] != null ? BoxDecoration(
                  border: Border.all(
                    color: colorMap[BookParagraph.colorTextPrimary]!,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ) : null,
                child: shiftingStatus == ShiftingStatus.none || shiftingStatus == ShiftingStatus.keyCapital || shiftingStatus == ShiftingStatus.keyLower ? Icon(
                  noteWordsCapital ? Icons.description : Icons.description_outlined,
                  color: colorMap[BookParagraph.colorTextPrimary],
                  size: noteWordsCapital
                      ? ThemeConstant.enabledIconSize
                      : ThemeConstant.smallIconSize,
                ) : Icon(
                  shiftingStatus == ShiftingStatus.noteCapital ? Icons.description : Icons.description_outlined,
                  color: colorMap[BookParagraph.colorTextPrimary],
                  size: shiftingStatus == ShiftingStatus.noteCapital
                      ? ThemeConstant.enabledIconSize
                      : ThemeConstant.smallIconSize,
                ),
              ),
              onPressed: onNoteIconTap,
            ),
          ),
          GestureDetector(
            onLongPress: onClearSelectionLongPress,
            child: IconButton(
              icon: const Icon(Icons.clear),
              color: colorMap[BookParagraph.colorTextPrimary],
              onPressed: onClearSelection,
            ),
          ),
        ],
      ),
    );
  }
}
