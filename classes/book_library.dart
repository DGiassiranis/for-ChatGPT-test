/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:aneya_json/json.dart';
import 'package:flutter/material.dart';
import 'package:notebars/classes/modifications_archive.dart';

import '../../../../global.dart';
import '../../../extensions.dart';
import 'book.dart';

const String booksNeedSyncKey = 'books_need_sync';

class BookLibrary {
  // region Properties
  String uuid;
  String name;
  int order = 0;
  bool enableStudying = true;
  Color color = Colors.deepPurple;
  DateTime? modified;
  // endregion

  //sync properties region
  int booksNeedSync = 0;
  //end region

  // region Getters/setters
  Iterable<Book> get books => app.books.where((book) => book.libraryUuid == uuid);
  // endregion

  // region Constructor & initialization
  BookLibrary({required this.name, this.uuid = '', this.order = 0, this.enableStudying = true, this.color = Colors.deepPurple, this.modified, this.booksNeedSync = 0,});

  factory BookLibrary.fromJson(Json cfg) => BookLibrary(name: '').applyCfg(cfg);
  Json toJson() => {
        "uuid": uuid,
        "name": name,
        "order": order,
        "enableStudying": enableStudying,
        "color": color.toHex(),
        "modified": modified?.toIso8601String(),
        booksNeedSyncKey: booksNeedSync,
      };

  applyCfg(Map<String, dynamic> cfg, [bool strict = false]) {
    if (strict == true) {
      uuid = cfg.getString('uuid', '');
      name = cfg.getString('name', '');
      order = cfg.getInt('order', 0);
      color = cfg.containsKey('color') && cfg['color'] is String ? (cfg['color'] as String).toColor() : Colors.deepPurple;
      enableStudying = cfg.getBool('enableStudying', true);
      modified = cfg.getDateTimeOrNull('modified');
      booksNeedSync = cfg.getInt(booksNeedSyncKey, 0);
    } else {
      uuid = cfg.getString('uuid', uuid);
      name = cfg.getString('name', name);
      order = cfg.getInt('order', order);
      if (cfg.containsKey('color') && cfg['color'] is String) color = (cfg['color'] as String).toColor();
      enableStudying = cfg.getBool('enableStudying', enableStudying);
      modified = cfg.getDateTimeOrNull('modified', modified);
      booksNeedSync = cfg.getInt(booksNeedSyncKey, 0);
    }

    return this;
  }

  factory BookLibrary.fromBookLibraryV2(BookLibraryV2 library) => BookLibrary(name: library.title, uuid: library.uuid, color: library.color, enableStudying: false, booksNeedSync: library.modifiedBooks.where((element) => element.requiredAction != RequiredActionEnum.synchronized).toList().length);
  // endregion
}

extension ListBookLibraryExt on List<BookLibrary> {

  bool containsLibrary(String uuid) => firstWhereOrNull((element) => element.uuid == uuid) != null;

}
