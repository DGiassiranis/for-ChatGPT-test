

import 'package:flutter/material.dart';

class PrefixIndent extends StatelessWidget {
  const PrefixIndent({Key? key, required this.depth}) : super(key: key);

  final int depth;
  final double width = 30;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: depth * width,
    );
  }
}
