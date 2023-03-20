

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:notebars/classes/book_note.dart';
import 'package:notebars/classes/book_paragraph.dart';
import 'package:notebars/extensions.dart';
import 'package:notebars/helpers/image_util.dart';
import 'package:notebars/widgets/notes/book_notes_widget_row.dart';

class NotebarImage extends StatefulWidget {
  const NotebarImage({Key? key, required this.note, required this.colormap, this.onPhotoTap, this.onDecreasePhotoSize, this.onIncreasePhotoSize, required this.hasSelectedWords}) : super(key: key);


  final BookNote note;
  final BookColorMap colormap;
  final VoidCallback? onPhotoTap;
  final VoidCallback? onDecreasePhotoSize;
  final VoidCallback? onIncreasePhotoSize;
  final bool hasSelectedWords;

  @override
  State<NotebarImage> createState() => _NotebarImageState();
}

class _NotebarImageState extends State<NotebarImage> {

  final Rx<Size> _size = const Size(0,0).obs;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      _fetchSizeAsync(constraints);
      return Container(
        padding: const EdgeInsets.only(bottom: 5),
        child: InkWell(
          splashColor: Colors.white,
          onTap: widget.onPhotoTap,
          child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: _size.value.width,
                height: _size.value.height,
                child: widget.note.hasAsset? SvgPicture.asset(widget.note.imageData,
                  color: widget.colormap[BookParagraph.colorTextPrimary],
                  height: BookNotesWidgetRow.rowHeight * widget.note.photoSize.heightMultiplier - 10,) : Image.memory(base64.decode(widget.note.imageData),
                    height: _size.value.height, width: _size.value.width, fit: BoxFit.fill,),
              ),
            ],
          )),
        ),
      );
    });
  }

  void _fetchSizeAsync(BoxConstraints constraints) async {
    _size.value = widget.note.hasAsset ? ImageUtil.fetchAppropriateSizeFromMaxHeightAndMaxWidth(context, maxHeight: constraints.maxHeight, maxWidth: constraints.maxWidth) : await ImageUtil.fetchAppropriateSizeForImage(widget.note.imageData, context, mounted, maxWidth: constraints.maxWidth, maxHeight: constraints.maxHeight);
  }

}
