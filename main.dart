/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:notebars/classes/book_to_setup.dart';
import 'package:notebars/common/route_constant.dart';
import 'package:notebars/getx/binding/app_binding.dart';
import 'package:notebars/views/deleted_books_view.dart';

import 'classes/book.dart';
import 'classes/book_chapter_for_study.dart';
import 'global.dart';
import 'views/book_merge_view.dart';
import 'views/book_notes_view.dart';
import 'views/book_read_view.dart';
import 'views/book_setup_view.dart';
import 'views/chapter_list_view.dart';
import 'views/landing_view.dart';
import 'views/libraries_view.dart';
import 'views/settings_view.dart';
import 'views/study_list_view.dart';
import 'package:google_sign_in_dartio/google_sign_in_dartio.dart';

void main() async {
  // Allow Flutter initialize first to avoid the "ServicesBinding.defaultBinaryMessenger was accessed before the binding was initialized" exception
  // caused by loading the JSON asset inside globalSetup()
  WidgetsFlutterBinding.ensureInitialized();

  // Wait for hive database to initialize
  await Hive.initFlutter();

  // Wait for global setup to initialize
  await globalSetup();

  if (Platform.isWindows) {
    await GoogleSignInDart.register(clientId: '252130809125-1a3h4ddiol2bm2d0vts850f7ua9skqk5.apps.googleusercontent.com',);
  }


  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return InAppNotification(
      child: GetMaterialApp(
        scrollBehavior: MyScrollBehavior(),
        initialBinding: AppBinding(),
        title: 'Notebars',
        theme: ThemeData(
          fontFamily: 'Roboto',
          primarySwatch: Colors.deepPurple,
        ),
        initialRoute: '/',
        routes: {
          // region Common routes
          RouteConstant.landingView: (context) => const LandingView(),
          RouteConstant.libraries: (context) => const LibrariesView(),
          RouteConstant.studyList: (context) => StudyListView(selectedBooks: ModalRoute.of(context)?.settings.arguments as List<Book>),
          RouteConstant.study: (context) => BookNotesView(
              book: (ModalRoute.of(context)?.settings.arguments as BookChapterForStudy).book,
              chapter: (ModalRoute.of(context)?.settings.arguments as BookChapterForStudy).chapter,
              studyMode: true),
          RouteConstant.read: (context) => BookReadView(book: ModalRoute.of(context)?.settings.arguments as Book),
          RouteConstant.bookNotes: (context) => ChapterListView(books: ModalRoute.of(context)?.settings.arguments as List<Book>),
          RouteConstant.bookNotesChapter: (context) => BookNotesView(
              book: (ModalRoute.of(context)?.settings.arguments as BookChapterForStudy).book,
              chapter: (ModalRoute.of(context)?.settings.arguments as BookChapterForStudy).chapter),
          RouteConstant.bookChapters: (context) => BookSetupView(bookToSetup: ModalRoute.of(context)?.settings.arguments as BookToSetUp),
          RouteConstant.booksMerge: (context) => BookMergeView(books: ModalRoute.of(context)?.settings.arguments as List<Book>),
          RouteConstant.settings: (context) => const SettingsView(),
          RouteConstant.deletedBooksRoute: (context) => const DeletedBooksView(),
          // endregion
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  }..addAll(super.dragDevices);
}
