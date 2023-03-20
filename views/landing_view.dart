/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:aneya_core/core.dart';
import 'package:aneya_responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/route_manager.dart';
import 'package:notebars/common/setting_constant.dart';
import 'package:notebars/getx/controller/sync_controller.dart';

import '../global.dart';

class LandingView extends StatefulWidget {
  const LandingView({Key? key}) : super(key: key);

  @override
  LandingViewState createState() => LandingViewState();
}

class LandingViewState extends State<LandingView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 1000), () async {
      Status status = await app.loadAppSettings();

      if (!mounted) return; // Ensure context is valid across async gaps

      if (status.isOK) {
        // region Auto-sign in silently to Google Drive

        app.googleSignInAccount = await app.googleSignIn.signInSilently(reAuthenticate: true,);
        // endregion


        if(app.settings[SettingConstant.syncWithGoogleDrive]){

          await SyncController.find.startTheSync();
          Get.offAndToNamed('/libraries');

        }else{
          if (!mounted) return;
          Navigator.of(context).popAndPushNamed('/libraries');
        }






        if (!mounted) return; // Ensure context is valid across async gaps
        if (status.message.isNotEmpty) app.showStatusSnackBar(context, status);
      } else {
        app.showStatusSnackBar(context, status);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: ListView(
        children: <Widget>[
          // region Logo & curves
          Stack(
            children: <Widget>[
              ClipPath(
                clipper: WaveClipper2(),
                child: Container(
                  width: double.infinity,
                  height: 50.vh(context),
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0x4403fd91), Color(0x1103fd91)])),
                  child: Column(),
                ),
              ),
              ClipPath(
                clipper: WaveClipper3(),
                child: Container(
                  width: double.infinity,
                  height: 50.vh(context),
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0x1100a3fc), Color(0x4400a3fc)])),
                  child: Column(),
                ),
              ),
              ClipPath(
                clipper: WaveClipper1(),
                child: Container(
                  width: double.infinity,
                  height: 50.vh(context),
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xff322c39), Color(0xff7546ba)])),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 20.vh(context) - 50,
                      ),
                      Flex(
                        direction: Axis.horizontal,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/logo-with-text.png', height: 100),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // endregion
          SizedBox(
            height: 25.vh(context) - 50,
          ),
          const Center(
            child: CircularProgressIndicator(color: Color(0xff322c39)),
          ),
          const SizedBox(
            height: 15,
          ),
          Center(child: ObxValue((Rx<String> message) => Text(message.value), SyncController.find.message))
        ],
      ),
    );
  }
}

class WaveClipper1 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height - 50);

    var firstEndPoint = Offset(size.width * 0.6, size.height - 29 - 50);
    var firstControlPoint = Offset(size.width * .25, size.height - 60 - 50);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    var secondEndPoint = Offset(size.width, size.height - 60);
    var secondControlPoint = Offset(size.width * 0.84, size.height - 50);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class WaveClipper3 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height - 50);

    var firstEndPoint = Offset(size.width * 0.6, size.height - 15 - 50);
    var firstControlPoint = Offset(size.width * .25, size.height - 60 - 50);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    var secondEndPoint = Offset(size.width, size.height - 40);
    var secondControlPoint = Offset(size.width * 0.84, size.height - 30);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class WaveClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height - 50);

    var firstEndPoint = Offset(size.width * .7, size.height - 40);
    var firstControlPoint = Offset(size.width * .25, size.height);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    var secondEndPoint = Offset(size.width, size.height - 45);
    var secondControlPoint = Offset(size.width * 0.84, size.height - 50);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
