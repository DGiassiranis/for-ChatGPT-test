/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../classes/book_library.dart';
import '../widgets/common/bottom_sheet_dialog.dart';

class LibraryEditSheet extends StatefulWidget {
  LibraryEditSheet({Key? key, required this.library, this.onSave, this.onCancel}) : super(key: key);

  final BookLibrary library;
  final Function(BookLibrary library)? onSave;
  final Function? onCancel;

  final LibraryEditSheetState _state = LibraryEditSheetState();

  bool validate() {
    return _state._formKey.currentState != null ? _state._formKey.currentState!.validate() : true;
  }

  @override
  LibraryEditSheetState createState() => _state;
}

class LibraryEditSheetState extends State<LibraryEditSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late BookLibrary _library;

  @override
  void initState() {
    super.initState();

    _library = BookLibrary.fromJson(widget.library.toJson());
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetDialog(
      formKey: _formKey,
      child: Column(
        children: <Widget>[
          ListTile(
            dense: true,
            leading: const Icon(Icons.edit_attributes, color: Colors.white60),
            title: TextFormField(
              initialValue: _library.name,
              decoration: const InputDecoration(
                isDense: true,
                labelStyle: TextStyle(color: Colors.white70),
                labelText: 'Type a library name...',
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (String name) {
                setState(() {
                  _library.name = name;
                });
              },
              validator: (String? value) {
                return (value == null || value.trim().isEmpty) ? 'Please, type a name' : null;
              },
            ),
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.palette, color: Colors.white60),
            title: Column(
              children: [
                Container(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: BlockPicker(
                    pickerColor: _library.color,
                    availableColors: const [
                      Colors.deepPurple,
                      Colors.indigo,
                      Colors.blue,
                      Colors.cyan,
                      Colors.purple,
                      Colors.purpleAccent,
                      Colors.pink,
                      Colors.red,
                      Colors.brown,
                      Colors.amber,
                      Colors.green,
                      Colors.greenAccent,
                    ],
                    onColorChanged: (Color c) {
                      setState(() {
                        _library.color = c;
                      });
                    },
                  ),
                ),
              ],
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
                    widget.onSave!(_library);
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
