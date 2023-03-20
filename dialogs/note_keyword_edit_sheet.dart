/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:notebars/extensions.dart';

import '../classes/book_note.dart';
import '../widgets/common/bottom_sheet_dialog.dart';

class NoteKeywordEditSheet extends StatefulWidget {
  NoteKeywordEditSheet({Key? key, required this.note, this.onSave, this.onCancel}) : super(key: key);

  final BookNote note;
  final Function(BookNote note)? onSave;
  final Function? onCancel;
  final NoteKeywordEditSheetState _state = NoteKeywordEditSheetState();

  bool validate() {
    return _state._formKey.currentState != null ? _state._formKey.currentState!.validate() : true;
  }

  @override
  NoteKeywordEditSheetState createState() => _state;
}

class NoteKeywordEditSheetState extends State<NoteKeywordEditSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late BookNote _note;

  @override
  void initState() {
    super.initState();
    _note = BookNote.fromJson(widget.note.toJson());
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
              initialValue: _note.name.isNotEmpty ? _note.name : _note.keywords.words.join(' '),
              decoration: const InputDecoration(
                isDense: true,
                labelStyle: TextStyle(color: Colors.white70),
                labelText: 'Type a name...',
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (String value) {
                setState(() {
                  _note.name = value;
                });
              },
            ),
          ),
          ListTile(
            dense: true,
            leading: Icon(
              Icons.edit_attributes,
              color: Colors.white.withOpacity(.6),
            ),
            title: TextFormField(
              initialValue: _note.note.isNotEmpty ? _note.note : _note.notewords.words.join(' '),
              maxLines: 5,
              decoration: const InputDecoration(
                isDense: true,
                labelStyle: TextStyle(color: Colors.white70),
                labelText: 'Type a note...',
              ),
              onChanged: (String value) {
                setState(() {
                  _note.note = value;
                });
              },
              style: const TextStyle(color: Colors.white),
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
                    widget.onSave!(_note);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
          // endregion
        ],
      ),
    );
  }
}
