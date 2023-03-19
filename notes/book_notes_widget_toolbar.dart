/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:notebars/global.dart';

import '../../classes/book_note.dart';
import '../../classes/book_paragraph.dart';
import '../../classes/keyword.dart';
import '../../extensions.dart';

class BookNotesWidgetToolbar extends StatelessWidget {
  final BookParagraph paragraph;
  final BookColorMap colormap;
  final List<Keyword> selectedWords;
  final bool showExpandButton;
  final VoidCallback? onToggleExpanded;
  final VoidCallback? onClearSelection;
  final VoidCallback? onClearSelectionLongPress;
  final VoidCallback? onClearParagraphSelection;
  final VoidCallback? onLinkWithPrevious;
  final VoidCallback? onUnlinkWithPrevious;
  final VoidCallback? onToggleCapitalNotes;
  final Function(String color)? onChangeColor;
  final Function(BookNote? note, bool capital, {bool? longpress})? onAddActionTap;
  final AddAction addAction;
  final bool addActionLock;
  final Function(BookNote? note)? onAddAsNote;

  const BookNotesWidgetToolbar({
    Key? key,
    required this.paragraph,
    required this.colormap,
    this.selectedWords = const [],
    this.showExpandButton = false,
    this.onToggleExpanded,
    this.onClearSelection,
    this.onClearSelectionLongPress,
    this.onClearParagraphSelection,
    this.onLinkWithPrevious,
    this.onUnlinkWithPrevious,
    this.onChangeColor,
    this.onAddActionTap,
    required this.addAction,
    required this.addActionLock,
    this.onAddAsNote,
    this.onToggleCapitalNotes,
  }) : super(key: key);

  bool get capital => app.settings['notesCapital'] ?? true;

  @override
  Widget build(BuildContext context) {
    // const double cBoxSize = 36;
    return const SizedBox();
  }
}

enum AddAction {
  note,
  keyword,
}
