/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  AppDrawerState createState() => AppDrawerState();
}

class AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(24, 18, 38, 1.0), // Color(0xff2c274c),
              Color.fromRGBO(30, 92, 164, 1.0), //Color(0xff46426c),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
                flex: 1,
                child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: SafeArea(
                        child: DrawerHeader(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          stops: [0.0, 0.5, 1.0],
                          tileMode: TileMode.clamp,
                          colors: <Color>[Colors.lightBlueAccent, Color.fromRGBO(30, 92, 164, 1.0), Colors.lightGreenAccent],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 8.0, // soften the shadow
                            spreadRadius: 2.0, //extend the shadow
                            offset: Offset(
                              -5.0, // Move to right 10  horizontally
                              5.0, // Move to bottom 10 Vertically
                            ),
                          )
                        ],
                      ),
                      child: Column(
                        children: const <Widget>[
                          SizedBox(height: 10.0),
                          Text(
                            "You are not signed in.",
                            style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500, color: Colors.white),
                          ),
                        ],
                      ),
                    )))),
            Expanded(
              flex: 2,
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  ListTile(
                      leading: Icon(Icons.login, color: Colors.lightBlue[200]),
                      title: const Text("Sign-in", style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.of(context).pushNamed('/sign-in');
                      }),
                  ListTile(
                      leading: Icon(Icons.settings, color: Colors.lightBlue[200]),
                      title: const Text("Settings", style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.of(context).pushNamed('/settings');
                      }),
                ],
              ),
            ),
            SafeArea(
                child: Column(
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationIcon: Image.asset(
                          'assets/images/expo-logo.png',
                          height: 50,
                        ),
                        applicationName: 'Event Operator',
                        applicationVersion: 'December 2020',
                        applicationLegalese: '\u{a9} 2020 Enfinity Software FZ LLC',
                        children: <Widget>[
                          const SizedBox(height: 24),
                          RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                    style: Theme.of(context).textTheme.bodyText2,
                                    text: 'ExpoSystem tracks the attendance to '
                                        'your events, conferences and shows, in real-time. '
                                        'Visitors and attendees can register either online, on-site or via our mobile app. '
                                        'Learn more about our ExpoSystem platform at '),
                                TextSpan(style: Theme.of(context).textTheme.bodyText2, text: 'https://www.exposystem.io'),
                                TextSpan(style: Theme.of(context).textTheme.bodyText2, text: '.'),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                    child: Image.asset(
                      'assets/images/expo-logo.png',
                      height: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 20)
              ],
            ))
          ],
        ),
      ),
    );
  }
}
