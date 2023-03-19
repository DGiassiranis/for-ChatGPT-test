// /// -----------------------------------------------------------------------
// ///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
// ///
// /// This file is subject to the terms and conditions defined in
// /// file 'LICENSE.txt', which is part of this source code package.
// /// -----------------------------------------------------------------------
// import 'package:flutter/material.dart';
//
// import '../../classes/book_paragraph.dart';
// import 'book_notes_widget_row.dart';
//
// class BookNotesWidgetAppBar extends StatelessWidget {
//   // region Properties
//   final BookParagraph paragraph;
//   // endregion
//   final bool hasSelectedWords;
//
//   const BookNotesWidgetAppBar({
//     Key? key,
//     required this.paragraph,
//     this.hasSelectedWords = false,
//   }) : super(key: key);
//
//   static double height(BookParagraph paragraph) {
//     return BookNotesWidgetRow.rowHeight * (paragraph.notes.length < 2 ? paragraph.notes.length : 2);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.max,
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         if (paragraph.notes.isNotEmpty)
//           Container(
//             constraints: const BoxConstraints(minHeight: 20),
//             width: MediaQuery.of(context).size.width,
//             height: BookNotesWidgetAppBar.height(paragraph),
//             child: BookNotesWidgetRow(
//               hasSelectedWords: hasSelectedWords,
//               paragraphs: [paragraph],
//               customNotes: paragraph.notes.length > 2 ? paragraph.notes.sublist(paragraph.notes.length - 2) : paragraph.notes,
//               activeParagraph: paragraph,
//               mode: BookNotesRenderMode.notes,
//               colormap: BookParagraph.colors[paragraph.color] ?? BookParagraph.colors['app']!,
//               activeNote: null,
//               explicitHeight: BookNotesWidgetRow.rowHeight,
//             ),
//           ),
//       ],
//     );
//   }
// }
