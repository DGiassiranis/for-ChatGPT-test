/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:notebars/extensions.dart';

import '../../classes/book.dart';
import '../../classes/book_library.dart';
import '../../global.dart';
import '../../widgets/library/book_button.dart';

class LibraryCard extends StatelessWidget {
  final BookLibrary library;
  final List<Book> selectedBooks;
  final VoidCallback? onAddBookPressed;
  final Function(Book book)? onBookPressed;
  final Function(Book book)? onBookLongPressed;
  final Function(bool)? onToggleLibrary;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;

  const LibraryCard(
      {Key? key,
      required this.library,
        this.selectedBooks = const [],
      this.onEditPressed,
      this.onDeletePressed,
      this.onBookPressed,
      this.onBookLongPressed,
      this.onToggleLibrary,
      this.onAddBookPressed,
      })
      : super(key: key);

  // region Getters
  Iterable<Book> get books => app.books.where((book) => book.libraryUuid == library.uuid).toList()..sort((a, b) => a.name.compareTo(b.name));
  // endregion

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Card(
        child: ExpansionTile(
          tilePadding: const EdgeInsets.only(left: 20),
          textColor: Colors.black87,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Switch(value: library.enableStudying, onChanged: onToggleLibrary, activeColor: library.color),
              PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  padding: EdgeInsets.zero,
                  offset: const Offset(0, 40),
                  itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                        PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: const [Icon(Icons.edit), SizedBox(width: 5), Text('Edit library')],
                            )),
                        PopupMenuItem<String>(
                          value: 'delete',
                          enabled: library.books.isEmpty,
                          child: Row(
                            children: const [Icon(Icons.delete), SizedBox(width: 5), Text('Delete library')],
                          ),
                        ),
                      ],
                  onSelected: (String action) {
                    switch (action) {
                      case 'edit':
                        onEditPressed!();
                        break;

                      case 'delete':
                        onDeletePressed!();
                        break;
                    }
                  }),
            ],
          ),
          title: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Bootstrap.collection_fill, color: library.color, size: 36),
                    const SizedBox(width: 15),
                    Expanded(
                        child: Text(
                      library.name,
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.fade,
                      softWrap: true,
                      maxLines: 2,
                    )),
                  ],
                ),
              ),
            ],
          ),
          children: <Widget>[
            // region Books list
            if (books.isEmpty)
              Card(
                color: Colors.transparent,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      const Text('No books found in this library...'),
                      const SizedBox(height: 20),
                      ElevatedButton(onPressed: onAddBookPressed, child: const Text('Add a new book...')),
                      const SizedBox(height: 20),
                      SvgPicture.asset(
                        'assets/illustrations/undraw_reading_time_gvg0.svg',
                        width: 150,
                      ),
                    ],
                  ) ,
                ),
              ),
            if (books.isNotEmpty)
              GridView(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 150, mainAxisExtent: 100),
                padding: const EdgeInsets.only(top: 20),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                children: [
                  ...books.map(
                    (book) => BookButton(
                      book: book,
                      selected: selectedBooks.containsUuid(book.uuid),
                      onTap: () => {if (onBookPressed != null) onBookPressed!(book)},
                      onLongPress: () => {if (onBookLongPressed != null) onBookLongPressed!(book)},
                    ),
                  ),
                  BookButton(
                    book: Book(name: 'Add a book...', libraryUuid: library.uuid),
                    icon: Icons.add,
                    color: library.color,
                    onTap: onAddBookPressed,
                  ),
                ],
              ),
            // endregion
          ],
        ),
      ),
    );
  }
}
