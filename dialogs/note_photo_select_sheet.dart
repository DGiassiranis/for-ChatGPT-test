/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:notebars/classes/book_note.dart';

import '../widgets/common/bottom_sheet_dialog.dart';

class NotePhotoSelectSheet extends StatefulWidget {
  final BookNote note;
  final VoidCallback? onCancel;
  final Function(String imageData) onCompleted;

  const NotePhotoSelectSheet({Key? key, required this.note, this.onCancel, required this.onCompleted}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NotePHotoSelectSheetState();
}

class _NotePHotoSelectSheetState extends State<NotePhotoSelectSheet> {
  void usePhotoLibrary() async {
    final XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) {
      if (mounted) Navigator.of(context).maybePop();
      return;
    }

    final img.Image? photo = img.decodeImage(await file.readAsBytes());
    if (photo == null) {
      if (mounted) Navigator.of(context).maybePop();
      return;
    }

    selectImage(photo);
  }

  void useCamera() async {
    final XFile? file = await ImagePicker().pickImage(source: ImageSource.camera);
    if (file == null) {
      if (mounted) Navigator.of(context).maybePop();
      return;
    }

    final img.Image? photo = img.decodeImage(await file.readAsBytes());
    if (photo == null) {
      if (mounted) Navigator.of(context).maybePop();
      return;
    }

    selectImage(photo);
  }

  selectImage(img.Image photo) {
    if (photo.width > NotePhotoSize.large.size.width) {
      photo = img.copyResize(photo, width: NotePhotoSize.large.size.width.round());
    }
    if (photo.height > NotePhotoSize.large.size.height) {
      photo = img.copyResize(photo, height: NotePhotoSize.large.size.height.round());
    }

    final bytes = img.encodePng(photo);
    widget.onCompleted(base64.encode(bytes));
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // region Sheet's header
          Container(
            padding: const EdgeInsets.only(top: 20),
            child: const Text(
              'Add a photo...',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Do you want to add an existing photo from your library or capture a photo using your camera?',
              style: TextStyle(color: Colors.white.withOpacity(.8)),
              textAlign: TextAlign.center,
            ),
          ),
          // endregion

          // region Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: widget.onCancel,
                child: Column(
                  children: const [
                    Icon(Bootstrap.arrow_left, color: Colors.white),
                    SizedBox(height: 5),
                    Text('Cancel', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              TextButton(
                onPressed: usePhotoLibrary,
                child: Column(
                  children: const [
                    Icon(Bootstrap.images, color: Colors.white),
                    SizedBox(height: 5),
                    Text('Photo Library', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              TextButton(
                onPressed: useCamera,
                child: Column(
                  children: const [
                    Icon(Bootstrap.camera, color: Colors.white),
                    SizedBox(height: 5),
                    Text('Use Camera', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          // endregion
        ],
      ),
    );
  }
}
