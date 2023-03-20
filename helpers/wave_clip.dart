import 'package:flutter/material.dart';

/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------

class WaveClip extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    final lowPoint = size.height - 20;
    final highPoint = size.height - 40;
    path.lineTo(0, size.height);
    path.quadraticBezierTo(size.width / 4, highPoint, size.width / 2, lowPoint);
    path.quadraticBezierTo(3 / 4 * size.width, size.height, size.width, lowPoint);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
