
part of 'icon_constant.dart';

abstract class PlantConstant{
  ///[categoryNo] keeps the position of the category
  static const int categoryNo = 2;

  ///path that returns the folder with the icons of the human's category
  static const String _folderPath = '${IconConstant._folderPath}plant/';

  ///Icon used as title of the human category;
  static const categoryIcon = '${IconConstant._folderPath}plant.svg';

  ///Icon category model with parent the plant category and children its icons
  static const IconCategoryModel plantIconsCategory = _$plantCategoryIcons;

  //region Category's icons
  static const anemoneIcon = '${_folderPath}anemone.svg';
  static const appletreeIcon = '${_folderPath}appletree.svg';
  static const branchleavesIcon = '${_folderPath}branchleaves.svg';
  static const burningIcon = '${_folderPath}burning.svg';
  static const cherryblossomIcon = '${_folderPath}cherryblossom.svg';
  static const elmIcon = '${_folderPath}elm.svg';
  static const flowerIcon = '${_folderPath}flower.svg';
  static const flower2Icon = '${_folderPath}flower2.svg';
  static const leafIcon = '${_folderPath}leaf.svg';
  static const leavesIcon = '${_folderPath}leaves.svg';
  static const lotusIcon = '${_folderPath}lotus.svg';
  static const lotusflowerIcon = '${_folderPath}lotusflower.svg';
  static const olivesIcon = '${_folderPath}olives.svg';
  static const olivetreeIcon = '${_folderPath}olivetree.svg';
  static const pineconeIcon = '${_folderPath}pinecone.svg';
  static const planttreeIcon = '${_folderPath}planttree.svg';
  static const roseIcon = '${_folderPath}rose.svg';
  static const rose2Icon = '${_folderPath}rose2.svg';
  static const rose3Icon = '${_folderPath}rose3.svg';
  static const spiderplantIcon = '${_folderPath}spider-plant.svg';
  static const treeIcon = '${_folderPath}tree.svg';
  static const tree01Icon = '${_folderPath}tree01.svg';
  static const tree02Icon = '${_folderPath}tree02.svg';
  static const tree03Icon = '${_folderPath}tree03.svg';
  static const tree04Icon = '${_folderPath}tree04.svg';
  static const tree05Icon = '${_folderPath}tree05.svg';
  static const tree06Icon = '${_folderPath}tree06.svg';
  static const tree07Icon = '${_folderPath}tree07.svg';
  static const tree09Icon = '${_folderPath}tree09.svg';
  static const tree2Icon = '${_folderPath}tree2.svg';
  static const treeo8Icon = '${_folderPath}treeo8.svg';
  static const wood2Icon = '${_folderPath}wood2.svg';
  static const wood3Icon = '${_folderPath}wood3.svg';
  static const woodcuttingIcon = '${_folderPath}woodcutting.svg';
  //end of region;

  ///A list with all the icons of this category
  static const List<String> icons = [
    anemoneIcon,
    appletreeIcon,
    branchleavesIcon,
    burningIcon,
    cherryblossomIcon,
    elmIcon,
    flowerIcon,
    flower2Icon,
    leafIcon,
    leavesIcon,
    lotusIcon,
    lotusflowerIcon,
    olivesIcon,
    olivetreeIcon,
    pineconeIcon,
    planttreeIcon,
    roseIcon,
    rose2Icon,
    rose3Icon,
    spiderplantIcon,
    treeIcon,
    tree01Icon,
    tree02Icon,
    tree03Icon,
    tree04Icon,
    tree05Icon,
    tree06Icon,
    tree07Icon,
    tree09Icon,
    tree2Icon,
    treeo8Icon,
    wood2Icon,
    wood3Icon,
    woodcuttingIcon,
  ];
}