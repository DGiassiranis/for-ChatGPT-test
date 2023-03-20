import 'package:notebars/classes/book.dart';

class BookToSetUp {
  const BookToSetUp({
    required this.book,
    this.chapterUuid,
  });

  final Book book;
  final String? chapterUuid;
}
