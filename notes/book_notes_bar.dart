import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:notebars/classes/book_note.dart';
import 'package:notebars/classes/book_note_sync_move.dart';
import 'package:notebars/classes/book_paragraph.dart';
import 'package:notebars/classes/keyword.dart';
import 'package:notebars/common/note_constant.dart';
import 'package:notebars/extensions.dart';
import 'package:notebars/views/book_notes_view.dart';
import 'package:notebars/widgets/notes/book_notes_widget_row.dart';
import 'package:notebars/widgets/notes/just_key_bar.dart';
import 'package:notebars/widgets/notes/just_note_bar.dart';
import 'package:notebars/widgets/notes/key_and_note_bar.dart';

class BookNotesBar extends StatefulWidget {
  const BookNotesBar({
    Key? key,
    required this.paragraphs,
    required this.onNotesIndexChanged,
    required this.hasSelectedWords,
    required this.paragraph,
    this.activeParagraph,
    required this.activeNote,
    required this.colorMap,
    this.onAddAsNote,
    this.onAddQuestion,
    this.onPhotoTap,
    this.onPhotoSizeTap,
    this.onShowAnswer,
    this.onNoteLongPress,
    this.onNoteDoubleTap,
    this.onNoteTap,
    this.onKeywordsTap,
    this.onAddAsKeywords,
    this.bookNoteSyncMoveList,
    required this.selectedWords,
    required this.initialPage,
    required this.active,
    required this.shiftingStatus,
    required this.lockStatus,
    required this.onTransparentIndexChanged,
    required this.continuousNotes,
    required this.notes,
  }) : super(key: key);

  final BookParagraphGroup paragraphs;
  final Function(BookNote note, int page, List<BookNote> notes)
      onNotesIndexChanged;
  final bool hasSelectedWords;
  final BookParagraph paragraph;
  final BookParagraph? activeParagraph;
  final BookNote? activeNote;
  final BookColorMap colorMap;
  final Function(BookNote? note)? onAddAsNote;
  final Function(BookNote note)? onAddQuestion;
  final Function(BookNote note)? onPhotoTap;
  final Function(BookNote note, bool)? onPhotoSizeTap;
  final Function(BookNote note)? onShowAnswer;
  final Function(BookNote)? onNoteLongPress;
  final Function(BookNote)? onNoteDoubleTap;
  final LockStatus lockStatus;
  final Function(BookNote note, int page, List<BookNote>? notes)
      onTransparentIndexChanged;
  final List<BookNoteSyncMove>? bookNoteSyncMoveList;
  final Function(BookNote)? onNoteTap;
  final Function(BookNote)? onKeywordsTap;
  final Function(BookNote? note, bool? capital)? onAddAsKeywords;
  final List<Keyword> selectedWords;
  final int initialPage;
  final bool active;
  final ShiftingStatus shiftingStatus;
  final List<List<BookNote>> continuousNotes;
  final List<BookNote> notes;

  @override
  State<BookNotesBar> createState() => _BookNotesBarState();
}

class _BookNotesBarState extends State<BookNotesBar> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.lockStatus == LockStatus.unlocked
          ? widget.notes
              .map((note) => Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: note.isNullNoteV2 ? 0 : note.noteHeight,
                        child: Stack(
                          children: [
                            swiperItems(note, false, widget.onNotesIndexChanged,
                                note.swiperController,),
                          ],
                        ),
                      ),
                    ],
                  ))
              .toList()
          : widget.notes
              .map((note) => Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: note.isNullNoteV2 ? 0 : note.noteHeight,
                        child: Stack(
                          children: [
                            swiperItems(note, false, widget.onNotesIndexChanged,
                                note.swiperController,),
                            swiperItems(note, true, widget.onTransparentIndexChanged,
                                note.transparentController,),
                          ],
                        ),
                      ),
                    ],
                  ))
              .toList(),
    );
  }

  Widget swiperItems(
    BookNote note,
    bool isTransparent,
    Function(BookNote note, int page, List<BookNote> notes) onIndexChanged,
    SwiperController controller,) {
    return Swiper(
      loop: false,
      outer: false,
      autoplay: false,
      onIndexChanged: (index) {
        if (controller is CustomSwiperController) {
          if (controller.isBlocked) {
            (controller).isBlocked = true;
            return;
          }
        }
        onIndexChanged(note, index, []);
      },
      controller: controller,
      index: note.noteIndex,
      itemCount: 3,
      itemBuilder: (context, index) {
        switch (index) {
          case NoteConstant.justKeyIndex:
            return Opacity(
              opacity: isTransparent ? 0.0 : 1.0,
              child: JustKeyBar(
                note: note,
                hasSelectedWords: widget.hasSelectedWords,
                paragraphs: [widget.paragraph],
                activeParagraph: widget.activeParagraph,
                activeNote: widget.activeNote,
                mode: BookNotesRenderMode.questions,
                colormap: widget.colorMap,
                onAddAsKeyword: widget.active &&
                    widget.selectedWords.isNotEmpty &&
                    widget.onAddAsKeywords != null
                    ? (note, capital) => widget.onAddAsKeywords!(note, capital)
                    : null,
                onAddAsNote: widget.active &&
                    widget.selectedWords.isNotEmpty &&
                    widget.onAddAsNote != null
                    ? (note) => widget.onAddAsNote!(note)
                    : null,
                onNoteLongPress: widget.onNoteLongPress,
                onNoteDoubleTap: widget.onNoteDoubleTap,
                onNoteTap: widget.onNoteTap,
                onKeywordsTap: widget.onKeywordsTap,
                onPhotoTap: widget.onPhotoTap,
              ),
            );
          case NoteConstant.keyAndNoteIndex:
            return Opacity(
              opacity: isTransparent ? 0.0 : 1.0,
              child: KeyAndNoteBar(
                note: note,
                onNoteTap: widget.onNoteTap,
                hasSelectedWords: widget.hasSelectedWords,
                paragraphs: [widget.paragraph],
                activeParagraph: widget.activeParagraph,
                activeNote: widget.activeNote,
                mode: BookNotesRenderMode.keywords,
                colormap: widget.colorMap,
                onAddAsKeyword: widget.active &&
                    widget.selectedWords.isNotEmpty &&
                    widget.onAddAsKeywords != null
                    ? (note, capital) => widget.onAddAsKeywords!(note, capital)
                    : null,
                onAddAsNote: widget.active &&
                    widget.selectedWords.isNotEmpty &&
                    widget.onAddAsNote != null
                    ? (note) => widget.onAddAsNote!(note)
                    : null,
                onNoteLongPress: widget.onNoteLongPress,
                onNoteDoubleTap: widget.onNoteDoubleTap,
                onKeywordsTap: widget.onKeywordsTap,
                onPhotoTap: widget.onPhotoTap,
                onPhotoSizeTap: widget.onPhotoSizeTap,
              ),
            );
          case NoteConstant.justNoteIndex:
            return Opacity(
              opacity: isTransparent ? 0.0 : 1.0,
              child: JustNoteBar(
                note: note,
                hasSelectedWords: widget.hasSelectedWords,
                paragraphs: [widget.paragraph],
                activeParagraph: widget.activeParagraph,
                activeNote: widget.activeNote,
                mode: BookNotesRenderMode.notes,
                colormap: widget.colorMap,
                onAddAsKeyword: widget.active &&
                    widget.selectedWords.isNotEmpty &&
                    widget.onAddAsKeywords != null
                    ? (note, capital) => widget.onAddAsKeywords!(note, capital)
                    : null,
                onAddAsNote: widget.active &&
                    widget.selectedWords.isNotEmpty &&
                    widget.onAddAsNote != null
                    ? (note) => widget.onAddAsNote!(note)
                    : null,
                onNoteLongPress: widget.onNoteLongPress,
                onNoteDoubleTap: widget.onNoteDoubleTap,
                onNoteTap: widget.onNoteTap,
                onKeywordsTap: widget.onKeywordsTap,
                onPhotoTap: widget.onPhotoTap,
              ),
            );
          default:
            return const SizedBox();
        }
      },
    );
  }
}
