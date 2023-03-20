/// -----------------------------------------------------------------------
///  [2021] - [2022] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:flutter/material.dart';

import '../../classes/book.dart';
import '../../widgets/library/book_button.dart';

class BookMergeSourceBar extends StatelessWidget {
  const BookMergeSourceBar({Key? key, required this.books, required this.destination, this.onBookPressed}) : super(key: key);

  final List<Book> books;
  final Book destination;
  final Function(Book book)? onBookPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: GridView(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 150, mainAxisExtent: 100),
        padding: const EdgeInsets.only(top: 20),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        children: [
          ...books.map(
            (book) => BookButton(
              book: book,
              selected: book == destination,
              onTap: () => {if (onBookPressed != null) onBookPressed!(book)},
            ),
          ),
        ],
      ),
    );
  }
}
