part of 'package:notebars/classes/icon/constant/icon_constant.dart';

class IconCategoryModel extends IconModel {
  const IconCategoryModel({
    required super.display,
    required super.path,
    required this.position,
    required this.icons,
  });

  final List<IconModel> icons;
  final int position;

  static IconCategoryModel nullCategory = const IconCategoryModel(display: 'null', path: 'null', position: -1, icons: []);

  bool get isNullCategory => display == 'null' || path == 'null' || position == -1 || icons.isEmpty;
}
