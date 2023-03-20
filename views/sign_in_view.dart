/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:flutter/material.dart';

class SignInView extends StatefulWidget {
  const SignInView({Key? key}) : super(key: key);

  @override
  SignInViewState createState() => SignInViewState();
}

class SignInViewState extends State<SignInView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  height: 300,
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0x4403fd91), Color(0x1103fd91)])),
                  child: Column(),
                ),
              ),
              ClipPath(
                clipper: WaveClipper3(),
                child: Container(
                  width: double.infinity,
                  height: 300,
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0x1100a3fc), Color(0x4400a3fc)])),
                  child: Column(),
                ),
              ),
              ClipPath(
                clipper: WaveClipper1(),
                child: Container(
                  width: double.infinity,
                  height: 300,
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xff322c39), Color(0xff7546ba)])),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 55),
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
          const SizedBox(height: 20),
          Container(
            width: MediaQuery.of(context).size.width,
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Material(
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                  child: TextField(
                    onChanged: (String value) {},
                    cursorColor: Colors.deepPurpleAccent,
                    decoration: const InputDecoration(
                        labelText: "Email",
                        prefixIcon: Material(
                          elevation: 0,
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          child: Icon(
                            Icons.email,
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 25)),
                  ),
                ),
                const SizedBox(height: 20),
                Material(
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                  child: TextField(
                    onChanged: (String value) {},
                    cursorColor: Colors.deepPurpleAccent,
                    decoration: const InputDecoration(
                        labelText: "Password",
                        prefixIcon: Material(
                          elevation: 0,
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          child: Icon(
                            Icons.lock,
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 25)),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                    ),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                  ),
                  onPressed: () => Navigator.popAndPushNamed(context, '/libraries'),
                  // borderRadius: BorderRadius.all(Radius.circular(30)),
                  child: const Text(
                    "Login",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Center(
            child: Text(
              "FORGOT PASSWORD ?",
              style: TextStyle(color: Colors.deepPurpleAccent, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Text(
                "Don't have an Account ? ",
                style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.normal),
              ),
              Text("Sign Up ",
                  style: TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.w500, fontSize: 12, decoration: TextDecoration.underline)),
            ],
          )
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
