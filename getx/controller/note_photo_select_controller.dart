
import 'dart:convert';
import 'dart:io';

import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notebars/api/image_service.dart';
import 'package:notebars/classes/book_note.dart';
import 'package:notebars/classes/book_paragraph.dart';
import 'package:notebars/classes/icon/constant/icon_constant.dart';
import 'package:image/image.dart' as img;

class NotePhotoSelectController extends GetxController{

  static NotePhotoSelectController get find => Get.find();

  Rx<IconCategoryModel> selectedCategory = IconCategoryModel.nullCategory.obs;

  final ImageService _imageService = ImageService.find;

  late BookParagraph paragraph;
  late Function(String byteData) onCompleted;
  late Function(String path) onCompletedAsset;
  Rx<NotePhotoSize> photoSize = NotePhotoSize.small.obs;

  void initialize({required BookParagraph paragraph, required Function(String byteData) onCompleted, required Function(String path) onCompletedAsset}) {
    selectedCategory.value = IconCategoryModel.nullCategory;
    this.paragraph = paragraph;
    this.onCompleted = onCompleted;
    this.onCompletedAsset = onCompletedAsset;
  }

  void onCancel() {
    selectedCategory.value.isNullCategory ? Get.back() : selectedCategory.value = IconCategoryModel.nullCategory;
  }

  void usePhotoLibrary() async {

    final img.Image? photo = Platform.isWindows ? await getLocalImageFromWindows() : await getLocalImage();

    if (photo == null) {
      Get.back();
      return;
    }
    selectImage(photo);
  }

  Future<img.Image?> getLocalImageFromWindows() async {
    FilePickerCross file = await FilePickerCross.importFromStorage(
        type: FileTypeCross.image,
        fileExtension: 'jpg, jpeg, png, svg'
    );

    return img.decodeImage(file.toUint8List());
  }

  Future<img.Image?> getLocalImage() async {
    final XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) {
      return null;
    }
    return img.decodeImage(await file.readAsBytes());
  }

  selectImage(img.Image photo) {
    if (photo.width > NotePhotoSize.larger.size.width) {
      photo = img.copyResize(photo, width: NotePhotoSize.larger.size.width.round());
    }
    if (photo.height > NotePhotoSize.larger.size.height) {
      photo = img.copyResize(photo, height: NotePhotoSize.larger.size.height.round());
    }

    final bytes = img.encodePng(photo);
    onCompleted(base64.encode(bytes));
  }

  void useCamera() async {
    final XFile? file = await ImagePicker().pickImage(source: ImageSource.camera);
    if (file == null) {
      Get.back();
      return;
    }

    final img.Image? photo = img.decodeImage(await file.readAsBytes());
    if (photo == null) {
      Get.back();
      return;
    }

    selectImage(photo);
  }

  void viaImageUrl() async {

    final ClipboardData? text = await Clipboard.getData(Clipboard.kTextPlain);

    if(!isTextValidated(text)){
      showFailureMessage();
      return;
    }

    final image = await _imageService.downloadImage(text!.text!);
    if(image == null){
      showFailureMessage();
      return;
    }

    try{
      final img.Image? photo = img.decodeImage(image);
      selectImage(photo!);
    }catch(_){
      showFailureMessage();
    }
  }

  bool isTextValidated(ClipboardData? text){
    if(text == null || text.text == null || (text.text ?? '').isEmpty) {
      return false;
    }

    if(!(Uri.tryParse((text.text ?? ''))?.hasAbsolutePath ?? true)){
      return false;
    }

    return true;
  }

  void showFailureMessage() {
    Get.showSnackbar(const GetSnackBar(
      title: 'Failure',
      message: 'It seems that the content in your clipboard does not represent an Image Url',
      duration: Duration(seconds: 2),
    ),);

  }







}