/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:notebars/dialogs/book_select_icon_sheet.dart';
import 'package:notebars/getx/controller/book_select_icon_controller.dart';

import '../classes/book.dart';
import '../widgets/common/bottom_sheet_dialog.dart';

class BookEditSheet extends StatefulWidget {
  BookEditSheet({Key? key, required this.book, this.onSave, this.onCancel}) : super(key: key);

  final Book book;
  final Function(Book book)? onSave;
  final Function? onCancel;
  final BookEditSheetState _state = BookEditSheetState();

  bool validate() {
    return _state._formKey.currentState != null ? _state._formKey.currentState!.validate() : true;
  }

  @override
  BookEditSheetState createState() => _state;
}

class BookEditSheetState extends State<BookEditSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Book _book;

  @override
  void initState() {
    super.initState();

    _book = Book.fromJson(widget.book.toJson());
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
              initialValue: _book.name,
              decoration: const InputDecoration(
                isDense: true,
                labelStyle: TextStyle(color: Colors.white70),
                labelText: 'Type book\'s name...',
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (String name) {
                setState(() {
                  _book.name = name;
                });
              },
              validator: (String? value) {
                return (value == null || value.trim().isEmpty) ? 'Please, type a name' : null;
              },
            ),
          ),
          const SizedBox(height: 20,),
          ListTile(
            dense: true,
            leading: Icon(
              Icons.image,
              color: Colors.white.withOpacity(.6),
            ),
            title: GestureDetector(
              onTap: () {
                BookSelectIconController controller = BookSelectIconController.find;

                controller.initialize(
                  onDeleteSymbol: () {
                    _book.bookIcon = null;
                    Get.back();
                  },
                  onCompletedAsset: (assetPath) {
                    _book.bookIcon = assetPath;
                    Get.back();
                  },
                );

                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  builder: (BuildContext bc) {
                    BookSelectIconController controller = BookSelectIconController.find;
                    controller.initialize(
                      onDeleteSymbol: () {
                        _book.bookIcon = null;
                        Get.back();
                        setState(() {
                        });
                      },
                      onCompletedAsset: (assetPath) {
                        _book.bookIcon = assetPath;
                        Get.back();
                        setState(() {
                        });
                      },
                    );

                    return const BookSelectIconSheet();
                  },
                );
              },
              child: _book.bookIcon != null ? SvgPicture.asset(_book.bookIcon!, width: 40, height: 40, color: Colors.white,) : const Text('Add a book icon...', style: TextStyle(color: Colors.white),),
            ),
          ),
          // region Actions
          const SizedBox(height: 20,),
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
                    widget.onSave!(_book);
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
