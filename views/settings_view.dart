
import 'dart:io';

import 'package:aneya_core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:notebars/common/route_constant.dart';
import 'package:notebars/common/setting_constant.dart';
import 'package:notebars/getx/controller/app_controller.dart';
import 'package:notebars/getx/controller/deleted_books_controller.dart';
import 'package:notebars/getx/controller/sync_controller.dart';

import '../global.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  SettingsViewState createState() => SettingsViewState();
}

const bool capitalizedEnabledDefault = true;
const double paragraphLineHeightDefaultValue = 1.8;
const double notebarsDefaultFontMultiplier = 1.2;
const double notebarsSmallFontMultiplier = 1.0;
const double notebarsVerySmallFontMultiplier = 0.8;
const double notebarsLargeFontMultiplier = 1.4;
const double notebarsVeryLargeFontMultiplier = 1.6;

class SettingsViewState extends State<SettingsView> {
  double stickyNoteOpacityValue = 0;

  get settings => app.settings;

  bool get textJustified => settings['textAlign'] == 'justify';

  bool get capitalizedEnabled =>
      settings['capitalizedEnabled'] ?? capitalizedEnabledDefault;

  bool get automatedStudying => settings['automatedStudying'] ?? false;

  bool get smartChapterCreation => settings['smartChapterCreation'] ?? true;

  int get quickChangeState => !((settings['quickChangeState'] ?? 3) < 3 ||
          (settings['quickChangeState'] ?? 3) * 1.0 > 9)
      ? settings['quickChangeState'] ?? 3
      : 3;

  bool get googleDriveSync =>
      settings[SettingConstant.syncWithGoogleDrive] == true;

  String get textSize => settings['appFontSize'] <= 14
      ? 'Small'
      : (settings['appFontSize'] >= 22 ? 'Extra Large' : settings['appFontSize'] > 20 ? 'Very Large' : settings['appFontSize'] > 18 ? 'Large' : 'Normal');

  double roundedMultipliedWith1000(double value){
    return ((value) * 1000).roundToDouble();
  }

  String get notebarsFontSize {
    double size = settings['notebarsFontSize'];

    double sizeMultipliedBy1000Rounded = (size * 1000).roundToDouble();

    if(sizeMultipliedBy1000Rounded == roundedMultipliedWith1000(notebarsVerySmallFontMultiplier)){
      return 'Very small';
    }

    if(sizeMultipliedBy1000Rounded == roundedMultipliedWith1000(notebarsSmallFontMultiplier)){
      return 'Small';
    }
    if(sizeMultipliedBy1000Rounded == roundedMultipliedWith1000(notebarsLargeFontMultiplier)){
      return 'Large';
    }
    if(sizeMultipliedBy1000Rounded == roundedMultipliedWith1000(notebarsVeryLargeFontMultiplier)){
      return 'Very Large';
    }

    return 'Normal';

  }

  String get paragraphTextSize {
    double size = settings['appFontSize'];

    double sizeMultipliedBy1000Rounded = (size * 1000).roundToDouble();

    if(sizeMultipliedBy1000Rounded == roundedMultipliedWith1000(14)){
      return 'Small';
    }

    if(sizeMultipliedBy1000Rounded == roundedMultipliedWith1000(16)){
      return 'Normal';
    }
    if(sizeMultipliedBy1000Rounded == roundedMultipliedWith1000(18)){
      return 'Large';
    }
    if(sizeMultipliedBy1000Rounded == roundedMultipliedWith1000(20)){
      return 'Very Large';
    }

    return 'Extra Large';

  }

  String get readingSpeed => settings['readingSpeed'] == 0
      ? 'Slow'
      : (settings['readingSpeed'] == 2 ? 'Fast' : 'Normal');

  String get stickyNoteOpacity => settings['noteStickyOpacity'] == 0
      ? 'Off'
      : (settings['noteStickyOpacity'] == 1 ? 'Visible' : 'Transparent');

  double get paragraphLineHeight =>
      settings['paragraphLineHeight'] ?? paragraphLineHeightDefaultValue;

  Future<void> googleSignInMethod() async {

    try {

      app.googleSignInAccount = await app.googleSignIn.signIn();

    } catch (e) {
      app.showStatusSnackBar(
          context,
          Status(false,
              message:
                  'Error signing in to your Google Drive account. Details: $e'));
    }
  }

  showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('SIGN OUT'),
        content: const Text('If you sing out, all your data will be erased'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                signOutAction();
              },
              child: const Text('SIGN OUT'))
        ],
      ),
    );
  }

  Future<void> _handleSignIn() async {
    try {
      if (app.googleSignInAccount != null) {
        // Auto-set notebarsFolderId
        await app.drive.fetchNotebarsFolderId();

        setState(() {
          settings[SettingConstant.syncWithGoogleDrive] = true;
          settings["googleAuthToken"] = app.googleSignInAccount!.serverAuthCode;
        });

        AppController.find.synchronizeFirstTimeV2();
      }
    } catch (e) {
      app.showStatusSnackBar(
          context,
          Status(false,
              message:
                  'Error signing in to your Google Drive account. Details: $e'));
    }
  }

  @override
  Widget build(BuildContext context) {
    stickyNoteOpacityValue = settings['noteStickyOpacity'] == 0
        ? 0
        : (settings['noteStickyOpacity'] == 1 ? 2 : 1);

    bool disabledSync = app.googleSignInAccount == null;
    return Scaffold(
      backgroundColor: const Color(0xffdbe2e7),
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(10),
        children: <Widget>[
          const SizedBox(height: 10),
          const Text("TEXT OPTIONS",
              style: TextStyle(
                  color: Colors.deepPurple, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListTile(
            tileColor: Colors.white54,
            title: const Text('Paragraph\'s line height',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Adjust the paragraph\'s line height',
                    style: TextStyle(color: Colors.grey)),
                Text(((paragraphLineHeight * 10) / 10).toString(),
                    style: const TextStyle(
                        color: Colors.deepPurpleAccent,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            leading: const Icon(Icons.height),
            isThreeLine: true,
            trailing: SizedBox(
              width: 100,
              child: Slider(
                value: settings['paragraphLineHeight'] ??
                    paragraphLineHeightDefaultValue,
                min: 1.7,
                max: 1.9,
                divisions: 2,
                label: paragraphTextSize,
                onChanged: (value) => setState(() {
                  settings['paragraphLineHeight'] = value;
                }),
              ),
            ),
          ),
          ListTile(
            tileColor: Colors.white54,
            title: const Text('Paragraph\'s text size',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Adjust the font size of texts.',
                    style: TextStyle(color: Colors.grey)),
                Text(
                    paragraphTextSize,
                    style: const TextStyle(
                        color: Colors.deepPurpleAccent,
                        fontWeight: FontWeight.bold),),
              ],
            ),
            leading: const Icon(Icons.format_size),
            isThreeLine: true,
            trailing: SizedBox(
              width: 100,
              child: Slider(
                value: settings['appFontSize'] ?? 16.0,
                min: 14,
                max: 22,
                divisions: 4,
                label: paragraphTextSize,
                onChanged: (value) => setState(() {
                  settings['appFontSize'] = value;
                }),
              ),
            ),
          ),
          ListTile(
            tileColor: Colors.white54,
            leading: const Icon(Icons.format_align_left),
            title: const Text('Capitalized Notes on paragraph',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    'Enable if you want the keys and the notes to be at the same case as the note bars',
                    style: TextStyle(color: Colors.grey)),
                Text(
                  capitalizedEnabled ? 'Enabled' : 'Disabled',
                  style: const TextStyle(
                      color: Colors.deepPurpleAccent,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            isThreeLine: true,
            trailing: SizedBox(
              width: 100,
              child: Switch(
                value: capitalizedEnabled,
                onChanged: (value) => setState(() {
                  settings['capitalizedEnabled'] = value;
                }),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text("NOTE OPTIONS",
              style: TextStyle(
                  color: Colors.deepPurple, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListTile(
            tileColor: Colors.white54,
            title: const Text('Notebars rows height',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            subtitle:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Adjust the height of each note row.',
                  style: TextStyle(color: Colors.grey)),
              Text('${settings['noteRowHeight']} pixels',
                  style: const TextStyle(
                      color: Colors.deepPurpleAccent,
                      fontWeight: FontWeight.bold)),
            ]),
            leading: const Icon(Icons.height),
            isThreeLine: true,
            trailing: SizedBox(
              width: 100,
              child: Slider(
                value: settings['noteRowHeight'],
                min: 40,
                max: 80,
                divisions: 4,
                label: '${settings['noteRowHeight']} pixels',
                onChanged: (value) => setState(() {
                  settings['noteRowHeight'] = value;
                }),
              ),
            ),
          ),
          ListTile(
            tileColor: Colors.white54,
            title: const Text('Notebars text size',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Adjust the font size of notebars.',
                    style: TextStyle(color: Colors.grey)),
                Text(notebarsFontSize,
                    style: const TextStyle(
                        color: Colors.deepPurpleAccent,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            leading: const Icon(Icons.format_size),
            isThreeLine: true,
            trailing: SizedBox(
              width: 100,
              child: Slider(
                value: settings['notebarsFontSize'] ?? notebarsVeryLargeFontMultiplier,
                min: notebarsVerySmallFontMultiplier,
                max: notebarsVeryLargeFontMultiplier,
                divisions: 4,
                label: notebarsFontSize,
                onChanged: (value) => setState(() {
                  settings['notebarsFontSize'] = value;
                }),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text("READING OPTIONS",
              style: TextStyle(
                  color: Colors.deepPurple, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListTile(
            tileColor: Colors.white54,
            title: const Text('Default reading speed',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    'Adjust the speed of highlighting words in the text.',
                    style: TextStyle(color: Colors.grey)),
                Text(readingSpeed,
                    style: const TextStyle(
                        color: Colors.deepPurpleAccent,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            leading: const Icon(Icons.speed),
            isThreeLine: true,
            trailing: SizedBox(
              width: 100,
              child: Slider(
                value: settings['readingSpeed'],
                min: 0,
                max: 2,
                label: readingSpeed,
                onChanged: (value) => setState(() {
                  settings['readingSpeed'] = value;
                }),
              ),
            ),
          ),
          ListTile(
            onTap: () {
              DeletedBooksController.find.fetchDeletedBooks();
              Get.toNamed(RouteConstant.deletedBooksRoute)?.then((value) async {
                if (!mounted) {
                  return;
                }
              });
            },
            tileColor: Colors.white54,
            title: const Text('Deleted books',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('You can restore any deleted book.',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
            leading: const Icon(Icons.folder_delete_outlined),
            isThreeLine: true,
          ),
          const SizedBox(height: 20),
          const Text("BOOK OPTIONS",
              style: TextStyle(
                  color: Colors.deepPurple, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListTile(
            tileColor: Colors.white54,
            title: const Text('Smart chapter creation',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    'Numbers and symbols in auto-generated title of a chapter are removed',
                    style: TextStyle(color: Colors.grey)),
                Text(smartChapterCreation ? 'Active' : 'Inactive',
                    style: const TextStyle(
                        color: Colors.deepPurpleAccent,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            leading: const Icon(Icons.fiber_smart_record_outlined),
            isThreeLine: true,
            trailing: SizedBox(
              width: 100,
              child: Switch(
                value: smartChapterCreation,
                onChanged: (value) => setState(() {
                  settings['smartChapterCreation'] = !smartChapterCreation;
                }),
              ),
            ),
          ),
          ListTile(
            tileColor: Colors.white54,
            title: const Text('Skip Reps',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Skip steps and set the first iteration point.',
                    style: TextStyle(color: Colors.grey)),
                Text("$quickChangeState reps will be skipped",
                    style: const TextStyle(
                        color: Colors.deepPurpleAccent,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            leading: const Icon(Icons.skip_next_outlined),
            isThreeLine: true,
            trailing: SizedBox(
              width: 120,
              child: Slider(
                value: quickChangeState * 1.0,
                min: 3,
                max: 9,
                label: readingSpeed,
                onChanged: (value) => setState(() {
                  settings['quickChangeState'] = value.round().toInt();
                }),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text("BACKUP OPTIONS",
              style: TextStyle(
                  color: Colors.deepPurple, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListTile(
            tileColor: Colors.white54,
            leading: const Icon(Icons.cloud_upload_outlined),
            title: const Text('Google Drive Backup',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    'Save a backup of your libraries and books in Google Drive.',
                    style: TextStyle(color: Colors.grey)),
                Text(
                  googleDriveSync ? 'On' : 'Off',
                  style: const TextStyle(
                      color: Colors.deepPurpleAccent,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            isThreeLine: true,
            trailing: SizedBox(
              width: 100,
              child: Switch(
                value: googleDriveSync,
                onChanged: disabledSync
                    ? null
                    : (value) async {
                        if (!googleDriveSync) {
                          if (!(await SyncController.find.checkNetwork())) {
                            return;
                          }
                        }

                        setState(() {
                          AppController.find.googleSyncEnabled.value = true;
                          if (settings["googleAuthToken"] == "" && app.authHeaders == null) {
                            _handleSignIn();
                          } else {
                            setState(() =>
                                settings[SettingConstant.syncWithGoogleDrive] =
                                    value);
                            if (settings[SettingConstant.syncWithGoogleDrive]) {
                              AppController.find.synchronizeFirstTimeV2();
                            }

                            app.notifySettingsChanged();
                          }
                        });
                      },
              ),
            ),
          ),
          const SizedBox(height: 10),
          disabledSync
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/google_drive_logo.png',
                        height: 20,
                        width: 20,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
                        'Sign in with Google',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    await googleSignInMethod();
                    setState(() {});
                  },
                )
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/google_drive_logo.png',
                        height: 20,
                        width: 20,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
                        'SIGN OUT',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    showSignOutDialog();
                    // await app.clearData();
                    // await app.googleSignIn.signOut();
                    // settings["googleAuthToken"] == "";
                  },
                ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Future<void> signOutAction() async {
    await app.clearData();
    await app.googleSignIn.signOut();
    settings[SettingConstant.syncWithGoogleDrive] = false;
    settings["googleAuthToken"] = "";
    app.googleSignInAccount = null;
    await app.saveAppSettings();
    setState(() {});
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    // Save settings before leaving the screen
    app.saveAppSettings();

    super.dispose();
  }
}
