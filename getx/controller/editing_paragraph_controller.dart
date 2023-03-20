
import 'package:get/get.dart';
import 'package:notebars/classes/book_paragraph.dart';

class EditingParagraphController extends GetxController{

  static EditingParagraphController get find => Get.find();

  Rx<bool> isTitle  = false.obs;
  Rx<bool> isLarge = false.obs;
  Rx<bool> isBold = false.obs;
  Rx<bool> isItalic = false.obs;
  Rx<bool> hasBackground = false.obs;
  Rx<String> selectedBackgroundColor = 'no_color_selected'.obs;
  bool hasBeenInitialized = false;

  Function()? onApply;
  Function()? onCancel;

  void initialize(BookParagraph paragraph, Function() onApply, Function() onCancel,) {
    this.onApply = onApply;
    this.onCancel = onCancel;
    hasBeenInitialized = true;
    if(!paragraph.hasAppliedStyling) return;

    isTitle.value = paragraph.isTitle;
    isLarge.value = paragraph.isLarge;
    isBold.value =  paragraph.isBold;
    isItalic.value = paragraph.isItalic;
    hasBackground.value = paragraph.hasBackground;
    selectedBackgroundColor.value = paragraph.hasBackground ? paragraph.color : selectedBackgroundColor.value;

    if(selectedBackgroundColor.value.isEmpty){
      selectedBackgroundColor.value = 'no_color_selected';
    }
  }


}