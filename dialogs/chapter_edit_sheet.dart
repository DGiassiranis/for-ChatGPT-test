/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:flutter/material.dart';

import '../classes/book_chapter.dart';
import '../widgets/common/bottom_sheet_dialog.dart';

class ChapterEditSheet extends StatefulWidget {
  ChapterEditSheet({Key? key, required this.chapter, this.onSave, this.onCancel}) : super(key: key);

  final BookChapter chapter;
  final Function(BookChapter chapter)? onSave;
  final Function? onCancel;
  final ChapterEditSheetState _state = ChapterEditSheetState();

  bool validate() {
    return _state._formKey.currentState != null ? _state._formKey.currentState!.validate() : true;
  }

  @override
  ChapterEditSheetState createState() => _state;
}

class ChapterEditSheetState extends State<ChapterEditSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late BookChapter _chapter;

  @override
  void initState() {
    super.initState();

    _chapter = BookChapter.fromJson(widget.chapter.toJson());
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
              initialValue: _chapter.name,
              decoration: const InputDecoration(
                isDense: true,
                labelStyle: TextStyle(color: Colors.white70),
                labelText: 'Type chapter\'s name...',
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (String name) {
                setState(() {
                  _chapter.name = name;
                });
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
                    widget.onSave!(_chapter);
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
