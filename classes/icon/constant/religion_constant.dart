
part of 'icon_constant.dart';

abstract class ReligionConstant {
  ///[categoryNo] keeps the position of the category
  static const int categoryNo = 3;

  ///path that returns the folder with the icons of the religion's category
  static const String _folderPath = '${IconConstant._folderPath}religion/';

  ///Icon used as title of the religion category;
  static const categoryIcon = '${IconConstant._folderPath}religion.svg';

  ///Icon category model with parent the religion category and children its icons
  static const IconCategoryModel religionCategoryIcons = _$religionCategoryIcons;

  //region Category's icons
  static const caodaiIcon = '${_folderPath}caodai.svg';
  static const cuauhtliIcon = '${_folderPath}cuauhtli.svg';
  static const ganeshaIcon = '${_folderPath}ganesha.svg';
  static const ganesha2Icon = '${_folderPath}ganesha2.svg';
  static const godIcon = '${_folderPath}god.svg';
  static const god2Icon = '${_folderPath}god2.svg';
  static const god3Icon = '${_folderPath}god3.svg';
  static const god4Icon = '${_folderPath}god4.svg';
  static const god5Icon = '${_folderPath}god5.svg';
  static const godofwealthIcon = '${_folderPath}godofwealth.svg';
  static const godofwealth2Icon = '${_folderPath}godofwealth2.svg';
  static const goo01Icon = '${_folderPath}goo01.svg';
  static const good02Icon = '${_folderPath}good02.svg';
  static const good03Icon = '${_folderPath}good03.svg';
  static const good04Icon = '${_folderPath}good04.svg';
  static const good05Icon = '${_folderPath}good05.svg';
  static const good06Icon = '${_folderPath}good06.svg';
  static const good07Icon = '${_folderPath}good07.svg';
  static const good08Icon = '${_folderPath}good08.svg';
  static const good09Icon = '${_folderPath}good09.svg';
  static const good10Icon = '${_folderPath}good10.svg';
  static const good11Icon = '${_folderPath}good11.svg';
  static const good12Icon = '${_folderPath}good12.svg';
  static const harpIcon = '${_folderPath}harp.svg';
  static const hermesIcon = '${_folderPath}hermes.svg';
  static const orpheusIcon = '${_folderPath}orpheus.svg';
  static const poseidonIcon = '${_folderPath}poseidon.svg';
  static const prayerIcon = '${_folderPath}prayer.svg';
  static const sunIcon = '${_folderPath}sun.svg';
  static const worldIcon = '${_folderPath}world.svg';
  static const zeusIcon = '${_folderPath}zeus.svg';
  //end of region;

  static const List<String> icons = [
    caodaiIcon,
    cuauhtliIcon,
    ganeshaIcon,
    ganesha2Icon,
    godIcon,
    god2Icon,
    god3Icon,
    god4Icon,
    god5Icon,
    godofwealthIcon,
    godofwealth2Icon,
    goo01Icon,
    good02Icon,
    good03Icon,
    good04Icon,
    good05Icon,
    good06Icon,
    good07Icon,
    good08Icon,
    good09Icon,
    good10Icon,
    good11Icon,
    good12Icon,
    harpIcon,
    hermesIcon,
    orpheusIcon,
    poseidonIcon,
    prayerIcon,
    sunIcon,
    worldIcon,
    zeusIcon,
  ];
}