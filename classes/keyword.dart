/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:aneya_json/json.dart';

class Keyword {
  // region Constants
  // endregion

  // region Properties
  String word;
  int pos;
  String? normalCase;
  bool capital;
  // endregion

  // region Getters/setters
  // endregion

  // region Constructors & initialization
  Keyword(this.word, this.pos, this.normalCase, {this.capital = false});

  applyCfg(Json cfg, [bool strict = false]) {
    if (strict == true) {
      word = cfg.getString('word', '');
      pos = cfg.getInt('pos', -1);
      capital = cfg.getBool('capital', false);
    } else {
      word = cfg.getString('word', word);
      pos = cfg.getInt('pos', pos);
      capital = cfg.getBool('capital', false);
    }
  }
  // endregion

  // region Methods
  Json toJson() => {'word': word, 'pos': pos, 'capital': capital};

  bool isEqual(Keyword keyword) => keyword.word.toLowerCase() == word.toLowerCase() && keyword.pos == pos;
  // endregion

  // region Static methods
  // endregion
}
