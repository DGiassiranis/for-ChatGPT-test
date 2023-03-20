
part of 'icon_constant.dart';

abstract class ReignConstant{
  ///[categoryNo] keeps the position of the category
  static const int categoryNo = 4;

  ///path that returns the folder with the icons of the reign's category
  static const String _folderPath = '${IconConstant._folderPath}reign/';

  ///Icon used as title of the reign category;
  static const categoryIcon = '${IconConstant._folderPath}reign.svg';

  ///Icon category model with parent the reign category and children its icons
  static const IconCategoryModel reignIconsCategory = _$reignCategoryIcons;

  //region Category's icons
  static const bedIcon = '${_folderPath}bed.svg';
  static const castleIcon = '${_folderPath}castle.svg';
  static const crownIcon = '${_folderPath}crown.svg';
  static const crown2Icon = '${_folderPath}crown2.svg';
  static const crown3Icon = '${_folderPath}crown3.svg';
  static const crown4Icon = '${_folderPath}crown4.svg';
  static const crown5Icon = '${_folderPath}crown5.svg';
  static const crown6Icon = '${_folderPath}crown6.svg';
  static const federalPalaceOfSwitzerlandIcon = '${_folderPath}federal-palace-of-switzerland.svg';
  static const hawaMahalIcon = '${_folderPath}hawa-mahal.svg';
  static const kingIcon = '${_folderPath}king.svg';
  static const mosqueIcon = '${_folderPath}mosque.svg';
  static const mysoreIcon = '${_folderPath}mysore.svg';
  static const palaceIcon = '${_folderPath}palace.svg';
  static const paleisOpDeDamIcon = '${_folderPath}paleis-op-de-dam.svg';
  static const scepterIcon = '${_folderPath}scepter.svg';
  static const sejongTheGreatIcon = '${_folderPath}sejong-the-great.svg';
  static const topkapiPalaceIcon = '${_folderPath}topkapi-palace.svg';
  static const wiseManIcon = '${_folderPath}wise-man.svg';
  //end of region;

  static const List<String> icons = [
    bedIcon,
    castleIcon,
    crownIcon,
    crown2Icon,
    crown3Icon,
    crown4Icon,
    crown5Icon,
    crown6Icon,
    federalPalaceOfSwitzerlandIcon,
    hawaMahalIcon,
    kingIcon,
    mosqueIcon,
    mysoreIcon,
    palaceIcon,
    paleisOpDeDamIcon,
    scepterIcon,
    sejongTheGreatIcon,
    topkapiPalaceIcon,
    wiseManIcon,
  ];

}