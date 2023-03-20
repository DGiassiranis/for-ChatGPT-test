
part of 'icon_constant.dart';

abstract class PhysicsConstant {

  ///[categoryNo] keeps the position of the category
  static const int categoryNo = 12;

  ///path that returns the folder with the icons of the physics's category
  static const String _folderPath = '${IconConstant._folderPath}physics/';

  ///Icon used as title of the physics category;
  static const categoryIcon = '${IconConstant._folderPath}physics.svg';

  ///Icon category model with parent the physics category and children its icons
  static const IconCategoryModel physicsIconsCategory = _$physicsCategoryIcons;

  //region Category's icons
  static const electricCircuitIcon = '${_folderPath}electric-circuit.svg';
  static const experimentIcon = '${_folderPath}experiment.svg';
  static const frictionIcon = '${_folderPath}friction.svg';
  static const gravityIcon = '${_folderPath}gravity.svg';
  static const hydraulicIcon = '${_folderPath}hydraulic.svg';
  static const magnetIcon = '${_folderPath}magnet.svg';
  static const magneticIcon = '${_folderPath}magnetic.svg';
  static const magnetsIcon = '${_folderPath}magnets.svg';
  static const pendulumIcon = '${_folderPath}pendulum.svg';
  static const physicsIcon = '${_folderPath}physics.svg';
  static const physics2Icon = '${_folderPath}physics2.svg';
  static const physics3Icon = '${_folderPath}physics3.svg';
  static const pulleyIcon = '${_folderPath}pulley.svg';
  static const theoryIcon = '${_folderPath}theory.svg';
  static const visionIcon = '${_folderPath}vision.svg';
  static const waveIcon = '${_folderPath}wave.svg';
  static const ww000threearrowsIcon = '${_folderPath}ww000threearrows.svg';
  static const ww001dimensions2Icon = '${_folderPath}ww001dimensions2.svg';
  static const ww002dimensionsIcon = '${_folderPath}ww002dimensions.svg';
  static const ww004dimensionIcon = '${_folderPath}ww004dimension.svg';
  static const ww004thoughtIcon = '${_folderPath}ww004thought.svg';
  static const ww005dimensions1Icon = '${_folderPath}ww005dimensions1.svg';
  static const ww005scalescreenIcon = '${_folderPath}ww005scalescreen.svg';
  static const ww006dimension2Icon = '${_folderPath}ww006dimension2.svg';
  static const ww006dimension3Icon = '${_folderPath}ww006dimension3.svg';
  static const ww007dimension1Icon = '${_folderPath}ww007dimension1.svg';
  static const ww008measureIcon = '${_folderPath}ww008measure.svg';
  static const ww010squaremeasumentIcon = '${_folderPath}ww010squaremeasument.svg';
  static const ww011solarpanelIcon = '${_folderPath}ww011solarpanel.svg';
  static const ww013dimensions3Icon = '${_folderPath}ww013dimensions3.svg';
  static const ww014sphereIcon = '${_folderPath}ww014sphere.svg';
  static const ww016measure1Icon = '${_folderPath}ww016measure1.svg';
  static const ww017dimension4Icon = '${_folderPath}ww017dimension4.svg';
  //end of region;

  ///A list with all the icons of this category
  static const List<String> icons = [
    electricCircuitIcon,
    experimentIcon,
    frictionIcon,
    gravityIcon,
    hydraulicIcon,
    magnetIcon,
    magneticIcon,
    magnetsIcon,
    pendulumIcon,
    physicsIcon,
    physics2Icon,
    physics3Icon,
    pulleyIcon,
    theoryIcon,
    visionIcon,
    waveIcon,
    ww000threearrowsIcon,
    ww001dimensions2Icon,
    ww002dimensionsIcon,
    ww004dimensionIcon,
    ww004thoughtIcon,
    ww005dimensions1Icon,
    ww005scalescreenIcon,
    ww006dimension2Icon,
    ww006dimension3Icon,
    ww007dimension1Icon,
    ww008measureIcon,
    ww010squaremeasumentIcon,
    ww011solarpanelIcon,
    ww013dimensions3Icon,
    ww014sphereIcon,
    ww016measure1Icon,
    ww017dimension4Icon,
  ];
}