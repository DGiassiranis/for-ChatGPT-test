part of 'icon_constant.dart';

abstract class PolemicConstant {
  ///[categoryNo] keeps the position of the category
  static const int categoryNo = 8;

  ///path that returns the folder with the icons of the polemic's category
  static const String _folderPath = '${IconConstant._folderPath}polemic/';

  ///Icon used as title of the polemic category;
  static const categoryIcon = '${IconConstant._folderPath}polemic.svg';

  ///Icon category model with parent the polemic category and children its icons
  static const IconCategoryModel polemicIconsCategory = _$polemicCategoryIcons;

  //region Category's icons
  static const aircraftIcon = '${_folderPath}aircraft.svg';
  static const airplaneIcon = '${_folderPath}airplane.svg';
  static const armouredVanIcon = '${_folderPath}armoured-van.svg';
  static const bombIcon = '${_folderPath}bomb.svg';
  static const canonIcon = '${_folderPath}canon.svg';
  static const explosionIcon = '${_folderPath}explosion.svg';
  static const explosion2Icon = '${_folderPath}explosion2.svg';
  static const gunsIcon = '${_folderPath}guns.svg';
  static const jetIcon = '${_folderPath}jet.svg';
  static const machineGunIcon = '${_folderPath}machine-gun.svg';
  static const machineGun2Icon = '${_folderPath}machine-gun2.svg';
  static const soldierIcon = '${_folderPath}soldier.svg';
  static const soldier2Icon = '${_folderPath}soldier2.svg';
  //end of region;

  static const List<String> icons = [
    aircraftIcon,
    airplaneIcon,
    armouredVanIcon,
    bombIcon,
    canonIcon,
    explosionIcon,
    explosion2Icon,
    gunsIcon,
    jetIcon,
    machineGunIcon,
    machineGun2Icon,
    soldierIcon,
    soldier2Icon,
  ];
}
