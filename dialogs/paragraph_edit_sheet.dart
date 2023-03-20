/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:notebars/classes/book_paragraph.dart';
import 'package:notebars/extensions.dart';

import '../widgets/common/bottom_sheet_dialog.dart';

class ParagraphEditSheet extends StatefulWidget {
  ParagraphEditSheet({Key? key, this.onSave, this.onCancel, required this.paragraph, required this.pos, required this.word}) : super(key: key);

  final BookParagraph paragraph;
  final int pos;
  final String word;
  final Function(BookParagraph paragraph)? onSave;
  final Function? onCancel;
  final ParagraphEditSheetState _state = ParagraphEditSheetState();

  bool validate() {
    return _state._formKey.currentState != null ? _state._formKey.currentState!.validate() : true;
  }

  @override
  ParagraphEditSheetState createState() => _state;
}

class ParagraphEditSheetState extends State<ParagraphEditSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String initSentence = '';
  String finalSentence = '';
  int startPos = 0;
  int endPos = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      calculateInitString();
    });
  }

  calculateInitString (){

    List<String> words = widget.paragraph.text.asWords();

    initSentence = words.getSurroundedSentenceFromPos(widget.pos);

  }


  @override
  Widget build(BuildContext context) {
    return BottomSheetDialog(
      formKey: _formKey,
      child: Column(
        children: <Widget>[
          ListTile(
            dense: true,
            leading: Icon(
              Icons.edit_attributes,
              color: Colors.white.withOpacity(.6),
            ),
            title: TextFormField(
              maxLines: 2,
              initialValue: initSentence,
              decoration: const InputDecoration(
                isDense: true,
                labelStyle: TextStyle(color: Colors.white70),
                labelText: 'Edit current sentence...',
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (String name) {
                finalSentence = name;
              },
              validator: (String? value) {
                return (value == null || value.trim().isEmpty) ? 'Please, type a name' : null;
              },
            ),
          ),
          // region Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  if (widget.onCancel != null) widget.onCancel!();
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (widget.onSave == null) return;
                  if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                    widget.paragraph.text = widget.paragraph.text.replaceAll(initSentence, finalSentence);
                    widget.onSave!(widget.paragraph);
                  }
                },
                child: const Text('Apply'),
              ),
            ],
          ),
          // endregion
        ],
      ),
    );
  }
}
