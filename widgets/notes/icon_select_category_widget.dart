import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:notebars/classes/icon/constant/icon_constant.dart';

class IconSelectCategoryWidget extends StatelessWidget {
  const IconSelectCategoryWidget({
    Key? key,
    required this.iconColor,
    required this.iconSize,
    required this.onCategoryTap,
    required this.wrapSpacing,
    this.hasDeleteIcon = false,
    required this.onDeleteIconTap,
  }) : super(key: key);

  final Color iconColor;
  final double iconSize;
  final Function(IconCategoryModel category) onCategoryTap;
  final Function() onDeleteIconTap;
  final double wrapSpacing;
  final bool hasDeleteIcon;

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
              if (hasDeleteIcon)
                InkWell(
                  onTap: onDeleteIconTap,
                  child: Icon(
                    Icons.delete_forever_outlined,
                    color: iconColor,
                    size: iconSize,
                  ),
                ),
              ...IconConstant.iconCategories.map((category) => InkWell(
                    onTap: () => onCategoryTap(category),
                    child: SvgPicture.asset(
                      category.path,
                      color: iconColor,
                      width: iconSize,
                      height: iconSize,
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
