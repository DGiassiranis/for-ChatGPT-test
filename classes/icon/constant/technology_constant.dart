part of 'icon_constant.dart';

abstract class TechnologyConstant {
  ///[categoryNo] keeps the position of the category
  static const int categoryNo = 15;

  ///path that returns the folder with the icons of the technology's category
  static const String _folderPath = '${IconConstant._folderPath}technology/';

  ///Icon used as title of the technology category;
  static const categoryIcon = '${IconConstant._folderPath}technology.svg';

  ///Icon category model with parent the technology category and children its icons
  static const IconCategoryModel technologyIconsCategory =
      _$technologyCategoryIcons;

  //region Category's icons
  static const apiIcon = '${_folderPath}api.svg';
  static const artificialintelligenceIcon = '${_folderPath}artificialintelligence.svg';
  static const artificialintelligence2Icon = '${_folderPath}artificialintelligence2.svg';
  static const chipIcon = '${_folderPath}chip.svg';
  static const cloudIcon = '${_folderPath}cloud.svg';
  static const computerIcon = '${_folderPath}computer.svg';
  static const cpuIcon = '${_folderPath}cpu.svg';
  static const cyborgIcon = '${_folderPath}cyborg.svg';
  static const energy01Icon = '${_folderPath}energy01.svg';
  static const energy02Icon = '${_folderPath}energy02.svg';
  static const energy03Icon = '${_folderPath}energy03.svg';
  static const energy04Icon = '${_folderPath}energy04.svg';
  static const energy05Icon = '${_folderPath}energy05.svg';
  static const energy06Icon = '${_folderPath}energy06.svg';
  static const energy07Icon = '${_folderPath}energy07.svg';
  static const energy08Icon = '${_folderPath}energy08.svg';
  static const fieldIcon = '${_folderPath}field.svg';
  static const globaldistributionIcon = '${_folderPath}globaldistribution.svg';
  static const greentechnologyIcon = '${_folderPath}greentechnology.svg';
  static const heartIcon = '${_folderPath}heart.svg';
  static const innovationIcon = '${_folderPath}innovation.svg';
  static const nanotechnologyIcon = '${_folderPath}nanotechnology.svg';
  static const nanotechnology2Icon = '${_folderPath}nanotechnology2.svg';
  static const projectmanagementIcon = '${_folderPath}projectmanagement.svg';
  static const smartfarmIcon = '${_folderPath}smartfarm.svg';
  static const technologyIcon = '${_folderPath}technology.svg';
  static const touchIcon = '${_folderPath}touch.svg';

  //end of region;

  ///A list with all the icons of this category
  static const List<String> icons = [
    apiIcon,
    artificialintelligenceIcon,
    artificialintelligence2Icon,
    chipIcon,
    cloudIcon,
    computerIcon,
    cpuIcon,
    cyborgIcon,
    energy01Icon,
    energy02Icon,
    energy03Icon,
    energy04Icon,
    energy05Icon,
    energy06Icon,
    energy07Icon,
    energy08Icon,
    fieldIcon,
    globaldistributionIcon,
    greentechnologyIcon,
    heartIcon,
    innovationIcon,
    nanotechnologyIcon,
    nanotechnology2Icon,
    projectmanagementIcon,
    smartfarmIcon,
    technologyIcon,
    touchIcon,
  ];
}
