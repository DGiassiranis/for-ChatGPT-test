
part of 'icon_constant.dart';

abstract class WorkerConstant {

  ///[categoryNo] keeps the position of the category
  static const int categoryNo = 22;

  ///path that returns the folder with the icons of the worker's category
  static const String _folderPath = '${IconConstant._folderPath}worker/';

  ///Icon used as title of the worker category;
  static const categoryIcon = '${IconConstant._folderPath}worker_title.svg';

  ///Icon category model with parent the worker category and children its icons
  static const IconCategoryModel workerIconsCategory = _$workerCategoryIcons;

  //region Category's icons
  static const worker001workerIcon = '${_folderPath}001worker.svg';
  static const worker002teamIcon = '${_folderPath}002team.svg';
  static const worker003trolleyIcon = '${_folderPath}003trolley.svg';
  static const worker005worker2Icon = '${_folderPath}005worker2.svg';
  static const worker006waiterIcon = '${_folderPath}006waiter.svg';
  static const worker007worker3Icon = '${_folderPath}007worker3.svg';
  static const worker008hardhatIcon = '${_folderPath}008hardhat.svg';
  static const worker009weldingIcon = '${_folderPath}009welding.svg';
  static const worker010workspaceIcon = '${_folderPath}010workspace.svg';
  static const worker011mechanicIcon = '${_folderPath}011mechanic.svg';
  static const worker012engineerIcon = '${_folderPath}012engineer.svg';
  static const worker013engineer1Icon = '${_folderPath}013engineer1.svg';
  static const worker014hammerIcon = '${_folderPath}014hammer.svg';
  static const worker015protestIcon = '${_folderPath}015protest.svg';
  static const worker016masonryIcon = '${_folderPath}016masonry.svg';
  static const worker017cofounderIcon = '${_folderPath}017cofounder.svg';
  static const worker018constructionIcon = '${_folderPath}018construction.svg';
  static const worker019diggingIcon = '${_folderPath}019digging.svg';
  static const worker020employeeIcon = '${_folderPath}020employee.svg';
  static const worker021bestemployeeIcon = '${_folderPath}021bestemployee.svg';
  static const worker022labtechnicianIcon = '${_folderPath}022labtechnician.svg';
  static const worker023farmerIcon = '${_folderPath}023farmer.svg';
  static const worker024vineyardIcon = '${_folderPath}024vineyard.svg';
  static const worker025tractorIcon = '${_folderPath}025tractor.svg';
  static const worker026farmIcon = '${_folderPath}026farm.svg';
  static const worker027shovelsIcon = '${_folderPath}027shovels.svg';
  static const worker028farmer1Icon = '${_folderPath}028farmer1.svg';
  static const worker029standIcon = '${_folderPath}029stand.svg';
  static const worker030agricultureIcon = '${_folderPath}030agriculture.svg';
  //end of region;

  ///A list with all the icons of this category
  static const List<String> icons = [
    worker001workerIcon,
    worker002teamIcon,
    worker003trolleyIcon,
    worker005worker2Icon,
    worker006waiterIcon,
    worker007worker3Icon,
    worker008hardhatIcon,
    worker009weldingIcon,
    worker010workspaceIcon,
    worker011mechanicIcon,
    worker012engineerIcon,
    worker013engineer1Icon,
    worker014hammerIcon,
    worker015protestIcon,
    worker016masonryIcon,
    worker017cofounderIcon,
    worker018constructionIcon,
    worker019diggingIcon,
    worker020employeeIcon,
    worker021bestemployeeIcon,
    worker022labtechnicianIcon,
    worker023farmerIcon,
    worker024vineyardIcon,
    worker025tractorIcon,
    worker026farmIcon,
    worker027shovelsIcon,
    worker028farmer1Icon,
    worker029standIcon,
    worker030agricultureIcon,
  ];
}