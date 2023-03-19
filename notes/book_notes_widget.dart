// /// -----------------------------------------------------------------------
// ///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
// ///
// /// This file is subject to the terms and conditions defined in
// /// file 'LICENSE.txt', which is part of this source code package.
// /// -----------------------------------------------------------------------
// import 'package:card_swiper/card_swiper.dart';
// import 'package:flutter/material.dart';
//
// import '../../classes/book_note.dart';
// import '../../classes/book_paragraph.dart';
// import '../../classes/keyword.dart';
// import '../../extensions.dart';
// import 'book_notes_widget_row.dart';
// import 'book_notes_widget_toolbar.dart';
//
// class BookNotesWidget extends StatelessWidget {
//   // region Properties
//   final BookParagraphGroup paragraphs;
//   final BookParagraph? activeParagraph;
//   final BookNote? activeNote;
//   final int initialPage;
//   final bool active;
//   final List<Keyword> selectedWords;
//   final Function(BookParagraph)? onParagraphTap;
//   final Function(BookParagraph)? onParagraphDoubleTap;
//   final Function(BookParagraph)? onParagraphLongPress;
//   final Function(BookParagraph, String, int)? onWordTap;
//   final Function(BookParagraph, String, int)? onWordDoubleTap;
//   final Function(BookParagraph, String, int)? onWordLongPress;
//   final Function()? onToggleExpanded;
//   final Function()? onToggleCapitalNotes;
//   final Function()? onClearSelection;
//   final Function()? onClearSelectionLongPress;
//   final Function()? onClearParagraphSelection;
//   final Function(BookNote)? onNoteLongPress;
//   final Function(BookNote)? onNoteDoubleTap;
//   final Function(BookNote)? onNoteTap;
//   final Function(BookNote)? onKeywordsTap;
//   final Function(BookParagraph)? onLinkWithPrevious;
//   final Function(BookParagraph)? onUnlinkWithPrevious;
//   final Function(BookParagraph, String)? onChangeColor;
//   final Function(BookNote? note, bool? capital, {bool? longpress})? onAddActionTap;
//   final Function(BookNote? note, bool? capital)? onAddAsKeywords;
//   final AddAction addAction;
//   final bool addActionLock;
//   final Function(BookNote? note)? onAddAsNote;
//   final Function(BookNote note)? onAddQuestion;
//   final Function(BookNote note)? onPhotoTap;
//   final Function(BookNote note, bool)? onPhotoSizeTap;
//   final Function(BookNote note)? onShowAnswer;
//   final Function(int)? onNotesIndexChanged;
//   final bool hasSelectedWords;
//   // endregion
//
//   const BookNotesWidget({
//     Key? key,
//     required this.paragraphs,
//     this.activeParagraph,
//     this.activeNote,
//     this.initialPage = 2,
//     this.active = false,
//     this.selectedWords = const [],
//     this.onParagraphTap,
//     this.onParagraphDoubleTap,
//     this.onParagraphLongPress,
//     this.onWordTap,
//     this.onWordDoubleTap,
//     this.onWordLongPress,
//     this.onNoteLongPress,
//     this.onNoteDoubleTap,
//     this.onNoteTap,
//     this.onKeywordsTap,
//     this.onToggleExpanded,
//     this.onToggleCapitalNotes,
//     this.onClearSelection,
//     this.onClearSelectionLongPress,
//     this.onClearParagraphSelection,
//     this.onLinkWithPrevious,
//     this.onUnlinkWithPrevious,
//     this.onChangeColor,
//     this.onAddActionTap,
//     this.onAddAsKeywords,
//     required this.addAction,
//     required this.addActionLock,
//     this.onAddAsNote,
//     this.onAddQuestion,
//     this.onPhotoTap,
//     this.onPhotoSizeTap,
//     this.onShowAnswer,
//     this.onNotesIndexChanged,
//     this.hasSelectedWords = false,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     BookColorMap? colormap = BookParagraph.colors[paragraphs.first.color] ?? BookParagraph.colors['grey'];
//
//     return Column(
//       mainAxisSize: MainAxisSize.max,
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         if (paragraphs.notes.isNotEmpty)
//           Container(
//             constraints: const BoxConstraints(minHeight: 20),
//             width: MediaQuery.of(context).size.width,
//             height: paragraphs.notesHeight,
//             child: Swiper(
//               autoplay: false,
//               onIndexChanged: onNotesIndexChanged,
//               controller: SwiperController(),
//               index: paragraphs.notesIndex,
//               itemCount: 3,
//               itemBuilder: (context, index) {
//                 switch(index){
//                   case 0:
//                     return BookNotesWidgetRow(
//                       hasSelectedWords: hasSelectedWords,
//                       paragraphs: paragraphs,
//                       activeParagraph: activeParagraph,
//                       activeNote: activeNote,
//                       mode: BookNotesRenderMode.notes,
//                       colormap: colormap as BookColorMap,
//                       onAddAsKeyword: active && selectedWords.isNotEmpty && onAddAsKeywords != null ? (note, capital) => onAddAsKeywords!(note, capital) : null,
//                       onAddAsNote: active && selectedWords.isNotEmpty && onAddAsNote != null ? (note) => onAddAsNote!(note) : null,
//                       onNoteLongPress: onNoteLongPress,
//                       onNoteDoubleTap: onNoteDoubleTap,
//                       onNoteTap: onNoteTap,
//                       onKeywordsTap: onKeywordsTap,
//                       onPhotoTap: onPhotoTap,
//                       note: ,
//                     );
//                   case 1:
//                     return BookNotesWidgetRow(
//                       hasSelectedWords: hasSelectedWords,
//                       paragraphs: paragraphs,
//                       activeParagraph: activeParagraph,
//                       activeNote: activeNote,
//                       mode: BookNotesRenderMode.keywords,
//                       colormap: colormap as BookColorMap,
//                       onAddAsKeyword: active && selectedWords.isNotEmpty && onAddAsKeywords != null ? (note, capital) => onAddAsKeywords!(note, capital) : null,
//                       onAddAsNote: active && selectedWords.isNotEmpty && onAddAsNote != null ? (note) => onAddAsNote!(note) : null,
//                       onNoteLongPress: onNoteLongPress,
//                       onNoteDoubleTap: onNoteDoubleTap,
//                       onKeywordsTap: onKeywordsTap,
//                       onPhotoTap: onPhotoTap,
//                       onPhotoSizeTap: onPhotoSizeTap,
//                     );
//                   case 2:
//                     return BookNotesWidgetRow(
//                       hasSelectedWords: hasSelectedWords,
//                       paragraphs: paragraphs,
//                       activeParagraph: activeParagraph,
//                       activeNote: activeNote,
//                       mode: BookNotesRenderMode.notes,
//                       colormap: colormap as BookColorMap,
//                       onAddAsKeyword: active && selectedWords.isNotEmpty && onAddAsKeywords != null ? (note, capital) => onAddAsKeywords!(note, capital) : null,
//                       onAddAsNote: active && selectedWords.isNotEmpty && onAddAsNote != null ? (note) => onAddAsNote!(note) : null,
//                       onNoteLongPress: onNoteLongPress,
//                       onNoteDoubleTap: onNoteDoubleTap,
//                       onNoteTap: onNoteTap,
//                       onKeywordsTap: onKeywordsTap,
//                       onPhotoTap: onPhotoTap,
//                     );
//                   default:
//                     return const SizedBox();
//                 }
//               },),
//           ),
//         if (paragraphs.expanded || paragraphs.contains(activeParagraph))
//           Column(
//             children: paragraphs
//                 .map(
//                   (p) => Container(
//                     width: MediaQuery.of(context).size.width,
//                     padding: const EdgeInsets.symmetric(horizontal: 10),
//                     color: (p == activeParagraph) ? colormap![BookParagraph.colorBackParagraph] : null,
//                     child: Column(
//                       children: [
//                         if (p == activeParagraph)
//                           BookNotesWidgetToolbar(
//                             paragraph: p,
//                             colormap: colormap as BookColorMap,
//                             selectedWords: selectedWords,
//                             onToggleExpanded: onToggleExpanded,
//                             onClearSelection: onClearSelection,
//                             onClearParagraphSelection: onClearParagraphSelection,
//                             onLinkWithPrevious: onLinkWithPrevious != null ? () => onLinkWithPrevious!(p) : null,
//                             onUnlinkWithPrevious: onUnlinkWithPrevious != null ? () => onUnlinkWithPrevious!(p) : null,
//                             onChangeColor: onChangeColor != null ? (String color) => onChangeColor!(p, color) : null,
//                             onAddActionTap: onAddActionTap,
//                             addAction: addAction,
//                             addActionLock: addActionLock,
//                             onAddAsNote: onAddAsNote,
//                             onToggleCapitalNotes: onToggleCapitalNotes,
//                             onClearSelectionLongPress: onClearSelectionLongPress,
//                           ),
//                         if(paragraphs.expanded || p == activeParagraph || paragraphs.notes.isEmpty) RichText(
//                           text: TextSpan(
//                             children: p.asWidgetSpans(
//                               colormap: colormap as BookColorMap,
//                               selectedWords: p == activeParagraph ? selectedWords : [],
//                               active: p == activeParagraph,
//                               onWordTap: onWordTap,
//                               onWordDoubleTap: onWordDoubleTap,
//                               onWordLongPress: onWordLongPress,
//                               addAction: addAction,
//                             ),
//                           ),
//                           textAlign: TextAlign.justify,
//                         ),
//                       ],
//                     ),
//                   ),
//                 )
//                 .toList(),
//           ),
//       ],
//     );
//   }
// }
