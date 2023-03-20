
part of 'icon_constant.dart';

abstract class PartsConstant {

  ///[categoryNo] keeps the position of the category
  static const int categoryNo = 11;

  ///path that returns the folder with the icons of the parts' category
  static const String _folderPath = '${IconConstant._folderPath}parts/';

  ///Icon used as title of the parts category;
  static const categoryIcon = '${IconConstant._folderPath}parts.svg';

  ///Icon category model with parent the parts category and children its icons
  static const IconCategoryModel partsIconsCategory = _$partsCategoryIcons;

  //region Category's icons
  static const batteryIcon = '${_folderPath}battery.svg';
  static const carIcon = '${_folderPath}car.svg';
  static const chainIcon = '${_folderPath}chain.svg';
  static const discBrakeIcon = '${_folderPath}disc-brake.svg';
  static const discBrake2Icon = '${_folderPath}disc-brake2.svg';
  static const engineIcon = '${_folderPath}engine.svg';
  static const maintenanceIcon = '${_folderPath}maintenance.svg';
  static const pistonsIcon = '${_folderPath}pistons.svg';
  static const springIcon = '${_folderPath}spring.svg';
  static const steeringWheelIcon = '${_folderPath}steering-wheel.svg';
  static const watchPartsIcon = '${_folderPath}watch-parts.svg';
  static const waterPumpIcon = '${_folderPath}water-pump.svg';
  static const wheelAlignmentIcon = '${_folderPath}wheel-alignment.svg';
  //end of region;

  ///A list with all the icons of this category
  static const List<String> icons = [
    batteryIcon,
    carIcon,
    chainIcon,
    discBrakeIcon,
    discBrake2Icon,
    engineIcon,
    maintenanceIcon,
    pistonsIcon,
    springIcon,
    steeringWheelIcon,
    watchPartsIcon,
    waterPumpIcon,
    wheelAlignmentIcon,
  ];


}