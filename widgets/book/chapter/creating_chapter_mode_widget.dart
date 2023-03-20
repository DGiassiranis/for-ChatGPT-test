import 'package:flutter/material.dart';
import 'package:notebars/classes/book.dart';
import 'package:notebars/classes/book_chapter.dart';
import 'package:notebars/widgets/book/chapters_list_with_titles.dart';

class CreatingChapterModeWidget extends StatelessWidget {
  const CreatingChapterModeWidget({
    Key? key,
    required this.book,
    required this.bookChanged,
    required this.currentIndexChanged,
    required this.addChapter,
  }) : super(key: key);

  final Book book;
  final Function() bookChanged;
  final Function(int newIndex) currentIndexChanged;
  final Function() addChapter;

  @override
  Widget build(BuildContext context) {
    return ChaptersListWithTitles(
      book: book,
      onTapChapter: _onTapChapter,
      onTapSubChapter: _onTapSubChapter,
      onTapUnit: _onTapUnit,
      addChapter: addChapter,
    );
  }

  /* Edit chapters region*/

  /*
  ON TAP CHAPTER CASES
  CASE 1:
  chapter index == 0;
  Expectations:
    1. Nothing will change;
  (WORKS)

  CASE 2:
  chapter(c1).index != 0
  chapter (c1) has nothing under it
  Expectations:
    1. It will become subchapter of the previous chapter(c0)
    2. It will have as parentChapterUuid the c0 uuid
  (WORKS

  CASE 3:
  chapter(c1).index != 0
  chapter (c1) has one subchapter(sc1) under it
  Expectations:
    1. c1 will become subchapter of the previous chapter(c0)
    2. sc1 will become subchapter of the c0
    3. c1, sc1 will change their parentChapterUuid to c0's uuid;
  (WORKS)

  CASE 4:
  chapter(c1).index != 0
  chapter (c1) has one subchapter(sc1) under it
  under sc1 there is a unit (u1)
  Expectations:
    1. c1 will become subchapter of the previous chapter(c0)
    2. sc1 will become subchapter of the c0
    3. c1, sc1 will change their parentChapterUuid to c0's uuid;
    4. u1 parentChapterUuid will change to c0's uuid;
  (FIXED)
  * */

  void _onTapChapter(BookChapter chapter) {
    int index = book.chapters.indexOf(chapter);
    if (index == 0) {
      return;
    }
    currentIndexChanged(book.chapters.indexOf(book.chapters[index - 1]));

    List<BookChapter> chaptersSubChapters = List.of(chapter.subChapters);
    chapter.subChapters.clear();
    chapter.depth = 1;
    chapter.parentChapterUuid = book.chapters[index - 1].uuid;
    book.chapters[index - 1].subChapters.add(chapter);
    book.chapters[index - 1].subChapters.addAll(chaptersSubChapters);

    for (var element in book.chapters[index - 1].subChapters) {
      element.parentChapterUuid = book.chapters[index - 1].uuid;
    }

    for (var subchapter in book.chapters[index - 1].subChapters) {
      for (var unit in subchapter.units) {
        unit.parentChapterUuid = book.chapters[index - 1].uuid;
      }
    }

    book.chapters.remove(chapter);

    bookChanged();
  }

  void _onTapSubChapter(
      BookChapter subChapter, BookChapter parentChapter, Book book) {
    /*
    ON TAP SUBCHAPTER CASES
    CASE 1:
    Sub chapter is at the first position -> index = 0;
    There is nothing under it:
    Expectations: Sub chapter will become chapter again
    parentChapterUuid will be removed;
    (WORKS)

    CASE 2:
    Sub chapter(sc1) is at the first position -> index = 0;
    There is a another subchapter under this (sc2)
    Expectations:
      1. sc1 will become chapter again
      2. The sc2 will become subchapter in the sc1
      3. The sc2 will change its parentChapterUuid and it will get the uuid of the sc1
    (WORKS)

    CASE 3:
    Sub chapter(sc1) is at the first position -> index = 0;
    There are more than one subchapters under this (sc2,sc3)
    Expectations:
      1. sc1 will become chapter again
      2. The sc2, sc3 will become subchapter in the sc1
      3. The sc2, sc3 will change their parentChapterUuid and they will get the uuid of the sc1
    (WORKS)

    CASE 4:
    Sub chapter(sc1) is at the first position -> index = 0;
    There is one subchapter under this (sc2)
    Under sc2 there is a unit(u1)
    Expectations:
      1. sc1 will become chapter again
      2. The sc2 will become subchapter in the sc1
      3. The sc2 will change its parentChapterUuid and it will get the uuid of the sc1
      4. The u1 will change its parentChapterUuid and it will get the uuid of the sc1
    (FIXED)

    CASE 5:
    Sub chapter(sc1) is at the first position -> index = 0;
    There is one subchapter under this (sc2)
    Under sc2 there is a unit(u1, u2)
    Expectations:
      1. sc1 will become chapter again
      2. The sc2, sc3 will become subchapter in the sc1
      3. The sc2, sc3 will change their parentChapterUuid and they will get the uuid of the sc1
      4. The u1,u2 will change its parentChapterUuid and it will get the uuid of the sc1
    (FIXED)

    CASE 5:
    Sub chapter(sc1) is at the first position -> index = 0;
    There is one subchapter under this (sc2,sc3)
    Under sc2 there is a unit (u1)
    Expectations:
      1. sc1 will become chapter again
      2. The sc2 will become subchapter in the sc1
      3. The sc2 will change its parentChapterUuid and it will get the uuid of the sc1
      4. The u1will change its parentChapterUuid and it will get the uuid of the sc1
    (FIXED)

    CASE 5:
    Sub chapter(sc1) is at the first position -> index = 0;
    There is one subchapter under this (sc2,sc3)
    Under sc2 there is a unit (u1)
    Under sc3 there is a unit (u2)
    Expectations:
      1. sc1 will become chapter again
      2. The sc2,sc3 will become subchapters in the sc1
      3. The sc2,sc3 will change their parentChapterUuid and they will get the uuid of the sc1
      4. The u1, u2 will change their parentChapterUuid and they will get the uuid of the sc1
    (FIXED)

    CASE 6:
    Sub chapter(sc1) is not at the first position -> index = 0;
    The subchapter will become unit under the subchapter(sc2) before it
    Expectations:
      1. sc1 will change its parentSubchapterUuid and it will get the sc2 uuid
    (WORKS)
    * */
    int bookIndex = book.chapters.indexOf(parentChapter);
    int index = parentChapter.subChapters.indexOf(subChapter);
    if (index == 0) {

      subChapter.depth = 0;
      for (var element in subChapter.units) {
        element.depth = 1;
      }
      subChapter.subChapters.addAll(List.of(subChapter.units));
      subChapter.parentChapterUuid = '';

      subChapter.subChapters.addAll(book.chapters[bookIndex].subChapters.sublist(index + 1));
      for (var element in subChapter.subChapters) {
        element.parentSubchapterUuid = '';
        element.parentChapterUuid = subChapter.uuid;
        for(BookChapter unit in element.units){
          unit.parentChapterUuid = subChapter.uuid;
        }
      }
      subChapter.parentChapterUuid = '';
      book.chapters[bookIndex].subChapters = book.chapters[bookIndex].subChapters.sublist(0,index + 1);
      subChapter.units.clear();
      subChapter.parentChapterUuid = null;
      book.chapters.insert(bookIndex + 1, subChapter);
      book.chapters[bookIndex].subChapters.remove(subChapter);
      bookChanged();
      return;
    }
    subChapter.depth = 2;
    List<BookChapter> subChaptersUnits = List.of(subChapter.units);
    for (var element in subChaptersUnits) {
      element.depth = 2;
      element.parentChapterUuid = book.chapters[bookIndex].uuid;
      element.parentSubchapterUuid = book.chapters[bookIndex].subChapters[index - 1].uuid;
    }

    subChapter.parentSubchapterUuid = book.chapters[bookIndex].subChapters[index - 1].uuid;
    subChapter.parentChapterUuid = book.chapters[bookIndex].uuid;

    subChapter.units.clear();
    book.chapters[bookIndex].subChapters[index - 1].units.add(subChapter);
    book.chapters[bookIndex].subChapters[index - 1].units
        .addAll(subChaptersUnits);
    parentChapter.subChapters.remove(subChapter);
    bookChanged();
  }

  void _onTapUnit(BookChapter unit, BookChapter subChapter,
      BookChapter parentChapter, Book book) {

    int unitIndex = subChapter.units.indexOf(unit);
    int subChapterIndex = parentChapter.subChapters.indexOf(subChapter);
    int chapterIndex = book.chapters.indexOf(parentChapter);

    List<BookChapter> newSubchapters = subChapter.units.sublist(unitIndex + 1);
    newSubchapters.addAll(
        book.chapters[chapterIndex].subChapters.sublist(subChapterIndex + 1));
    book.chapters[chapterIndex].subChapters
        .sublist(subChapterIndex + 1)
        .forEach((element) {
      book.chapters[chapterIndex].subChapters.remove(element);
    });

    unit.depth = 0;
    unit.parentChapterUuid = null;
    unit.parentSubchapterUuid = null;
    for (var element in newSubchapters) {
      element.depth = 1;
      element.parentChapterUuid = unit.uuid;
      element.parentSubchapterUuid = null;
      for (var innerUnit in element.units) {
        innerUnit.parentChapterUuid = unit.uuid;
      }}
    unit.subChapters = newSubchapters;

    book.chapters.insert(chapterIndex + 1, unit);
    book.chapters[chapterIndex].subChapters[subChapterIndex].units =
        subChapter.units.sublist(0, unitIndex);
    bookChanged();
  }
/* End of edit chapters region*/
}
