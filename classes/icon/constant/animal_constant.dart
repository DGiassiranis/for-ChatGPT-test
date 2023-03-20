
part of 'icon_constant.dart';

///part of [IconConstant] class
abstract class AnimalConstant{
  ///[categoryNo] keeps the position of the category
  static const int categoryNo = 1;

  ///path that returns the folder with the icons of the animal's category
  static const String _folderPath = '${IconConstant._folderPath}animal/';

  ///Icon used as title of the animal category;
  static const categoryIcon = '${IconConstant._folderPath}animal.svg';

  ///Icon category model with parent the animal category and children its icons
  static const IconCategoryModel animalIconsCategory = _$animalCategoryIcons;

  //region Category's icons
  static const animal01Icon = '${_folderPath}animal01.svg';
  static const animal02Icon = '${_folderPath}animal02.svg';
  static const animal03Icon = '${_folderPath}animal03.svg';
  static const animal04Icon = '${_folderPath}animal04.svg';
  static const animal05Icon = '${_folderPath}animal05.svg';
  static const animal06Icon = '${_folderPath}animal06.svg';
  static const animal07Icon = '${_folderPath}animal07.svg';
  static const animal07bIcon = '${_folderPath}animal07b.svg';
  static const animal08Icon = '${_folderPath}animal08.svg';
  static const animal09Icon = '${_folderPath}animal09.svg';
  static const animal10Icon = '${_folderPath}animal10.svg';
  static const animal10bIcon = '${_folderPath}animal10b.svg';
  static const animal11Icon = '${_folderPath}animal11.svg';
  static const animal11cIcon = '${_folderPath}animal11c.svg';
  static const animal12Icon = '${_folderPath}animal12.svg';
  static const animal13Icon = '${_folderPath}animal13.svg';
  static const animal14Icon = '${_folderPath}animal14.svg';
  static const animal15Icon = '${_folderPath}animal15.svg';
  static const animal16Icon = '${_folderPath}animal16.svg';
  static const beeIcon = '${_folderPath}bee.svg';
  static const beehiveIcon = '${_folderPath}beehive.svg';
  static const butterflyIcon = '${_folderPath}butterfly.svg';
  static const dolphinIcon = '${_folderPath}dolphin.svg';
  static const dolphin2Icon = '${_folderPath}dolphin2.svg';
  static const fishIcon = '${_folderPath}fish.svg';
  static const fishbIcon = '${_folderPath}fishb.svg';
  static const lobsterIcon = '${_folderPath}lobster.svg';
  static const sealIcon = '${_folderPath}seal.svg';
  static const snailIcon = '${_folderPath}snail.svg';
  static const snakeIcon = '${_folderPath}snake.svg';
  static const symbol01Icon = '${_folderPath}symbol01.svg';
  static const symbol02Icon = '${_folderPath}symbol02.svg';
  static const symbol03Icon = '${_folderPath}symbol03.svg';
  static const symbol04Icon = '${_folderPath}symbol04.svg';
  static const symbol05Icon = '${_folderPath}symbol05.svg';
  static const symbol07Icon = '${_folderPath}symbol07.svg';
  static const waspIcon = '${_folderPath}wasp.svg';
  static const whaleIcon = '${_folderPath}whale.svg';
  //end of region;

  ///A list with all the icons of this category
  static const List<String> icons = [
    animal01Icon,
    animal02Icon,
    animal03Icon,
    animal04Icon,
    animal05Icon,
    animal06Icon,
    animal07Icon,
    animal07bIcon,
    animal08Icon,
    animal09Icon,
    animal10Icon,
    animal10bIcon,
    animal11Icon,
    animal11cIcon,
    animal12Icon,
    animal13Icon,
    animal14Icon,
    animal15Icon,
    animal16Icon,
    beeIcon,
    beehiveIcon,
    butterflyIcon,
    dolphinIcon,
    dolphin2Icon,
    fishIcon,
    fishbIcon,
    lobsterIcon,
    sealIcon,
    snailIcon,
    snakeIcon,
    symbol01Icon,
    symbol02Icon,
    symbol03Icon,
    symbol04Icon,
    symbol05Icon,
    symbol07Icon,
    waspIcon,
    whaleIcon,
  ];

}