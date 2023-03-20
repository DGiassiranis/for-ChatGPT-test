

import 'package:dio/dio.dart';

class DioClient {

  static const httpStatusOk = 200;

  final Dio dioClient = Dio(
      BaseOptions(
    connectTimeout: 5000,
    receiveTimeout: 5000,
    validateStatus: (status) {
      return true;
    },
  ));

}