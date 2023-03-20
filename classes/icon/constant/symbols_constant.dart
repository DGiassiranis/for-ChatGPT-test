


part of 'icon_constant.dart';

abstract class SymbolsConstant {

  ///[categoryNo] keeps the position of the category
  static const int categoryNo = 17;

  ///path that returns the folder with the icons of the symbols's category
  static const String _folderPath = '${IconConstant._folderPath}symbols/';

  ///Icon used as title of the symbols category;
  static const categoryIcon = '${IconConstant._folderPath}symbols.svg';

  ///Icon category model with parent the symbols category and children its icons
  static const IconCategoryModel symbolsIconsCategory = _$symbolsCategoryIcons;


  //region Category's icons
  static const abullet13Icon = '${_folderPath}abullet13.svg';
  static const abullet14Icon = '${_folderPath}abullet14.svg';
  static const blurIcon = '${_folderPath}blur.svg';
  static const bsymbol01Icon = '${_folderPath}bsymbol01.svg';
  static const bsymbol02Icon = '${_folderPath}bsymbol02.svg';
  static const caduceussymbolIcon = '${_folderPath}caduceussymbol.svg';
  static const climbingIcon = '${_folderPath}climbing.svg';
  static const copyrightIcon = '${_folderPath}copyright.svg';
  static const emailIcon = '${_folderPath}email.svg';
  static const endlessknotIcon = '${_folderPath}endless-knot.svg';
  static const eternityIcon = '${_folderPath}eternity.svg';
  static const femenineIcon = '${_folderPath}femenine.svg';
  static const finishIcon = '${_folderPath}finish.svg';
  static const finishflag2Icon = '${_folderPath}finishflag2.svg';
  static const flag02Icon = '${_folderPath}flag02.svg';
  static const flag02bIcon = '${_folderPath}flag02b.svg';
  static const flag03Icon = '${_folderPath}flag03.svg';
  static const flag04Icon = '${_folderPath}flag04.svg';
  static const flag2Icon = '${_folderPath}flag2.svg';
  static const flag3Icon = '${_folderPath}flag3.svg';
  static const functionIcon = '${_folderPath}function.svg';
  static const islamIcon = '${_folderPath}islam.svg';
  static const mathematicsIcon = '${_folderPath}mathematics.svg';
  static const missionIcon = '${_folderPath}mission.svg';
  static const monkeyIcon = '${_folderPath}monkey.svg';
  static const musicalsignformusicclassIcon = '${_folderPath}musical-sign-for-music-class.svg';
  static const paragraphIcon = '${_folderPath}paragraph.svg';
  static const peaceIcon = '${_folderPath}peace.svg';
  static const rupeeIcon = '${_folderPath}rupee.svg';
  static const ssymbol002Icon = '${_folderPath}ssymbol002.svg';
  static const ssymbol003Icon = '${_folderPath}ssymbol003.svg';
  static const ssymbol004Icon = '${_folderPath}ssymbol004.svg';
  static const symbolIcon = '${_folderPath}symbol.svg';
  static const triangleIcon = '${_folderPath}triangle.svg';
  //end of region;

  ///A list with all the icons of this category
  static const List<String> icons = [
    abullet13Icon,
    abullet14Icon,
    blurIcon,
    bsymbol01Icon,
    bsymbol02Icon,
    caduceussymbolIcon,
    climbingIcon,
    copyrightIcon,
    emailIcon,
    endlessknotIcon,
    eternityIcon,
    femenineIcon,
    finishIcon,
    finishflag2Icon,
    flag02Icon,
    flag02bIcon,
    flag03Icon,
    flag04Icon,
    flag2Icon,
    flag3Icon,
    functionIcon,
    islamIcon,
    mathematicsIcon,
    missionIcon,
    monkeyIcon,
    musicalsignformusicclassIcon,
    paragraphIcon,
    peaceIcon,
    rupeeIcon,
    ssymbol002Icon,
    ssymbol003Icon,
    ssymbol004Icon,
    symbolIcon,
    triangleIcon,
  ];
}