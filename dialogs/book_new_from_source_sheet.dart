/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:notebars/global.dart';

import '../classes/book_library.dart';
import '../widgets/common/bottom_sheet_dialog.dart';

class BookNewFromSourceSheet extends StatelessWidget {
  final BookLibrary library;
  final VoidCallback? onCancel;
  final VoidCallback? onImportFromFile;
  final VoidCallback? onImportFromUrl;
  final VoidCallback? onImportFromClipboard;

  const BookNewFromSourceSheet({Key? key, required this.library, this.onImportFromFile, this.onImportFromUrl, this.onImportFromClipboard, this.onCancel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomSheetDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // region Sheet's header
          Container(
            padding: const EdgeInsets.only(top: 20),
            child: const Text(
              'Add a new book...',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              'Library: ${library.name}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Select an import method by tapping the corresponding button...',
              style: TextStyle(color: Colors.white.withOpacity(.8)),
              textAlign: TextAlign.center,
            ),
          ),
          // endregion

          // region Actions
          ListView(
            shrinkWrap: true,
            children: [
              Card(
                color: Colors.deepPurple,
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  minLeadingWidth: 0,
                  iconColor: Colors.white,
                  leading: const Icon(Icons.link),
                  title: const Text(
                    'From URL...',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.left,
                  ),
                  subtitle: Text(
                    'Import text from a web page that is available online.',
                    style: TextStyle(color: Colors.white.withOpacity(.5), fontSize: 12),
                    softWrap: true,
                  ),
                  onTap: onImportFromUrl,
                ),
              ),
              Card(
                color: Colors.deepPurple,
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  minLeadingWidth: 0,
                  iconColor: Colors.white,
                  leading: const Icon(Icons.paste),
                  title: const Text(
                    'From clipboard...',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.left,
                  ),
                  subtitle: Text(
                    'Tap when you are ready to paste your book\'s content.',
                    style: TextStyle(color: Colors.white.withOpacity(.5), fontSize: 12),
                    softWrap: true,
                  ),
                  onTap: onImportFromClipboard,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10,),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: app.openYoutubePlaylist,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    size: 35,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Text(
                  'Instructions Video',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10,),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: onCancel,
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          // endregion
        ],
      ),
    );
  }
}
