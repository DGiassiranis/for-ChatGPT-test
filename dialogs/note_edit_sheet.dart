import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:notebars/classes/book_note.dart';
import 'package:notebars/classes/book_paragraph.dart';
import 'package:notebars/getx/controller/note_edit_controller.dart';

class NoteEditSheet extends GetView<NoteEditController> {
  const NoteEditSheet({Key? key, required this.onChangeSize, required this.noteBarSize, required this.onSelectSymbol}) : super(key: key);

  final Function(NoteNoteBarSize size) onChangeSize;
  final NoteNoteBarSize noteBarSize;
  final Function(String keyText, String noteText, String questionText) onSelectSymbol;

  @override
  Widget build(BuildContext context) {
    Color? bgColor = BookParagraph.colors[controller.paragraph.color]
    ?[BookParagraph.colorBackKeywords];
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: MediaQuery.of(context).viewInsets,
      width: 50,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: bgColor,
      ),
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.vpn_key_outlined,
                  color: BookParagraph.colors[controller.paragraph.color]
                              ?[BookParagraph.colorTextPrimary]
                          ?.withOpacity(0.5) ??
                      Colors.white.withOpacity(.6),
                ),
                title: TextFormField(
                  controller: controller.nameController,
                  cursorColor: BookParagraph.colors[controller.paragraph.color]
                          ?[BookParagraph.colorTextPrimary]
                      ?.withOpacity(0.5),
                  decoration: _inputDecorationFromParagraph(controller.paragraph,
                      labelText: 'Type a name...'),
                  style: TextStyle(
                      color: BookParagraph.colors[controller.paragraph.color]
                              ?[BookParagraph.colorTextPrimary] ??
                          Colors.white),
                  onChanged: (String value) {},
                  maxLines: null,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.description_outlined,
                  color: BookParagraph.colors[controller.paragraph.color]
                              ?[BookParagraph.colorTextPrimary]
                          ?.withOpacity(0.5) ??
                      Colors.white.withOpacity(.6),
                ),
                title: TextFormField(
                  controller: controller.noteController,
                  cursorColor: BookParagraph.colors[controller.paragraph.color]
                          ?[BookParagraph.colorTextPrimary]
                      ?.withOpacity(0.5),
                  decoration: _inputDecorationFromParagraph(controller.paragraph,
                      labelText: 'Type a note...'),
                  style: TextStyle(
                      color: BookParagraph.colors[controller.paragraph.color]
                              ?[BookParagraph.colorTextPrimary] ??
                          Colors.white),
                  onChanged: (String value) {},
                  maxLines: null,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.question_mark,
                  color: BookParagraph.colors[controller.paragraph.color]
                              ?[BookParagraph.colorTextPrimary]
                          ?.withOpacity(0.5) ??
                      Colors.white.withOpacity(.6),
                ),
                title: TextFormField(
                  controller: controller.questionController,
                  cursorColor: BookParagraph.colors[controller.paragraph.color]
                          ?[BookParagraph.colorTextPrimary]
                      ?.withOpacity(0.5),
                  decoration: _inputDecorationFromParagraph(controller.paragraph,
                      labelText: 'Type a question...'),
                  style: TextStyle(
                      color: BookParagraph.colors[controller.paragraph.color]
                              ?[BookParagraph.colorTextPrimary] ??
                          Colors.white),
                  onChanged: (String value) {},
                  maxLines: null,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ListTile(
                onTap: () => onSelectSymbol(controller.nameController.text, controller.noteController.text, controller.questionController.text),
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.camera_alt_outlined,
                  color: BookParagraph.colors[controller.paragraph.color]
                              ?[BookParagraph.colorTextPrimary]
                          ?.withOpacity(0.5) ??
                      Colors.white.withOpacity(.6),
                ),
                title: controller.note.symbolAssetPath.isNotEmpty ? Row(
                  children: [
                    SvgPicture.asset(controller.note.symbolAssetPath, width: 50, height: 50, color: BookParagraph.colors[controller.paragraph.color]
                    ?[BookParagraph.colorTextPrimary],),
                  ],
                ) : TextFormField(
                  enabled: false,
                  cursorColor: BookParagraph.colors[controller.paragraph.color]
                          ?[BookParagraph.colorTextPrimary]
                      ?.withOpacity(0.5),
                  decoration: _inputDecorationFromParagraph(controller.paragraph,
                      labelText: 'Add a symbol ✮ ✢ ❂ ✶ ✧...'),
                  style: TextStyle(
                      color: BookParagraph.colors[controller.paragraph.color]
                              ?[BookParagraph.colorTextPrimary] ??
                          Colors.white),
                  onChanged: (String value) {},
                  maxLines: null,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _changeSizeRow,
                  ElevatedButton(
                    onPressed: (){
                      controller.onSave(
                        controller.nameController.text,
                        controller.noteController.text,
                        controller.questionController.text,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          BookParagraph.colors[controller.paragraph.color]
                              ?[BookParagraph.colorTextPrimary],
                    ),
                    child: Text('Save', style: TextStyle(
                      color: bgColor,
                    ),),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget get _changeSizeRow {
    Color? bgColor = BookParagraph.colors[controller.paragraph.color]
    ?[BookParagraph.colorTextPrimary];
    return Material(
    color: Colors.transparent,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Size',
          style: TextStyle(
            fontSize: 16,
            color: bgColor,
          ),
        ),

        Radio<NoteNoteBarSize>(
          activeColor: bgColor,
          value: NoteNoteBarSize.small,
          groupValue: noteBarSize,
          onChanged: (value) {
            if (value == null) return;
            onChangeSize(value);
          },
        ),
        Radio<NoteNoteBarSize>(
          activeColor: bgColor,
          value: NoteNoteBarSize.medium,
          groupValue: noteBarSize,
          onChanged: (value) {
            if (value == null) return;
            onChangeSize(value);
          },
        ),

        Radio<NoteNoteBarSize>(
          activeColor: bgColor,
          value: NoteNoteBarSize.large,
          groupValue: noteBarSize,
          onChanged: (value) {
            if (value == null) return;
            onChangeSize(value);
          },
        ),
      ],
    ),
  );
  }


  InputDecoration _inputDecorationFromParagraph(BookParagraph paragraph,
      {String? labelText,}) {
    return InputDecoration(
      isDense: true,
      hintStyle: TextStyle(
          color: BookParagraph.colors[paragraph.color]
                      ?[BookParagraph.colorTextPrimary]
                  ?.withOpacity(0.5) ??
              Colors.white70),
      focusColor: BookParagraph.colors[paragraph.color]
                  ?[BookParagraph.colorTextPrimary]
              ?.withOpacity(0.5) ??
          Colors.white70,
      hintText: labelText,
      border: UnderlineInputBorder(
        borderSide: BorderSide(
            color: BookParagraph.colors[paragraph.color]
                        ?[BookParagraph.colorTextPrimary]
                    ?.withOpacity(0.5) ??
                Colors.white),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(
            color: BookParagraph.colors[paragraph.color]
                        ?[BookParagraph.colorTextPrimary]
                    ?.withOpacity(0.5) ??
                Colors.white),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
            color: BookParagraph.colors[paragraph.color]
                    ?[BookParagraph.colorTextPrimary] ??
                Colors.white),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
            color: BookParagraph.colors[paragraph.color]
                        ?[BookParagraph.colorTextPrimary]
                    ?.withOpacity(0.5) ??
                Colors.white),
      ),
      disabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
            color: BookParagraph.colors[paragraph.color]
            ?[BookParagraph.colorTextPrimary]
                ?.withOpacity(0.5) ??
                Colors.white),
      ),
    );
  }
}
