import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:notebars/common/theme_constant.dart';
import 'package:notebars/views/book_notes_view.dart';
import 'dart:math' as math;

class BookNotesViewBar extends StatelessWidget {
  const BookNotesViewBar({
    Key? key,
    required this.expanded,
    required this.expandAll,
    required this.collapseAll,
    required this.collapseAllTillNoteFinished, this.previousChapter, this.nextChapter,
    required this.lockStatus,
    required this.onLockLongPress,
    required this.onLockTap,
    required this.onGearTap,
    required this.onGearLongPress,
    required this.gearRotationMode,
    required this.collapseAction
  }) : super(key: key);

  final bool expanded;
  final Function() expandAll;
  final Function() collapseAll;
  final Function() collapseAllTillNoteFinished;
  final Function()? previousChapter;
  final Function() onLockTap;
  final Function() onLockLongPress;
  final Function() onGearTap;
  final Function() onGearLongPress;
  final Function()? nextChapter;
  final LockStatus lockStatus;
  final GearRotationMode gearRotationMode;
  final CollapseAction collapseAction;

  @override
  Widget build(BuildContext context) {
    return IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onLongPress: onGearLongPress,
              child: Transform.rotate(
                angle: gearRotationMode == GearRotationMode.rotated ? (22 * math.pi) / 180 : 0,
                child: IconButton(
                  onPressed: onGearTap,
                  icon: const Icon(
                    Bootstrap.gear,
                    size: ThemeConstant.smallIconSize,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onLongPress: onLockLongPress,
              child: IconButton(
                onPressed: onLockTap,
                icon: Icon(
                  lockStatus == LockStatus.unlocked ? Icons.tune : Icons.lock_outline,
                  size: ThemeConstant.smallIconSize,
                  color: Colors.white,
                ),
              ),
            ),

            ///go to previous chapter button
            GestureDetector(
              onLongPress: () {},
              child: const IconButton(
                //TODO: previousChapter Goes here;
                onPressed: null,
                icon: Icon(
                  Icons.keyboard_double_arrow_left,
                  size: ThemeConstant.smallIconSize,
                  color: Colors.transparent,
                ),
              ),
            ),
            const SizedBox(
              width: 50,
            ),

            ///go to next chapter button
            GestureDetector(
              onLongPress: () {},
              child: const IconButton(
                //TODO: nextChapter Goes here;
                onPressed: null,
                icon: Icon(
                  Icons.keyboard_double_arrow_right,
                  size: ThemeConstant.smallIconSize,
                  color: Colors.transparent,
                ),
              ),
            ),
            GestureDetector(
              onLongPress: () {},
              child: IconButton(
                onPressed: collapseAllTillNoteFinished,
                icon: Icon(
                  collapseAction == CollapseAction.collapseTillNoNotes ? Icons.file_download_done : Icons.checklist_rtl,
                  size: ThemeConstant.smallIconSize,
                  color: Colors.white,
                ),
              ),
            ),
            ///Collapse&Expand Button
            GestureDetector(
              onLongPress: () {},
              child: IconButton(
                onPressed: expanded ? collapseAll : expandAll,
                icon: Icon(
                  expanded ? Icons.compress : Icons.expand,
                  size: ThemeConstant.smallIconSize,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ));
  }
}
