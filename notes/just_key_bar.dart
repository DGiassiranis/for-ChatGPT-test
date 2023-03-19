
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:notebars/classes/book_note.dart';
import 'package:notebars/classes/book_paragraph.dart';
import 'package:notebars/extensions.dart';
import 'package:notebars/global.dart';
import 'package:notebars/views/settings_view.dart';
import 'package:notebars/widgets/notes/book_notes_widget_photo.dart';
import 'package:notebars/widgets/notes/book_notes_widget_row.dart';



class JustKeyBar extends StatelessWidget {
  const JustKeyBar({Key? key, required this.paragraphs, required this.hasSelectedWords, this.customNotes, required this.colormap, required this.mode, this.activeParagraph, this.activeNote, this.onAddAsKeyword, this.onNoteLongPress, this.onNoteDoubleTap, this.onNoteTap, this.onKeywordsTap, this.onPhotoTap, this.onPhotoSizeTap, this.onAddAsNote, this.onAddQuestion, this.onShowAnswer, this.explicitHeight, required this.note}) : super(key: key);

  final BookParagraphGroup paragraphs;
  final bool hasSelectedWords;
  final List<BookNote>? customNotes;
  final BookColorMap colormap;
  final BookNotesRenderMode mode;
  final BookParagraph? activeParagraph;
  final BookNote? activeNote;
  final Function(BookNote?, bool?)? onAddAsKeyword;
  final Function(BookNote)? onNoteLongPress;
  final Function(BookNote)? onNoteDoubleTap;
  final Function(BookNote)? onNoteTap;
  final Function(BookNote)? onKeywordsTap;
  final Function(BookNote)? onPhotoTap;
  final Function(BookNote, bool)? onPhotoSizeTap;
  final Function(BookNote?)? onAddAsNote;
  final Function(BookNote)? onAddQuestion;
  final Function(BookNote)? onShowAnswer;
  final double? explicitHeight;
  final BookNote note;

  // region Getters/setters
  static double get rowHeight => app.settings['noteRowHeight'];

  @override
  Widget build(BuildContext context) {
    const double textHeight = 1.4;
    final double symbolHeight = (explicitHeight ??
        note.noteHeight) * .8;
    return note.isNullNoteV2 ? const SizedBox() : Row(
      children: [
        Container(
          height: explicitHeight ??
              note.noteHeight,
          width: MediaQuery.of(context).size.width * 0.1,
          color: colormap[BookParagraph.colorBackKeywords],
      padding: const EdgeInsets.all(2.0),
          child: note.symbolAssetPath.isNotEmpty && note.keywords.isNotEmpty ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(note.symbolAssetPath, color: colormap[BookParagraph.colorTextPrimary], height: symbolHeight, width: symbolHeight,),
            ],
          ) : const SizedBox(),
        ),
        GestureDetector(
          onLongPress: () =>
          onNoteLongPress != null ? onNoteLongPress!(note) : null,
          onDoubleTap: () =>
          onNoteDoubleTap != null ? onNoteDoubleTap!(note) : null,
          onTap: () =>
          onKeywordsTap != null ? onKeywordsTap!(note) : null,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: explicitHeight ??
                note.noteHeight,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: (paragraphs.indexOf(noteBelongsTo(note)).isOdd
                  ? colormap[BookParagraph.colorKeyBackground]
                  : colormap[BookParagraph.colorKeyBackground]),
            ),
            child: note.imageData.isNotEmpty
                ? Container(
              height: explicitHeight ??
                  note.noteHeight,
              padding: const EdgeInsets.only(left: 10, top: 5, right: 5),
              child: BookNotesWidgetPhoto(
                note: note,
                colormap: colormap,
                onPhotoTap: onPhotoTap == null ? null : () => onPhotoTap!(note),
                onIncreasePhotoSize: onPhotoSizeTap != null && note.photoSize != NotePhotoSize.large ? () => onPhotoSizeTap!(note, true) : null,
                onDecreasePhotoSize: onPhotoSizeTap != null && note.photoSize != NotePhotoSize.small ? () => onPhotoSizeTap!(note, false) : null,
              ),
            )
                : (note.keywords.isNotEmpty
                ? Center(
              child: Text(
                (note.keyBarStatus != KeyBarStatus.question ? (note.name.isNotEmpty ? note.name : note.keywords.words.join(' ')) : note.question),
                style: TextStyle(color: colormap[BookParagraph.colorTextPrimary]?.withOpacity(note.keyBarStatus != KeyBarStatus.keyTransparent ? 1.0 : 0.15, ), fontSize: note.noteBarSize.fontSize * (app.settings["notebarsFontSize"] ?? notebarsDefaultFontMultiplier), fontWeight: FontWeight.bold,
                  height: textHeight,
                ),
                textAlign: TextAlign.center,
              ),
            ) : note.symbolAssetPath.isNotEmpty ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(note.symbolAssetPath, color: colormap[BookParagraph.colorTextPrimary], height: symbolHeight, width: symbolHeight,),
              ],
            )
                : (onAddAsKeyword != null && noteBelongsTo(note) == activeParagraph
                ? TextButton(
              onPressed: () => onAddAsKeyword!(note, false),
              child: Row(
                children: const [Icon(Icons.add), Text('Add here...')],
              ),
            )
                : const SizedBox(width: 1))),
          ),
        ),
        Container(
          height: explicitHeight ??
              note.noteHeight,
          width: MediaQuery.of(context).size.width * 0.1,
          padding: const EdgeInsets.all(2.0),
          color: colormap[BookParagraph.colorBackNotes],
          child: note.symbolAssetPath.isNotEmpty && note.keywords.isNotEmpty ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(note.symbolAssetPath, color: colormap[BookParagraph.colorTextPrimary], height: symbolHeight, width: symbolHeight,),
            ],
          ) : const SizedBox(),
        )
      ],
    );
  }

  BookParagraph noteBelongsTo(BookNote note) {
    try{
      return paragraphs.firstWhere((p) => p.notes.contains(note));
    }catch(_){
      return paragraphs.last;
    }
  }
}
