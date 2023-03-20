


import 'dart:typed_data';

import 'package:get/get.dart' hide Response;
import 'package:notebars/dio_client.dart';
import 'package:http/http.dart' as http;

class ImageService{

  static ImageService get find => Get.find();

  ImageService(this.dioClient);

  final DioClient dioClient;

  Future<Uint8List?> downloadImage(String url) async {

    final response = await http.get(Uri.parse(url));

    if(response.statusCode != DioClient.httpStatusOk) return null;

    return response.bodyBytes;
  }

}