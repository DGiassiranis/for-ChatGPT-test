

import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:notebars/classes/book_note.dart';
import 'package:notebars/classes/book_paragraph.dart';
import 'package:notebars/classes/icon/constant/icon_constant.dart';
import 'package:notebars/getx/controller/note_photo_select_controller.dart';
import 'package:notebars/widgets/notes/icon_select_category_widget.dart';
import 'package:notebars/widgets/notes/icon_select_svg_widget.dart';

class NotePhotoSelectSheetV2 extends StatelessWidget {
  const NotePhotoSelectSheetV2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NotePhotoSelectController controller = NotePhotoSelectController.find;
    final bgColor = BookParagraph.colors[controller.paragraph.color]
        ?[BookParagraph.colorBackKeywords];
    final bgIconColor = BookParagraph.colors[controller.paragraph.color]
        ?[BookParagraph.colorTextPrimary];
    const double spaceBetweenVertical = 15;
    const double selectImageIconSize = 30;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    double iconSize = sqrt((screenWidth*screenHeight*0.55)/(50))*0.75;

    final double wrapSpacing = iconSize/2;
    return Container(
      width: MediaQuery.of(context).size.width * 0.98,
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      color: bgColor,
      child: SingleChildScrollView(
        controller: ScrollController(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              // height: MediaQuery.of(context).size.height * 0.16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: controller.usePhotoLibrary,
                    style: TextButton.styleFrom(
                      backgroundColor: bgIconColor,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          color: bgColor,
                          size: selectImageIconSize,
                        ),
                        const SizedBox(height: 5),
                        Text('Photo Library', style: TextStyle(color: bgColor)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: controller.viaImageUrl,
                    style: TextButton.styleFrom(
                      backgroundColor: bgIconColor,
                      fixedSize: Size.fromWidth(MediaQuery.of(context).size.width * .25)
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          color: bgColor,
                          size: selectImageIconSize,
                        ),
                        const SizedBox(height: 5),
                        Text('Image URL', style: TextStyle(color: bgColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: spaceBetweenVertical,
            ),
            Container(
              height: 1,
              width: double.infinity,
              color: bgIconColor,
            ),
            SizedBox(
              width: double.infinity,
              child: ObxValue((Rx<IconCategoryModel> selectedCategory) => selectedCategory.value.isNullCategory ? Text(
                '...or Select a Group of Symbols',
                style: TextStyle(fontSize: 11, color: bgIconColor),
                textAlign: TextAlign.start,
              ) : Text(
                'Select a symbol',
                style: TextStyle(fontSize: 11, color: bgIconColor),
                textAlign: TextAlign.start,
              ), controller.selectedCategory),
            ),
            ObxValue((Rx<IconCategoryModel> selectedCategory) {
              return !selectedCategory.value.isNullCategory ? IconSelectSvgWidget(
                wrapSpacing: wrapSpacing,
                iconColor: bgIconColor ?? Colors.white,
                iconSize: iconSize,
                onIconTap: controller.onCompletedAsset,
                categoryModel: controller.selectedCategory.value,
              ) : IconSelectCategoryWidget(
                onDeleteIconTap: () {},
                wrapSpacing: wrapSpacing,
                iconColor: bgIconColor ?? Colors.white,
                iconSize: iconSize,
                onCategoryTap: (category) =>
                controller.selectedCategory.value = category,
              );
            }, controller.selectedCategory),
            Container(
              height: 1,
              width: double.infinity,
              color: bgIconColor,
            ),

            Row(
              children: [
                Material(
                  color: Colors.transparent,
                  child: ObxValue(
                          (Rx<NotePhotoSize> photoSize) => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Size',
                            style: TextStyle(
                              color: bgIconColor,
                            ),
                          ),
                          Transform.scale(
                            scale: 0.75,
                            child: Radio<NotePhotoSize>(
                              activeColor: bgIconColor,
                              value: NotePhotoSize.small,
                              groupValue: photoSize.value,
                              onChanged: (value) {
                                if (value == null) return;
                                controller.photoSize.value = value;
                              },
                            ),
                          ),
                          Transform.scale(
                            scale: 0.75,
                            child: Radio<NotePhotoSize>(
                              activeColor: bgIconColor,
                              value: NotePhotoSize.medium,
                              groupValue: photoSize.value,
                              onChanged: (value) {
                                if (value == null) return;
                                controller.photoSize.value = value;
                              },
                            ),
                          ),
                          Transform.scale(
                            scale: 0.75,
                            child: Radio<NotePhotoSize>(
                              activeColor: bgIconColor,
                              value: NotePhotoSize.large,
                              groupValue: photoSize.value,
                              onChanged: (value) {
                                if (value == null) return;
                                controller.photoSize.value = value;
                              },
                            ),
                          ),
                        ],
                      ),
                      controller.photoSize),
                ),
                const Spacer(),
                Obx(() =>                 TextButton(
                  style: TextButton.styleFrom(
                      side: BorderSide(
                        color: bgIconColor ?? Colors.transparent,
                      )
                  ),
                  onPressed: controller.onCancel,
                  child: controller.selectedCategory.value.isNullCategory ? Text(
                    'Cancel',
                    style: TextStyle(color: bgIconColor),
                  ) : Icon(
                    CupertinoIcons.arrow_left,
                    color: bgIconColor,
                    size: 20,
                  ),
                )
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
