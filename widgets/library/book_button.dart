/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../classes/book.dart';
import '../../classes/book_library.dart';
import '../../global.dart';

class BookButton extends StatelessWidget {
  final Book book;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final bool selected;

  const BookButton(
      {Key? key,
      required this.book,
      this.selected = false,
      this.onTap,
      this.onDoubleTap,
      this.onLongPress,
      this.icon = Icons.menu_book,
      this.color = Colors.grey})
      : super(key: key);

  BookLibrary get library =>
      app.libraries.firstWhere((l) => l.uuid == book.libraryUuid);

  @override
  Widget build(BuildContext context) {
    double iconSize = selected ? 32 : 28;
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          onLongPress: onLongPress,
          child: Container(
            width: selected ? 70 : 60,
            height: selected ? 70 : 60,
            decoration: ShapeDecoration(
              shape: CircleBorder(
                  side: selected
                      ? BorderSide(
                          width: 2,
                          color: library.color,
                        )
                      : BorderSide(
                          width: 0, color: library.color.withOpacity(.5))),
              color: selected
                  ? library.color.withOpacity(.3)
                  : library.color.withOpacity(.1),
            ),
            padding: EdgeInsets.zero,
            child: Stack(
              children: [
                Center(
                  child: book.bookIcon != null
                      ? SvgPicture.asset(
                          book.bookIcon!,
                          width: iconSize,
                          height: iconSize,
                          color: library.color,
                        )
                      : Icon(
                          icon,
                          size: iconSize,
                          color: library.color,
                        ),
                ),
                if (selected)
                  const Positioned(
                    right: 0,
                    top: 0,
                    child: Icon(Icons.check_circle,
                        size: 24, color: Colors.transparent),
                  ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Icon(Bootstrap.bell_fill,
                      size: 16, color: book.bellColor),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          book.name,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
