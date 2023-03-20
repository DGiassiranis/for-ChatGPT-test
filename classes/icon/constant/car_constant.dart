part of 'icon_constant.dart';

abstract class CarConstant {
  ///[categoryNo] keeps the position of the category
  static const int categoryNo = 10;

  ///path that returns the folder with the icons of the car's category
  static const String _folderPath = '${IconConstant._folderPath}car/';

  ///Icon used as title of the car category;
  static const categoryIcon = '${IconConstant._folderPath}car.svg';

  ///Icon category model with parent the car category and children its icons
  static const IconCategoryModel carIconsCategory = _$carCategoryIcons;

  //region Category's icons
  static const carIcon = '${_folderPath}car.svg';
  static const deliveryTruckIcon = '${_folderPath}delivery-truck.svg';
  static const electricCarIcon = '${_folderPath}electric-car.svg';
  static const excavatorIcon = '${_folderPath}excavator.svg';
  static const paperPlaneIcon = '${_folderPath}paper-plane.svg';
  static const planeIcon = '${_folderPath}plane.svg';
  static const plane2Icon = '${_folderPath}plane2.svg';
  static const sportsCarIcon = '${_folderPath}sports-car.svg';

  //end of region;

  ///A list with all the icons of this category
  static const List<String> icons = [
    carIcon,
    deliveryTruckIcon,
    electricCarIcon,
    excavatorIcon,
    paperPlaneIcon,
    planeIcon,
    plane2Icon,
    sportsCarIcon,
  ];
}
