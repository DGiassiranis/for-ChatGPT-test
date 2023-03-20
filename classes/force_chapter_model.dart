

import 'package:notebars/classes/book.dart';

class ForceChapterModel {

  const ForceChapterModel({required this.book, required this.forceChapterType});

  final Book book;
  final ForceChapterType forceChapterType;

}

enum ForceChapterType{
  forceNext,
  forcePrevious,
}