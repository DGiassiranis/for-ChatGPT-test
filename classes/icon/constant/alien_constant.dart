part of 'icon_constant.dart';

abstract class AlienConstant {
  ///[categoryNo] keeps the position of the category
  static const int categoryNo = 16;

  ///path that returns the folder with the icons of the alien's category
  static const String _folderPath = '${IconConstant._folderPath}alien/';

  ///Icon used as title of the alien category;
  static const categoryIcon = '${IconConstant._folderPath}alien.svg';

  ///Icon category model with parent the alien category and children its icons
  static const IconCategoryModel alienIconsCategory = _$alienCategoryIcons;

  //region Category's icons
  static const alien01Icon = '${_folderPath}alien01.svg';
  static const alien02Icon = '${_folderPath}alien02.svg';
  static const alien03Icon = '${_folderPath}alien03.svg';
  static const alien04Icon = '${_folderPath}alien04.svg';
  static const alien05Icon = '${_folderPath}alien05.svg';
  static const alien06Icon = '${_folderPath}alien06.svg';
  static const alien07Icon = '${_folderPath}alien07.svg';
  static const alien08Icon = '${_folderPath}alien08.svg';
  static const alien09Icon = '${_folderPath}alien09.svg';
  static const alien10Icon = '${_folderPath}alien10.svg';
  static const alien8Icon = '${_folderPath}alien8.svg';
  static const planet01Icon = '${_folderPath}planet01.svg';
  static const planet02Icon = '${_folderPath}planet02.svg';
  static const planet03Icon = '${_folderPath}planet03.svg';
  static const planet04Icon = '${_folderPath}planet04.svg';
  static const planet05Icon = '${_folderPath}planet05.svg';
  static const planet06Icon = '${_folderPath}planet06.svg';
  static const planet07Icon = '${_folderPath}planet07.svg';
  static const planet08Icon = '${_folderPath}planet08.svg';
  static const planet09Icon = '${_folderPath}planet09.svg';
  static const planet10Icon = '${_folderPath}planet10.svg';
  static const planet11Icon = '${_folderPath}planet11.svg';
  static const planet12Icon = '${_folderPath}planet12.svg';
  static const planet13Icon = '${_folderPath}planet13.svg';
  static const planet14Icon = '${_folderPath}planet14.svg';
  static const ufo01Icon = '${_folderPath}ufo01.svg';
  static const ufo02Icon = '${_folderPath}ufo02.svg';
  static const ufo03Icon = '${_folderPath}ufo03.svg';
  static const weaponIcon = '${_folderPath}weapon.svg';
  static const zodiacIcon = '${_folderPath}zodiac.svg';

  //end of region;

  ///A list with all the icons of this category
  static const List<String> icons = [
    alien01Icon,
    alien02Icon,
    alien03Icon,
    alien04Icon,
    alien05Icon,
    alien06Icon,
    alien07Icon,
    alien08Icon,
    alien09Icon,
    alien10Icon,
    alien8Icon,
    planet01Icon,
    planet02Icon,
    planet03Icon,
    planet04Icon,
    planet05Icon,
    planet06Icon,
    planet07Icon,
    planet08Icon,
    planet09Icon,
    planet10Icon,
    planet11Icon,
    planet12Icon,
    planet13Icon,
    planet14Icon,
    ufo01Icon,
    ufo02Icon,
    ufo03Icon,
    weaponIcon,
    zodiacIcon,
  ];
}
