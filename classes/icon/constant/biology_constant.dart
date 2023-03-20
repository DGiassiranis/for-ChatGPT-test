
part of 'icon_constant.dart';

abstract class BiologyConstant {

  ///[categoryNo] keeps the position of the category
  static const int categoryNo = 14;

  ///path that returns the folder with the icons of the biology's category
  static const String _folderPath = '${IconConstant._folderPath}biology/';

  ///Icon used as title of the biology category;
  static const categoryIcon = '${IconConstant._folderPath}biology.svg';

  ///Icon category model with parent the biology category and children its icons
  static const IconCategoryModel biologyIconsCategory = _$biologyCategoryIcons;

  //region Category's icons
  static const antivirusIcon = '${_folderPath}antivirus.svg';
  static const bacteriaIcon = '${_folderPath}bacteria.svg';
  static const bacteria2Icon = '${_folderPath}bacteria2.svg';
  static const bacteria3Icon = '${_folderPath}bacteria3.svg';
  static const bacteria4Icon = '${_folderPath}bacteria4.svg';
  static const bacteriologyIcon = '${_folderPath}bacteriology.svg';
  static const bigcelluleIcon = '${_folderPath}bigcellule.svg';
  static const biohazardsignIcon = '${_folderPath}biohazardsign.svg';
  static const dnaIcon = '${_folderPath}dna.svg';
  static const dna2Icon = '${_folderPath}dna2.svg';
  static const dna3Icon = '${_folderPath}dna3.svg';
  static const evolutionIcon = '${_folderPath}evolution.svg';
  static const gasmaskIcon = '${_folderPath}gas-mask.svg';
  static const microscopeIcon = '${_folderPath}microscope.svg';
  static const mitosisIcon = '${_folderPath}mitosis.svg';
  static const moleculeIcon = '${_folderPath}molecule.svg';
  static const petridishIcon = '${_folderPath}petridish.svg';
  static const petridish2Icon = '${_folderPath}petridish2.svg';
  static const virusIcon = '${_folderPath}virus.svg';

  static const List<String> icons = [
    antivirusIcon,
    bacteriaIcon,
    bacteria2Icon,
    bacteria3Icon,
    bacteria4Icon,
    bacteriologyIcon,
    bigcelluleIcon,
    biohazardsignIcon,
    dnaIcon,
    dna2Icon,
    dna3Icon,
    evolutionIcon,
    gasmaskIcon,
    microscopeIcon,
    mitosisIcon,
    moleculeIcon,
    petridishIcon,
    petridish2Icon,
    virusIcon,
  ];

}