
part of 'icon_constant.dart';

abstract class EducationConstant {

  ///[categoryNo] keeps the position of the category
  static const int categoryNo = 12;

  ///path that returns the folder with the icons of the physics's category
  static const String _folderPath = '${IconConstant._folderPath}education/';

  ///Icon used as title of the education category;
  static const categoryIcon = '${IconConstant._folderPath}education_title.svg';

  ///Icon category model with parent the education category and children its icons
  static const IconCategoryModel educationIconsCategory = _$educationCategoryIcons;

  //region Category's icons
  static const education002readingbookIcon = '${_folderPath}002readingbook.svg';
  static const education003graduatedIcon = '${_folderPath}003graduated.svg';
  static const education004trainingIcon = '${_folderPath}004training.svg';
  static const education005openbookIcon = '${_folderPath}005openbook.svg';
  static const education006educationIcon = '${_folderPath}006education.svg';
  static const education007programIcon = '${_folderPath}007program.svg';
  static const education008classroomIcon = '${_folderPath}008classroom.svg';
  static const education009kindergartenIcon = '${_folderPath}009kindergarten.svg';
  static const education010schoolIcon = '${_folderPath}010school.svg';
  static const education011school1Icon = '${_folderPath}011school1.svg';
  static const education012suppliesIcon = '${_folderPath}012supplies.svg';
  static const education013education1Icon = '${_folderPath}013education1.svg';
  static const education014school2Icon = '${_folderPath}014school2.svg';
  static const education015education2Icon = '${_folderPath}015education2.svg';
  //end of region;

  ///A list with all the icons of this category
  static const List<String> icons = [
    education002readingbookIcon,
    education003graduatedIcon,
    education004trainingIcon,
    education005openbookIcon,
    education006educationIcon,
    education007programIcon,
    education008classroomIcon,
    education009kindergartenIcon,
    education010schoolIcon,
    education011school1Icon,
    education012suppliesIcon,
    education013education1Icon,
    education014school2Icon,
    education015education2Icon,
  ];
}