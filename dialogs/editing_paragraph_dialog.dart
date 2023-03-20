import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notebars/classes/book_paragraph.dart';
import 'package:notebars/common/theme_constant.dart';
import 'package:notebars/getx/controller/editing_paragraph_controller.dart';

class EditingParagraphDialog extends StatefulWidget {
  const EditingParagraphDialog({Key? key}) : super(key: key);

  @override
  State<EditingParagraphDialog> createState() => _EditingParagraphDialogState();
}

class _EditingParagraphDialogState extends State<EditingParagraphDialog> {
  EditingParagraphController controller = EditingParagraphController.find;



  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    double colorBoxSize = sqrt((screenWidth*screenHeight*0.55)/(100))*6;
    return AlertDialog(
      contentPadding: const EdgeInsets.all(10.0),
      actions: [
        TextButton(
          onPressed: controller.onCancel!,
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.deepPurpleAccent),
          ),
        ),
        ElevatedButton(
          onPressed: controller.onApply!,
          child: const Text('Apply'),
        ),
      ],
      content: Obx(() => SizedBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _radioButton(
                  controller.isTitle.value,
                      () {
                    controller.isTitle.value = !controller.isTitle.value;
                    if (controller.isTitle.value) {
                      controller.isLarge.value = false;
                      controller.isItalic.value = false;
                      controller.isBold.value = false;
                    }
                  },
                  'TITLE',
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 5,),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  runSpacing: 5,
                  children: [

                    _radioButton(
                      controller.isLarge.value,
                      () {
                        controller.isLarge.value = !controller.isLarge.value;
                        if (controller.isLarge.value) {
                          controller.isTitle.value = false;
                        }
                      },
                      'Large',
                      textStyle: const TextStyle(fontSize: 17),
                    ),

                    _radioButton(
                      controller.isBold.value,
                      () {
                        controller.isBold.value = !controller.isBold.value;
                        if (controller.isBold.value) {
                          controller.isTitle.value = false;
                        }
                      },
                      'Bold',
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    _radioButton(
                      controller.isItalic.value,
                          () {
                        controller.isItalic.value = !controller.isItalic.value;
                        if (controller.isItalic.value) {
                          controller.isTitle.value = false;
                        }
                      },

                      'Italic',
                      textStyle: const TextStyle(fontStyle: FontStyle.italic),
                    ),

                  ],
                ),
                const SizedBox(height: 15,),
                const Center(child: Text('Background')),
                const SizedBox(height: 10,),
                SizedBox(
                  height: 3*((colorBoxSize/6) - 10),
                  width: colorBoxSize,
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 6,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children:[
                      InkWell(
                        onTap: () {
                          controller.selectedBackgroundColor.value =  'no_color_selected';
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(
                                color: controller.selectedBackgroundColor.value == 'no_color_selected' ? Colors.black : Colors.grey,
                              )
                          ),
                          width: ThemeConstant.colorBoxSize,
                          height: ThemeConstant.colorBoxSize,
                        ),
                      ),
                      ...BookParagraph.lightColors.keys
                          .map(
                            (color) => InkWell(
                          onTap: () {
                            controller.selectedBackgroundColor.value = color;
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: BookParagraph
                                  .colors[color]![BookParagraph.colorBackKeywords],
                              border: Border.all(
                                color: controller.selectedBackgroundColor.value == color ? Colors.black : Colors.transparent,
                              )
                            ),
                            width: ThemeConstant.colorBoxSize,
                            height: ThemeConstant.colorBoxSize,
                          ),
                        ),
                      ).toList(),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Widget _radioButton(bool value, Function() onChanged, String title,
      {TextStyle? textStyle}) {
    return InkWell(
      onTap: onChanged,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: value ? Colors.black : Colors.transparent,
                borderRadius: BorderRadius.circular(100.0),
                border: Border.all(
                  color: Colors.black,
                )),
          ),
          const SizedBox(
            width: 3,
          ),
          Text(
            title,
            style: textStyle,
          ),
        ],
      ),
    );
  }
}
