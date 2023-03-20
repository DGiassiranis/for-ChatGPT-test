import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:notebars/classes/book_note.dart';
import 'package:notebars/classes/book_paragraph.dart';
import 'package:notebars/extensions.dart';

class NoteEditController extends GetxController {
  NoteEditController({
    required this.paragraph,
    required this.note,
    required this.onSave,
    required this.onCancel,
    required this.onDeleteTap,
  });

  final BookParagraph paragraph;
  final BookNote note;
  final Function(String note, String name, String question) onSave;
  final Function() onCancel;
  final Function() onDeleteTap;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController questionController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    nameController.text = note.name.isNotEmpty
        ? note.name
        : note.keywords.words.join(' ');
    noteController.text = note.note.isNotEmpty
        ? note.note
        : note.notewords.words.join(' ');
    questionController.text = note.question.isNotEmpty ? note.question : '';
  }
}
