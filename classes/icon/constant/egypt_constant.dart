
part of 'icon_constant.dart';

abstract class EgyptConstant{

  ///[categoryNo] keeps the position of the category
  static const int categoryNo = 6;

  ///path that returns the folder with the icons of the egypt's category
  static const String _folderPath = '${IconConstant._folderPath}egypt/';

  ///Icon used as title of the egypt category;
  static const categoryIcon = '${IconConstant._folderPath}egypt.svg';

  ///Icon category model with parent the egypt category and children its icons
  static const IconCategoryModel egyptIconsCategory = _$egyptCategoryIcons;

  //region Category's icons
  static const ancientscrollIcon = '${_folderPath}ancientscroll.svg';
  static const ankhIcon = '${_folderPath}ankh.svg';
  static const anubisIcon = '${_folderPath}anubis.svg';
  static const anubis2Icon = '${_folderPath}anubis2.svg';
  static const beetleIcon = '${_folderPath}beetle.svg';
  static const beetle2Icon = '${_folderPath}beetle2.svg';
  static const cartoucheIcon = '${_folderPath}cartouche.svg';
  static const catIcon = '${_folderPath}cat.svg';
  static const cleopatraIcon = '${_folderPath}cleopatra.svg';
  static const columnIcon = '${_folderPath}column.svg';
  static const crookIcon = '${_folderPath}crook.svg';
  static const eagleIcon = '${_folderPath}eagle.svg';
  static const egypt2Icon = '${_folderPath}egypt2.svg';
  static const eyeofraIcon = '${_folderPath}eyeofra.svg';
  static const flowerIcon = '${_folderPath}flower.svg';
  static const greatsphinxofgizaIcon = '${_folderPath}greatsphinxofgiza.svg';
  static const hieroglyphIcon = '${_folderPath}hieroglyph.svg';
  static const hieroglyph2Icon = '${_folderPath}hieroglyph2.svg';
  static const hieroglyph3Icon = '${_folderPath}hieroglyph3.svg';
  static const mummyIcon = '${_folderPath}mummy.svg';
  static const pharaohIcon = '${_folderPath}pharaoh.svg';
  static const pyramids02Icon = '${_folderPath}pyramids02.svg';
  static const pyramids03Icon = '${_folderPath}pyramids03.svg';
  static const pyramids04Icon = '${_folderPath}pyramids04.svg';
  static const pyramids06Icon = '${_folderPath}pyramids06.svg';
  static const pyramids07Icon = '${_folderPath}pyramids07.svg';
  static const scorpionIcon = '${_folderPath}scorpion.svg';
  static const sphinxIcon = '${_folderPath}sphinx.svg';
  static const sphinx2Icon = '${_folderPath}sphinx2.svg';
  static const thothIcon = '${_folderPath}thoth.svg';
  //end of region;

  ///A list with all the icons of this category
  static const List<String> icons = [
    ancientscrollIcon,
    ankhIcon,
    anubisIcon,
    anubis2Icon,
    beetleIcon,
    beetle2Icon,
    cartoucheIcon,
    catIcon,
    cleopatraIcon,
    columnIcon,
    crookIcon,
    eagleIcon,
    egypt2Icon,
    eyeofraIcon,
    flowerIcon,
    greatsphinxofgizaIcon,
    hieroglyphIcon,
    hieroglyph2Icon,
    hieroglyph3Icon,
    mummyIcon,
    pharaohIcon,
    pyramids02Icon,
    pyramids03Icon,
    pyramids04Icon,
    pyramids06Icon,
    pyramids07Icon,
    scorpionIcon,
    sphinxIcon,
    sphinx2Icon,
    thothIcon,
  ];
}