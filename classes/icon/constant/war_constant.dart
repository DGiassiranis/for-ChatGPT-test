part of 'icon_constant.dart';

abstract class WarConstant{
  ///[categoryNo] keeps the position of the category
  static const int categoryNo = 7;

  ///path that returns the folder with the icons of the war's category
  static const String _folderPath = '${IconConstant._folderPath}war/';

  ///Icon used as title of the war category;
  static const categoryIcon = '${IconConstant._folderPath}war.svg';

  ///Icon category model with parent the war category and children its icons
  static const IconCategoryModel warIconsCategory = _$warCategoryIcons;

  //region Category's icons
  static const armorIcon = '${_folderPath}armor.svg';
  static const armor2Icon = '${_folderPath}armor2.svg';
  static const armor3Icon = '${_folderPath}armor3.svg';
  static const armor4Icon = '${_folderPath}armor4.svg';
  static const axeIcon = '${_folderPath}axe.svg';
  static const axe2Icon = '${_folderPath}axe2.svg';
  static const battleIcon = '${_folderPath}battle.svg';
  static const battle2Icon = '${_folderPath}battle2.svg';
  static const battleAxeIcon = '${_folderPath}battle-axe.svg';
  static const battleShieldIcon = '${_folderPath}battle-shield.svg';
  static const battleShield2Icon = '${_folderPath}battle-shield2.svg';
  static const boxingIcon = '${_folderPath}boxing.svg';
  static const catapultIcon = '${_folderPath}catapult.svg';
  static const crossedIcon = '${_folderPath}crossed.svg';
  static const fireIcon = '${_folderPath}fire.svg';
  static const helmetIcon = '${_folderPath}helmet.svg';
  static const helmet2Icon = '${_folderPath}helmet2.svg';
  static const helmet3Icon = '${_folderPath}helmet3.svg';
  static const helmet4Icon = '${_folderPath}helmet4.svg';
  static const helmet5Icon = '${_folderPath}helmet5.svg';
  static const helmet6Icon = '${_folderPath}helmet6.svg';
  static const helmet7Icon = '${_folderPath}helmet7.svg';
  static const historyIcon = '${_folderPath}history.svg';
  static const shieldIcon = '${_folderPath}shield.svg';
  static const shield2Icon = '${_folderPath}shield2.svg';
  static const spearIcon = '${_folderPath}spear.svg';
  static const swordsIcon = '${_folderPath}swords.svg';
  static const trojanHorseIcon = '${_folderPath}trojan-horse.svg';
  //end of region;

  ///A list with all the icons of this category
  static const List<String> icons = [
    armorIcon,
    armor2Icon,
    armor3Icon,
    armor4Icon,
    axeIcon,
    axe2Icon,
    battleIcon,
    battle2Icon,
    battleAxeIcon,
    battleShieldIcon,
    battleShield2Icon,
    boxingIcon,
    catapultIcon,
    crossedIcon,
    fireIcon,
    helmetIcon,
    helmet2Icon,
    helmet3Icon,
    helmet4Icon,
    helmet5Icon,
    helmet6Icon,
    helmet7Icon,
    historyIcon,
    shieldIcon,
    shield2Icon,
    spearIcon,
    swordsIcon,
    trojanHorseIcon,
  ];
}