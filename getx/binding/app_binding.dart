
import 'package:get/instance_manager.dart';
import 'package:notebars/api/image_service.dart';
import 'package:notebars/dio_client.dart';
import 'package:notebars/getx/controller/app_controller.dart';
import 'package:notebars/getx/controller/book_select_icon_controller.dart';
import 'package:notebars/getx/controller/deleted_books_controller.dart';
import 'package:notebars/getx/controller/editing_paragraph_controller.dart';
import 'package:notebars/getx/controller/network_controller.dart';
import 'package:notebars/getx/controller/note_photo_select_controller.dart';
import 'package:notebars/getx/controller/note_symbol_select_controller.dart';
import 'package:notebars/getx/controller/sync_controller.dart';

class AppBinding extends Bindings{

  @override
  void dependencies() {
    Get.put(DioClient());
    Get.put(ImageService(Get.find()));
    Get.put(NetworkController());
    Get.put(AppController());
    Get.put(SyncController());
    Get.put(DeletedBooksController());
    Get.put(NotePhotoSelectController());
    Get.put(NoteSymbolSelectController());
    Get.put(BookSelectIconController());
    Get.put(EditingParagraphController());
  }

}