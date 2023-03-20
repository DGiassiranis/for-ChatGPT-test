/// -----------------------------------------------------------------------
///  [2021] - [2022] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:notebars/classes/force_chapter_model.dart';
import 'package:notebars/common/setting_constant.dart';
import 'package:notebars/extensions.dart';
import 'package:notebars/getx/controller/sync_controller.dart';

import '../classes/book.dart';
import '../classes/book_chapter.dart';
import '../classes/book_chapter_for_study.dart';
import '../global.dart';
import '../widgets/study/book_chapter_study_list_item.dart';

class StudyListView extends StatefulWidget {
  const StudyListView({Key? key, this.selectedBooks = const []})
      : super(key: key);

  final List<Book> selectedBooks;

  @override
  StudyListViewState createState() => StudyListViewState();
}

class StudyListViewState extends State<StudyListView> {
  // region Properties
  late bool showOnlySelectedBooks;

  bool sortByTitle = false;
  bool sortByTime = true;
  bool refreshing = false;
  bool synchronized = true;

  // endregion

  // region Getters
  List<BookChapterForStudy> get chapters => sortByTitle
      ? app.studyBooks
          .where((book) => showOnlySelectedBooks
              ? widget.selectedBooks.containsUuid(book.uuid)
              : true)
          .map((book) {
            List<BookChapterForStudy> chapters = [];
            for (var num = 0; num < book.chapters.length; num++) {
              chapters.add(
                  BookChapterForStudy(book: book, chapter: book.chapters[num]));
              for (BookChapter subchapter in book.chapters[num].subChapters) {
                chapters
                    .add(BookChapterForStudy(book: book, chapter: subchapter));
                for (BookChapter unit in subchapter.units) {
                  chapters.add(BookChapterForStudy(book: book, chapter: unit));
                }
              }
            }
            return chapters;
          })
          .expand((i) => i)
          .toList()

          ///This method used just to know what kind of sorting is chosen
          ///Maybe it will change in the future
          ///So, we need ot keep it.
          .sortByPositionsInDataBase()
      : app.studyBooks
          .where((book) => showOnlySelectedBooks
              ? widget.selectedBooks.containsUuid(book.uuid)
              : true)
          .map((book) {
            List<BookChapterForStudy> chapters = [];
            for (var num = 0; num < book.chapters.length; num++) {
              chapters.add(
                  BookChapterForStudy(book: book, chapter: book.chapters[num]));
              for (BookChapter subchapter in book.chapters[num].subChapters) {
                chapters
                    .add(BookChapterForStudy(book: book, chapter: subchapter));
                for (BookChapter unit in subchapter.units) {
                  chapters.add(BookChapterForStudy(book: book, chapter: unit));
                }
              }
            }
            return chapters;
          })
          .expand((i) => i)
          .toList()
          .sortByTimeToStudy();

  // endregion

  // region Methods
  void studyChapter(BookChapterForStudy chapterForStudy, int index) async {
    Navigator.of(context)
        .pushNamed('/study', arguments: chapterForStudy)
        .then((value) async {
      whenReturnFromChapterAction(value, chapterForStudy, index);
    });
  }

  void whenReturnFromChapterAction(
      dynamic value, BookChapterForStudy chapterForStudy, int index) async {
    if (value is Book) {
      value.lastVisitedChapter = chapterForStudy.chapter.uuid;
      await app.saveBook(value, saveInLocalModifications: true);
      await app.fetchBooks();
      if(app.books.isEmpty){
        await Future.delayed(const Duration(milliseconds: 500));
        await app.fetchBooks();
      }
      refresh();
      return;
    } else if (value is ForceChapterModel) {
      await app.saveBook(value.book, saveInLocalModifications: true);
      await app.fetchBooks();
      List<BookChapterForStudy> sortedChapters = chapters.sortByTimeToStudy();
      if (sortedChapters.isNotEmpty){
        value.forceChapterType == ForceChapterType.forceNext ? studyChapter(chapters[index + 1], index + 1) : studyChapter(chapters[index - 1], index - 1 );
      }
      return;
    } else {
      chapterForStudy.book.lastVisitedChapter = chapterForStudy.chapter.uuid;
      await app.saveBook(chapterForStudy.book, saveInLocalModifications: true);
      refresh();
      return;
    }
  }

  void skipReps(BookChapterForStudy chapterForStudy) async {
    chapterForStudy.chapter.studyState = StudyState.values.firstWhere(
        (element) => element.no == (app.settings["quickChangeState"] ?? 3));

    chapterForStudy.chapter.lastRead = DateTime.now();

    await app.saveBook(chapterForStudy.book, saveInLocalModifications: true);
    refresh();
  }

  void restartChapterTimer(BookChapterForStudy chapterForStudy) async {
    setState(() => chapterForStudy.book
        .findChapterById(
            chapterForStudy.chapter.uuid, chapterForStudy.chapter.depth)
        .restartStudyTime());

    await app.saveBook(chapterForStudy.book, saveInLocalModifications: true);
  }

  void resetChapterTimer(BookChapterForStudy chapterForStudy) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Reset the study time of this chapter?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: const Text('Yes'),
              onPressed: () async {
                setState(() => chapterForStudy.chapter.resetStudyTime());

                await app.saveBook(chapterForStudy.book,
                    saveInLocalModifications: true);

                if (mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> refresh() async {
    refreshing = true;

    setState(() {});

    await  Future.delayed(const Duration(milliseconds: 50),
            () => refreshing = false);

    setState(() {});
  }

  // endregion

  void appChangesListenerFn() {
    if (mounted) refresh();
  }

  @override
  void initState() {
    super.initState();

    showOnlySelectedBooks = widget.selectedBooks.isNotEmpty;
    sortByTime = widget.selectedBooks.isEmpty;
    sortByTitle = !sortByTime;
    // app.addListener(appChangesListenerFn);
  }

  @override
  void dispose() {
    super.dispose();

    app.removeListener(appChangesListenerFn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffdbe2e7),
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
        title: const Text('Study List'),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.deepPurpleAccent,
        shape: const CircularNotchedRectangle(),
        child: IconTheme(
          data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          child: Row(
            children: [
              ToggleButtons(
                isSelected: [
                  sortByTime,
                ],
                onPressed: sortByTime
                    ? null
                    : (value) {
                        setState(() {
                          sortByTime = true;
                          sortByTitle = false;
                        });
                      },
                renderBorder: false,
                color: Colors.white,
                selectedColor: Colors.tealAccent,
                disabledColor: Colors.tealAccent,
                fillColor: Colors.deepPurple.withOpacity(.3),
                borderRadius: BorderRadius.circular(10),
                children: const [
                  Icon(Icons.timer_outlined),
                ],
              ),
              ToggleButtons(
                isSelected: [
                  sortByTitle,
                ],
                onPressed: sortByTitle
                    ? null
                    : (value) {
                        setState(() {
                          sortByTitle = true;
                          sortByTime = false;
                        });
                      },
                disabledColor: Colors.tealAccent,
                renderBorder: false,
                color: Colors.white,
                selectedColor: Colors.tealAccent,
                fillColor: Colors.deepPurple.withOpacity(.3),
                borderRadius: BorderRadius.circular(10),
                children: const [
                  Icon(Icons.format_list_bulleted),
                ],
              ),
              const Spacer(),
              ToggleButtons(
                isSelected: [
                  !showOnlySelectedBooks,
                ],
                onPressed: !showOnlySelectedBooks
                    ? null
                    : (value) {
                        setState(() {
                          showOnlySelectedBooks = false;
                        });
                      },
                renderBorder: false,
                color: Colors.white,
                selectedColor: Colors.tealAccent,
                fillColor: Colors.deepPurple.withOpacity(.3),
                disabledColor:
                    widget.selectedBooks.isEmpty ? null : Colors.tealAccent,
                borderRadius: BorderRadius.circular(10),
                children: const [
                  Icon(Bootstrap.funnel),
                ],
              ),
              ToggleButtons(
                isSelected: [
                  showOnlySelectedBooks,
                ],
                onPressed: showOnlySelectedBooks || widget.selectedBooks.isEmpty
                    ? null
                    : (value) {
                        setState(() {
                          showOnlySelectedBooks = true;
                        });
                      },
                renderBorder: false,
                color: Colors.white,
                disabledColor:
                    widget.selectedBooks.isEmpty ? null : Colors.tealAccent,
                selectedColor: Colors.tealAccent,
                fillColor: Colors.deepPurple.withOpacity(.3),
                borderRadius: BorderRadius.circular(10),
                children: const [
                  Icon(Bootstrap.funnel_fill),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent,
        onPressed: null,
        child: Obx(
          () => IconButton(
            icon: Badge(
              badgeColor: Colors.lightBlueAccent,
              showBadge: SyncController.find.modifiedBooks.isNotEmpty,
              badgeContent: Text(
                  SyncController.find.modifiedBooks.length.toString(),
                  style: const TextStyle(color: Colors.white)),
              child: const Icon(
                Icons.sync,
                size: 30,
              ),
            ),
            onPressed: !SyncController.find.needsSync.value
                ? null
                : app.settings[SettingConstant.syncWithGoogleDrive]
                    ? () async {
                        await SyncController.find.synchronize();
                      }
                    : null,
          ),
        ),
      ),
      body: chapters.isNotEmpty
          ? (refreshing
              ? const Center(child: CircularProgressIndicator())
              : AnimationLimiter(
                  child: RefreshIndicator(
                    onRefresh: refresh,
                    child: ListView.builder(
                      itemCount: chapters.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (index + 1 == chapters.length) {
                          return Column(
                            children: [
                              AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: BookChapterStudyListItem(
                                      index: index,
                                      chapterForStudy: chapters[index],
                                      onSkipReps: skipReps,
                                      onStudy: studyChapter,
                                      onResetTimer: resetChapterTimer,
                                      onRestartTimer: restartChapterTimer,
                                      lastVisited: chapters[index]
                                              .book
                                              .lastVisitedChapter ==
                                          chapters[index].chapter.uuid,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: Get.height * 0.1,
                              ),
                            ],
                          );
                        }
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: BookChapterStudyListItem(
                                index: index,
                                chapterForStudy: chapters[index],
                                onSkipReps: skipReps,
                                onStudy: studyChapter,
                                onResetTimer: resetChapterTimer,
                                onRestartTimer: restartChapterTimer,
                                lastVisited:
                                    chapters[index].book.lastVisitedChapter ==
                                        chapters[index].chapter.uuid,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ))
          : Center(
              child: Card(
                color: Colors.transparent,
                elevation: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const Text('No chapters found for studying...'),
                    const SizedBox(height: 20),
                    const SizedBox(height: 20),
                    SvgPicture.asset(
                        'assets/illustrations/undraw_empty_xct9.svg',
                        width: 250),
                  ],
                ),
              ),
            ),
    );
  }
}
