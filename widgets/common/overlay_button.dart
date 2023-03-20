/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:popover/popover.dart';

class OverlayButton extends StatelessWidget {
  final Widget icon;
  final PopoverDirection direction;
  final Widget child;
  final String tooltip;
  final Color color;
  final Color overlayColor;
  final BoxConstraints? constraints;

  const OverlayButton(
      {Key? key,
      required this.icon,
      required this.child,
      this.direction = PopoverDirection.top,
      this.tooltip = '',
      this.color = Colors.white,
      this.overlayColor = Colors.transparent,
      this.constraints})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.all(0),
      icon: icon,
      tooltip: tooltip,
      onPressed: () {
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
    );
  }
}
