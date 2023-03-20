import 'package:flutter/material.dart';
import 'package:notebars/classes/book_note.dart';

class PreviewBottomActions extends StatelessWidget {
  const PreviewBottomActions({
    Key? key,
    required this.onChangeSize,
    required this.onReplace,
    required this.onDelete,
    required this.bgIconColor,
    required this.bgColor,
    required this.imageData,
    required this.photoSize,
  }) : super(key: key);

  final Function(NotePhotoSize size) onChangeSize;
  final Function() onReplace;
  final Function() onDelete;
  final Color bgIconColor;
  final Color bgColor;
  final String imageData;
  final NotePhotoSize photoSize;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        _changeSizeRow,
        const SizedBox(width: 25,),
        TextButton(
          style: TextButton.styleFrom(
              side: BorderSide(
                color: bgIconColor,
              )
          ),
          onPressed: onReplace,
          child: Text(
            'Replace',
            style: TextStyle(color: bgIconColor),
          ),
        ),
      ],
    );
  }

  Widget get _changeSizeRow => Material(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Size',
              style: TextStyle(
                fontSize: 16,
                color: bgIconColor,
              ),
            ),

            Radio<NotePhotoSize>(
              activeColor: bgIconColor,
              value: NotePhotoSize.small,
              groupValue: photoSize,
              onChanged: (value) {
                if (value == null) return;
                onChangeSize(value);
              },
            ),
            Radio<NotePhotoSize>(
              activeColor: bgIconColor,
              value: NotePhotoSize.medium,
              groupValue: photoSize,
              onChanged: (value) {
                if (value == null) return;
                onChangeSize(value);
              },
            ),

            Radio<NotePhotoSize>(
              activeColor: bgIconColor,
              value: NotePhotoSize.large,
              groupValue: photoSize,
              onChanged: (value) {
                if (value == null) return;
                onChangeSize(value);
              },
            ),
          ],
        ),
      );
}
