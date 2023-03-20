
part of 'icon_constant.dart';

abstract class BoatConstant{

  ///[categoryNo] keeps the position of the category
  static const int categoryNo = 9;

  ///path that returns the folder with the icons of the boat's category
  static const String _folderPath = '${IconConstant._folderPath}boat/';

  ///Icon used as title of the boat category;
  static const categoryIcon = '${IconConstant._folderPath}boat.svg';

  ///Icon category model with parent the boat category and children its icons
  static const IconCategoryModel boatIconsCategory = _$boatCategoryIcons;

  //region Category's icons
  static const anchorIcon = '${_folderPath}anchor.svg';
  static const anchor2Icon = '${_folderPath}anchor2.svg';
  static const anchor3Icon = '${_folderPath}anchor3.svg';
  static const boat01Icon = '${_folderPath}boat01.svg';
  static const boat02Icon = '${_folderPath}boat02.svg';
  static const boat03Icon = '${_folderPath}boat03.svg';
  static const boat04Icon = '${_folderPath}boat04.svg';
  static const boat05Icon = '${_folderPath}boat05.svg';
  static const boat06Icon = '${_folderPath}boat06.svg';
  static const boat07Icon = '${_folderPath}boat07.svg';
  static const boat08Icon = '${_folderPath}boat08.svg';
  static const boat09Icon = '${_folderPath}boat09.svg';
  static const cargoshipIcon = '${_folderPath}cargoship.svg';
  static const cruiseIcon = '${_folderPath}cruise.svg';
  static const oiltankerIcon = '${_folderPath}oiltanker.svg';
  static const shipIcon = '${_folderPath}ship.svg';
  static const ship3Icon = '${_folderPath}ship3.svg';
  static const ship4Icon = '${_folderPath}ship4.svg';
  //end of region;

  ///A list with all the icons of this category
  static const List<String> icons = [
    anchorIcon,
    anchor2Icon,
    anchor3Icon,
    boat01Icon,
    boat02Icon,
    boat03Icon,
    boat04Icon,
    boat05Icon,
    boat06Icon,
    boat07Icon,
    boat08Icon,
    boat09Icon,
    cargoshipIcon,
    cruiseIcon,
    oiltankerIcon,
    shipIcon,
    ship3Icon,
    ship4Icon,
  ];

}