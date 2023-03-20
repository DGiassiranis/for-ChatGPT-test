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
import 'package:notebars/common/setting_constant.dart';
import 'package:notebars/getx/controller/sync_controller.dart';

import '../classes/book.dart';
import '../classes/book_chapter_for_study.dart';
import '../global.dart';
import '../widgets/book/book_chapter_list_item.dart';

class ChapterListView extends StatefulWidget {
  const ChapterListView({Key? key, this.books = const []}) : super(key: key);

  final List<Book> books;

  @override
  ChapterListViewState createState() => ChapterListViewState();
}

class ChapterListViewState extends State<ChapterListView> {
  // region Properties
  bool refreshing = false;
  bool synchronized = true;
  // endregion

  // region Getters
  List<BookChapterForStudy> get chapters => widget.books
      .map((book) {
        List<BookChapterForStudy> chapters = [];

        for (var num = 0; num < book.allChapters.length; num++) {
          chapters.add(BookChapterForStudy(book: book, chapter: book.allChapters[num]));
        }

        return chapters;
      })
      .expand((i) => i)
      .toList();
  // endregion

  // region Methods
  void editChapter(BookChapterForStudy chapterForStudy) async {
    chapterForStudy.book.lastVisitedChapter = chapterForStudy.chapter.uuid;

    await app.saveBook(chapterForStudy.book, saveInLocalModifications: true);

    if (!mounted){
      return;
    }
    Navigator.of(context).pushNamed('/book/notes/chapter', arguments: chapterForStudy).then((_) => refresh());
  }

  Future<void> refresh() async {
    refreshing = true;
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 50), () => setState(() => refreshing = false));
    setState(() {});
  }
  // endregion

  void appChangesListenerFn() {
    if (mounted) refresh();
  }

  @override
  void initState() {
    super.initState();
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
        title: const Text('Chapters List'),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.deepPurpleAccent,
        shape: const CircularNotchedRectangle(),
        child: IconTheme(
          data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          child: Row(
            children: const [
              ///because we needed to set the same size without icons,
              ///we just put inside a null IconButton Widget;
              IconButton(onPressed: null, icon: SizedBox())
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent,
        onPressed: null,
        child: Obx(() => IconButton(
          icon: Badge(
            badgeColor: Colors.lightBlueAccent,
            showBadge: SyncController.find.modifiedBooks.isNotEmpty,
            badgeContent: Text(SyncController.find.modifiedBooks.length.toString(),
                style: const TextStyle(color: Colors.white)),
            child: const Icon(
              Icons.sync,
              size: 30,
            ),
          ),
          onPressed: !SyncController.find.needsSync.value
              ? null
              : app.settings[SettingConstant.syncWithGoogleDrive] ? () async {

            await SyncController.find.synchronize();

          } : null,
        ), ),
      ),
      body: chapters.isNotEmpty
          ? (refreshing
              ? null
              : AnimationLimiter(
                  child: RefreshIndicator(
                    onRefresh: refresh,
                    child: ListView.builder(
                      itemCount: chapters.length,
                      itemBuilder: (BuildContext context, int index) {
                        if(index + 1 == chapters.length ){
                          return Column(
                            children: [
                            AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: BookChapterListItem(
                                  chapterForStudy: chapters[index],
                                  onEdit: editChapter,
                                  lastVisited: chapters[index].book.lastVisitedChapter == chapters[index].chapter.uuid,
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
                              child: BookChapterListItem(
                                chapterForStudy: chapters[index],
                                onEdit: editChapter,
                                lastVisited: chapters[index].book.lastVisitedChapter == chapters[index].chapter.uuid,
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
                    const Text('No chapters found...'),
                    const SizedBox(height: 20),
                    const SizedBox(height: 20),
                    SvgPicture.asset('assets/illustrations/undraw_empty_xct9.svg', width: 250),
                  ],
                ),
              ),
            ),
    );
  }
}
