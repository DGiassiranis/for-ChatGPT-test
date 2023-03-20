import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:notebars/classes/icon/constant/icon_constant.dart';
import 'package:notebars/getx/controller/book_select_icon_controller.dart';
import 'package:notebars/widgets/notes/icon_select_category_widget.dart';
import 'package:notebars/widgets/notes/icon_select_svg_widget.dart';

class BookSelectIconSheet extends StatelessWidget {
  const BookSelectIconSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BookSelectIconController controller =
        BookSelectIconController.find;
    const bgColor = Colors.deepPurpleAccent;
    const bgIconColor = Colors.white;
    const double spaceBetweenVertical = 15;
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
              child: ObxValue(
                      (Rx<IconCategoryModel> selectedCategory) => selectedCategory
                      .value.isNullCategory
                      ? const Text(
                    '...select a Group of symbols',
                    style: TextStyle(fontSize: 11, color: bgIconColor),
                    textAlign: TextAlign.start,
                  )
                      : const Text(
                    'Select a symbol',
                    style: TextStyle(fontSize: 11, color: bgIconColor),
                    textAlign: TextAlign.start,
                  ),
                  controller.selectedCategory),
            ),
            ObxValue((Rx<IconCategoryModel> selectedCategory) {
              return !selectedCategory.value.isNullCategory
                  ? IconSelectSvgWidget(
                wrapSpacing: wrapSpacing,
                iconColor: bgIconColor,
                iconSize: iconSize,
                onIconTap: controller.onCompletedAsset,
                categoryModel: controller.selectedCategory.value,
              )
                  : IconSelectCategoryWidget(
                hasDeleteIcon: true,
                onDeleteIconTap: controller.onDeleteSymbol,
                wrapSpacing: wrapSpacing,
                iconColor: bgIconColor,
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Obx(
                      () => TextButton(
                    style: TextButton.styleFrom(
                        side: const BorderSide(
                          color: bgIconColor,
                        )),
                    onPressed: controller.onCancel,
                    child: controller.selectedCategory.value.isNullCategory
                        ? const Text(
                      'Cancel',
                      style: TextStyle(color: bgIconColor),
                    )
                        : const Icon(
                      CupertinoIcons.arrow_left,
                      color: bgIconColor,
                      size: 20,
                    ),
                  ),
                ),
                Obx(
                      () => controller.selectedCategory.value.isNullCategory
                      ? const SizedBox(
                    width: 10,
                  )
                      : const SizedBox(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
