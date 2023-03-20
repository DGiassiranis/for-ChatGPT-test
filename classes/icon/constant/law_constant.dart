
part of 'icon_constant.dart';

abstract class LawConstant {

  ///[categoryNo] keeps the position of the category
  static const int categoryNo = 20;

  ///path that returns the folder with the icons of the law's category
  static const String _folderPath = '${IconConstant._folderPath}law/';

  ///Icon used as title of the law category;
  static const categoryIcon = '${IconConstant._folderPath}law_title.svg';

  ///Icon category model with parent the law category and children its icons
  static const IconCategoryModel lawIconsCategory = _$lawCategoryIcons;

  //region Category's icons
  static const law001sheriffbadgeIcon = '${_folderPath}001sheriffbadge.svg';
  static const law003courtIcon = '${_folderPath}003court.svg';
  static const law004penIcon = '${_folderPath}004pen.svg';
  static const law005justiceIcon = '${_folderPath}005justice.svg';
  static const law006lawIcon = '${_folderPath}006law.svg';
  static const law007handcuffsIcon = '${_folderPath}007handcuffs.svg';
  static const law008sheriffbadge1Icon = '${_folderPath}008sheriffbadge1.svg';
  static const law009lawsIcon = '${_folderPath}009laws.svg';
  static const law010custodyIcon = '${_folderPath}010custody.svg';
  static const law011policebadgeIcon = '${_folderPath}011policebadge.svg';
  static const law012lawyerIcon = '${_folderPath}012lawyer.svg';
  static const law013policehatIcon = '${_folderPath}013policehat.svg';
  static const law014prisonerIcon = '${_folderPath}014prisoner.svg';
  //end of region;

  ///A list with all the icons of this category
  static const List<String> icons = [
    law001sheriffbadgeIcon,
    law003courtIcon,
    law004penIcon,
    law005justiceIcon,
    law006lawIcon,
    law007handcuffsIcon,
    law008sheriffbadge1Icon,
    law009lawsIcon,
    law010custodyIcon,
    law011policebadgeIcon,
    law012lawyerIcon,
    law013policehatIcon,
    law014prisonerIcon,
  ];
}