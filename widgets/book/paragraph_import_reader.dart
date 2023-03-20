/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:flutter/material.dart';

import '../../classes/book_paragraph.dart';
import '../../extensions.dart';

class ParagraphImportReader extends StatelessWidget {
  final BookParagraph paragraph;
  final bool onlyFirstWords;
  final Function(BookParagraph, String, int)? onWordTap;
  final Function(BookParagraph, String, int)? onWordLongPress;
  final Function()? onParagraphTap;
  final Function()? onParagraphDoubleTap;
  final Function()? onParagraphLongPress;

  const ParagraphImportReader({
    Key? key,
    required this.paragraph,
    this.onlyFirstWords = true,
    this.onWordTap,
    this.onWordLongPress,
    this.onParagraphTap,
    this.onParagraphDoubleTap,
    this.onParagraphLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: paragraph.hasBackground ? (BookParagraph.colors[paragraph.color]?[BookParagraph.colorKeyBackground] ?? Colors.transparent) : Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 5),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (onlyFirstWords)
            GestureDetector(
              onTap: onParagraphTap,
              onDoubleTap: onParagraphDoubleTap,
              onLongPress: onParagraphLongPress,
              child: Text(
                paragraph.text.replaceAll('\n', ' '),
                style: paragraph.isTitle ? BookParagraph.titleTextStyle : BookParagraph.paragraphTextStyle(paragraph.isLarge, paragraph.isBold, paragraph.isItalic),
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (!onlyFirstWords)
            RichText(
              text: TextSpan(
                children: paragraph.asTextSpans(
                  style: paragraph.isTitle ? BookParagraph.titleTextStyle : BookParagraph.paragraphTextStyle(paragraph.isLarge, paragraph.isBold, paragraph.isItalic),
                  onWordTap: onWordTap,
                  onWordLongPress: onWordLongPress,
                ),
              ),
              textAlign: TextAlign.justify,
              textWidthBasis: TextWidthBasis.longestLine,
            ),
        ],
      ),
    );
  }
}
