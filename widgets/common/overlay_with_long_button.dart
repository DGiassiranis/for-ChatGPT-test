import 'package:flutter/material.dart';
import 'package:popover/popover.dart';

class OverlayWithLongButton extends StatelessWidget {
  const OverlayWithLongButton({
    Key? key,
    required this.iconData,
    required this.direction,
    required this.child,
    required this.tooltip,
    this.color = Colors.white,
    this.overlayColor = Colors.transparent,
    this.constraints,
    this.iconColor,
    required this.onTap,
    this.finishShiftingMode,
  }) : super(key: key);

  final IconData iconData;
  final PopoverDirection direction;
  final Widget child;
  final String tooltip;
  final Color color;
  final Color overlayColor;
  final Color? iconColor;
  final BoxConstraints? constraints;
  final Function() onTap;
  final Function()? finishShiftingMode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: onTap,
        onLongPress: () {
          if(finishShiftingMode != null) finishShiftingMode!();
          showPopover(
            context: context,
            constraints: constraints,
            transitionDuration: const Duration(milliseconds: 150),
            bodyBuilder: (context) => child,
            direction: direction,
            backgroundColor: color,
            barrierColor: overlayColor,
            barrierDismissible: true,
            arrowHeight: 5,
            arrowWidth: 8,
          );
        },
        child: Icon(
          iconData,
          color: iconColor,
        ),
      ),
    );
  }
}
