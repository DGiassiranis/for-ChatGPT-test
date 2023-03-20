
part of 'icon_constant.dart';

abstract class HumanConstant{

  ///[categoryNo] keeps the position of the category
  static const int categoryNo = 0;

  ///path that returns the folder with the icons of the human's category
  static const String _folderPath = '${IconConstant._folderPath}human/';

  ///Icon used as title of the human category;
  static const categoryIcon = '${IconConstant._folderPath}human.svg';

  ///Icon category model with parent the human category and children its icons
  static const IconCategoryModel humanIconsCategory = _$humanCategoryIcons;

  //region Category's icons
  static const arteryIcon = '${_folderPath}artery.svg';
  static const bone003Icon = '${_folderPath}bone003.svg';
  static const bone01Icon = '${_folderPath}bone01.svg';
  static const bone02Icon = '${_folderPath}bone02.svg';
  static const bone04Icon = '${_folderPath}bone04.svg';
  static const bone05Icon = '${_folderPath}bone05.svg';
  static const epidermisIcon = '${_folderPath}epidermis.svg';
  static const humanresourcesIcon = '${_folderPath}human-resources.svg';
  static const human009Icon = '${_folderPath}human009.svg';
  static const human01Icon = '${_folderPath}human01.svg';
  static const human02Icon = '${_folderPath}human02.svg';
  static const human03Icon = '${_folderPath}human03.svg';
  static const human04Icon = '${_folderPath}human04.svg';
  static const human05Icon = '${_folderPath}human05.svg';
  static const human06Icon = '${_folderPath}human06.svg';
  static const human07Icon = '${_folderPath}human07.svg';
  static const human08Icon = '${_folderPath}human08.svg';
  static const human10Icon = '${_folderPath}human10.svg';
  static const human12Icon = '${_folderPath}human12.svg';
  static const musclesIcon = '${_folderPath}muscles.svg';
  static const neuronIcon = '${_folderPath}neuron.svg';
  static const noseIcon = '${_folderPath}nose.svg';
  static const orgIcon = '${_folderPath}org.svg';
  static const org0Icon = '${_folderPath}org0.svg';
  static const org005Icon = '${_folderPath}org005.svg';
  static const org005bIcon = '${_folderPath}org005b.svg';
  static const org006Icon = '${_folderPath}org006.svg';
  static const org007Icon = '${_folderPath}org007.svg';
  static const org008Icon = '${_folderPath}org008.svg';
  static const org009Icon = '${_folderPath}org009.svg';
  static const org01Icon = '${_folderPath}org01.svg';
  static const org02Icon = '${_folderPath}org02.svg';
  static const org03Icon = '${_folderPath}org03.svg';
  static const org04Icon = '${_folderPath}org04.svg';
  static const physiologyIcon = '${_folderPath}physiology.svg';
  static const redbloodcellsIcon = '${_folderPath}redbloodcells.svg';
  static const ribcageIcon = '${_folderPath}ribcage.svg';
  static const skeletonIcon = '${_folderPath}skeleton.svg';
  static const spineIcon = '${_folderPath}spine.svg';
  //end of region;

  ///A list with all the icons of this category
  static const List<String> icons = [
    arteryIcon,
    bone003Icon,
    bone01Icon,
    bone02Icon,
    bone04Icon,
    bone05Icon,
    epidermisIcon,
    humanresourcesIcon,
    human009Icon,
    human01Icon,
    human02Icon,
    human03Icon,
    human04Icon,
    human05Icon,
    human06Icon,
    human07Icon,
    human08Icon,
    human10Icon,
    human12Icon,
    musclesIcon,
    neuronIcon,
    noseIcon,
    orgIcon,
    org0Icon,
    org005Icon,
    org005bIcon,
    org006Icon,
    org007Icon,
    org008Icon,
    org009Icon,
    org01Icon,
    org02Icon,
    org03Icon,
    org04Icon,
    physiologyIcon,
    redbloodcellsIcon,
    ribcageIcon,
    skeletonIcon,
    spineIcon,
  ];
}