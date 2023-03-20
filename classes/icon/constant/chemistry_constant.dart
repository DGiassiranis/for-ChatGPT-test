
part of 'icon_constant.dart';

abstract class ChemistryConstant {

  ///[categoryNo] keeps the position of the category
  static const int categoryNo = 13;

  ///path that returns the folder with the icons of the chemistry's category
  static const String _folderPath = '${IconConstant._folderPath}chemistry/';

  ///Icon used as title of the chemistry category;
  static const categoryIcon = '${IconConstant._folderPath}chemistry.svg';

  ///Icon category model with parent the chemistry category and children its icons
  static const IconCategoryModel chemistryIconsCategory = _$chemistryCategoryIcons;

  //region Category's icons
  static const che0Icon = '${_folderPath}che0.svg';
  static const chemistry01Icon = '${_folderPath}chemistry01.svg';
  static const chemistry011Icon = '${_folderPath}chemistry011.svg';
  static const chemistry012Icon = '${_folderPath}chemistry012.svg';
  static const chemistry02Icon = '${_folderPath}chemistry02.svg';
  static const chemistry03Icon = '${_folderPath}chemistry03.svg';
  static const chemistry04Icon = '${_folderPath}chemistry04.svg';
  static const chemistry05Icon = '${_folderPath}chemistry05.svg';
  static const chemistry06Icon = '${_folderPath}chemistry06.svg';
  static const chemistry07Icon = '${_folderPath}chemistry07.svg';
  static const chemistry08Icon = '${_folderPath}chemistry08.svg';
  static const chemistry09Icon = '${_folderPath}chemistry09.svg';
  static const chemistry10Icon = '${_folderPath}chemistry10.svg';
  static const chemistry13Icon = '${_folderPath}chemistry13.svg';
  static const chemistry14Icon = '${_folderPath}chemistry14.svg';
  static const flask3Icon = '${_folderPath}flask3.svg';
  static const flask4Icon = '${_folderPath}flask4.svg';
  static const flask5Icon = '${_folderPath}flask5.svg';
  static const goldIcon = '${_folderPath}gold.svg';
  static const gold2Icon = '${_folderPath}gold2.svg';
  static const ironIcon = '${_folderPath}iron.svg';
  static const leadIcon = '${_folderPath}lead.svg';
  static const lead2Icon = '${_folderPath}lead2.svg';
  static const magnesiumIcon = '${_folderPath}magnesium.svg';
  static const mercuryIcon = '${_folderPath}mercury.svg';
  static const oxygen2Icon = '${_folderPath}oxygen2.svg';
  static const platinumIcon = '${_folderPath}platinum.svg';
  static const s01Icon = '${_folderPath}s01.svg';
  static const silverIcon = '${_folderPath}silver.svg';
  static const sodiumIcon = '${_folderPath}sodium.svg';
  static const v01Icon = '${_folderPath}v01.svg';
  static const v02Icon = '${_folderPath}v02.svg';
  //end of region;

  ///A list with all the icons of this category
  static const List<String> icons = [
    che0Icon,
    chemistry01Icon,
    chemistry011Icon,
    chemistry012Icon,
    chemistry02Icon,
    chemistry03Icon,
    chemistry04Icon,
    chemistry05Icon,
    chemistry06Icon,
    chemistry07Icon,
    chemistry08Icon,
    chemistry09Icon,
    chemistry10Icon,
    chemistry13Icon,
    chemistry14Icon,
    flask3Icon,
    flask4Icon,
    flask5Icon,
    goldIcon,
    gold2Icon,
    ironIcon,
    leadIcon,
    lead2Icon,
    magnesiumIcon,
    mercuryIcon,
    oxygen2Icon,
    platinumIcon,
    s01Icon,
    silverIcon,
    sodiumIcon,
    v01Icon,
    v02Icon,
  ];

}