part of 'icon_constant.dart';

abstract class HistoryConstant {
  ///[categoryNo] keeps the position of the category
  static const int categoryNo = 5;

  ///path that returns the folder with the icons of the history's category
  static const String _folderPath = '${IconConstant._folderPath}history/';

  ///Icon used as title of the history category;
  static const categoryIcon = '${IconConstant._folderPath}history.svg';

  ///Icon category model with parent the history category and children its icons
  static const IconCategoryModel historyIconsCategory = _$historyCategoryIcons;

  //region Category's icons
  static const archIcon = '${_folderPath}arch.svg';
  static const architectureIcon = '${_folderPath}architecture.svg';
  static const buildingIcon = '${_folderPath}building.svg';
  static const castleIcon = '${_folderPath}castle.svg';
  static const castle2Icon = '${_folderPath}castle2.svg';
  static const castle3Icon = '${_folderPath}castle3.svg';
  static const castle4Icon = '${_folderPath}castle4.svg';
  static const castle5Icon = '${_folderPath}castle5.svg';
  static const castle6Icon = '${_folderPath}castle6.svg';
  static const churchIcon = '${_folderPath}church.svg';
  static const coliseumIcon = '${_folderPath}coliseum.svg';
  static const historicsiteIcon = '${_folderPath}historicsite.svg';
  static const historicsite2Icon = '${_folderPath}historicsite2.svg';
  static const historyIcon = '${_folderPath}history.svg';
  static const landmarkIcon = '${_folderPath}landmark.svg';
  static const mayanpyramidIcon = '${_folderPath}mayanpyramid.svg';
  static const monumentIcon = '${_folderPath}monument.svg';
  static const monument2Icon = '${_folderPath}monument2.svg';
  static const monument3Icon = '${_folderPath}monument3.svg';
  static const monumentsIcon = '${_folderPath}monuments.svg';
  static const mosqueIcon = '${_folderPath}mosque.svg';

  //end of region;
  static const List<String> icons = [
    archIcon,
    architectureIcon,
    buildingIcon,
    castleIcon,
    castle2Icon,
    castle3Icon,
    castle4Icon,
    castle5Icon,
    castle6Icon,
    churchIcon,
    coliseumIcon,
    historicsiteIcon,
    historicsite2Icon,
    historyIcon,
    landmarkIcon,
    mayanpyramidIcon,
    monumentIcon,
    monument2Icon,
    monument3Icon,
    monumentsIcon,
    mosqueIcon,
  ];
}
