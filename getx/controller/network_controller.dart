

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/instance_manager.dart';

class NetworkController extends GetxController{

  static NetworkController get find => Get.find();

  Rx<bool> isNetworkConnected = false.obs;

  @override
  void onInit() {
    super.onInit();

    getConnectionType();
    checkStatusListener();
  }

  Future<void> getConnectionType() async{

    ConnectivityResult connectivityStatus = await Connectivity().checkConnectivity();

    isNetworkConnected.value = connectivityStatus == ConnectivityResult.wifi || connectivityStatus == ConnectivityResult.mobile || connectivityStatus == ConnectivityResult.ethernet;
  }

  void checkStatusListener() {
    Connectivity().onConnectivityChanged.listen((event) {
      isNetworkConnected.value = event == ConnectivityResult.wifi || event == ConnectivityResult.mobile || event == ConnectivityResult.ethernet;
    });
  }
}