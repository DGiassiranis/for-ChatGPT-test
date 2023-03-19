import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:notebars/classes/icon/constant/icon_constant.dart';

class IconSelectSvgWidget extends StatelessWidget {
  const IconSelectSvgWidget({
    Key? key,
    required this.iconColor,
    required this.iconSize,
    required this.onIconTap,
    required this.categoryModel,
    required this.wrapSpacing,
  }) : super(key: key);

  final Color iconColor;
  final double iconSize;
  final IconCategoryModel categoryModel;
  final Function(String iconPath) onIconTap;
  final double wrapSpacing;

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();
    return Container(
      padding: const EdgeInsets.all(15.0),
      height: MediaQuery.of(context).size.height * 0.55,
      width: double.infinity,
      child: RawScrollbar(
        controller: scrollController,
        thumbColor: iconColor,
        thumbVisibility: false,
        thickness: 5.0,
        child: SingleChildScrollView(
          controller: scrollController,
          child: Wrap(
            alignment: WrapAlignment.center,
            runSpacing: wrapSpacing,
            spacing: wrapSpacing,
            children: [
              _IconWidget(iconPath: categoryModel.path, onIconTap: onIconTap, iconColor: iconColor, iconSize: iconSize),
              ...categoryModel.icons.map((icon) => _IconWidget(iconPath: icon.path, onIconTap: onIconTap, iconColor: iconColor, iconSize: iconSize))
            ],
          ),
        ),
      ),
    );
  }

}

class _IconWidget extends StatelessWidget {
  const _IconWidget({Key? key, required this.iconPath, required this.onIconTap, required this.iconColor, required this.iconSize,}) : super(key: key);

  final String iconPath;
  final Function(String path) onIconTap;
  final Color iconColor;
  final double iconSize;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onIconTap(iconPath),
      child: SvgPicture.asset(
        iconPath,
        color: iconColor,
        width: iconSize,
        height: iconSize,
      ),
    );
  }
}

