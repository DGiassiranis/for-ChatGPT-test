import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notebars/classes/book_note.dart';
import 'package:notebars/dialogs/preview_bottom_actions.dart';

class PreviewPhotoSheet extends StatelessWidget {
  const PreviewPhotoSheet({
    Key? key,
    required this.onChangeSize,
    required this.onReplace,
    required this.onDelete,
    required this.width,
    required this.height,
    required this.bgIconColor,
    required this.bgColor,
    required this.imageData,
    required this.photoSize,
  }) : super(key: key);

  final Function(NotePhotoSize size) onChangeSize;
  final Function() onReplace;
  final Function() onDelete;
  final double width;
  final double height;
  final Color bgIconColor;
  final Color bgColor;
  final String imageData;
  final NotePhotoSize photoSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      color: bgColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Spacer(),
          ConstrainedBox(
            constraints: BoxConstraints(
                minWidth : width,
                maxWidth : width,
                maxHeight : height,
                minHeight : height,
            ),
            child: Image.memory(
              base64.decode(imageData),
              fit: BoxFit.fill,
            ),
          ),
          PreviewBottomActions(
            onChangeSize: onChangeSize,
            onReplace: onReplace,
            onDelete: onDelete,
            bgIconColor: bgIconColor,
            bgColor: bgColor,
            imageData: imageData,
            photoSize: photoSize,
          ),
          const Spacer(),
        ],

      ),
    );
  }


}
