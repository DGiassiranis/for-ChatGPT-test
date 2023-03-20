

import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/instance_manager.dart';
import 'package:notebars/classes/book_paragraph.dart';
import 'package:notebars/classes/icon/constant/icon_constant.dart';

class NoteSymbolSelectController extends GetxController{

  static NoteSymbolSelectController get find => Get.find();

  Rx<IconCategoryModel> selectedCategory = IconCategoryModel.nullCategory.obs;
  late BookParagraph paragraph;
  late Function(String path) onCompletedAsset;
  late Function() onDeleteSymbol;

  void initialize({required BookParagraph paragraph, required Function(String path) onCompletedAsset, required Function() onDeleteSymbol}) {
    selectedCategory.value = IconCategoryModel.nullCategory;
    this.paragraph = paragraph;
    this.onCompletedAsset = onCompletedAsset;
    this.onDeleteSymbol = onDeleteSymbol;
  }

  void onCancel() {
    selectedCategory.value.isNullCategory ? Get.back() : selectedCategory.value = IconCategoryModel.nullCategory;
  }
}