/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:flutter/material.dart';

import '../../classes/book_paragraph.dart';

class ParagraphSimpleReader extends StatefulWidget {
  final BookParagraph paragraph;
  final bool selected;
  final Function()? onParagraphTap;
  final Function()? onParagraphDoubleTap;
  final Function()? onParagraphLongPress;

  const ParagraphSimpleReader({
    Key? key,
    required this.paragraph,
    this.onParagraphTap,
    this.onParagraphDoubleTap,
    this.onParagraphLongPress,
    this.selected = false,
  }) : super(key: key);

  @override
  ParagraphSimpleReaderState createState() => ParagraphSimpleReaderState();
}

class ParagraphSimpleReaderState extends State<ParagraphSimpleReader> {
  BookParagraph get paragraph => widget.paragraph;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: widget.onParagraphTap,
            onDoubleTap: widget.onParagraphDoubleTap,
            onLongPress: widget.onParagraphLongPress,
            child: RichText(
              text: TextSpan(text: paragraph.text.replaceAll('\n', ' '), style: const TextStyle(color: Colors.black)),
              textAlign: TextAlign.justify,
              textWidthBasis: TextWidthBasis.longestLine,
            ),
          )
        ],
      ),
    );
  }
}
