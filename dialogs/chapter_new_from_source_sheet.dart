/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:notebars/classes/book.dart';

import '../widgets/common/bottom_sheet_dialog.dart';

class ChapterNewFromSourceSheet extends StatelessWidget {
  final Book book;
  final VoidCallback? onCancel;
  final VoidCallback? onImportFromFile;
  final VoidCallback? onImportFromUrl;
  final VoidCallback? onImportFromClipboard;

  const ChapterNewFromSourceSheet({Key? key, required this.book, this.onImportFromFile, this.onImportFromUrl, this.onImportFromClipboard, this.onCancel})
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
              'Add a new chapter...',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              'Book: ${book.name}',
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
