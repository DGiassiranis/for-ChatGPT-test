/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:aneya_core/core.dart';
import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:icons_plus/icons_plus.dart';
import 'package:notebars/classes/book_to_setup.dart';
import 'package:notebars/common/constants.dart';
import 'package:notebars/common/route_constant.dart';
import 'package:notebars/common/setting_constant.dart';
import 'package:notebars/extensions.dart' hide ListUtils;
import 'package:notebars/getx/controller/sync_controller.dart';
import 'package:notebars/helpers/instructions_util.dart';
import 'package:uuid/uuid.dart';

import '../classes/book.dart';
import '../classes/book_library.dart';
import '../dialogs/book_new_from_source_sheet.dart';
import '../dialogs/library_edit_sheet.dart';
import '../global.dart';
import '../widgets/library/library_card.dart';

class LibrariesView extends StatefulWidget {
  const LibrariesView({Key? key}) : super(key: key);

  @override
  LibrariesViewState createState() => LibrariesViewState();
}

class LibrariesViewState extends State<LibrariesView>
    with WidgetsBindingObserver {
  // region Properties
  List<Book> selectedBooks = [];

  // endregion

  // region Getters
  /// The library that contains the selected book(s), if any
  BookLibrary? get selectedLibrary => selectedBooks.isNotEmpty
      ? app.libraries
          .firstWhereOrNull((l) => l.uuid == selectedBooks.first.libraryUuid)
      : null;

  // endregion

  // region Action methods
  // region Library methods
  /// Triggered when user hits library editing bottom sheet "save" button
  Future<void> saveLibrary(BookLibrary library) async {
    await app.saveLibrary(library);

    // Trigger reactivity
    setState(() => {});
  }

  void deleteLibrary(BookLibrary library) {
    if (library.books.isNotEmpty) {}
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Delete library?'),
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
                // Ensure library isn't selected
                if (selectedLibrary == library) {
                  setState(() => selectedBooks.clear());
                }

                app.deleteLibrary(library);

                if (mounted) Navigator.of(context).pop();

                // Force redraw
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  /// Opens library editor bottom sheet
  void openLibraryEditor(BookLibrary library) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext bc) {
        return LibraryEditSheet(
          library: library,
          onCancel: _onDismissSheet,
          onSave: (library) async {
            await saveLibrary(library);

            if (mounted) Navigator.of(context).pop();
          },
        );
      },
    );
  }

  /// Toggles study mode to the given library and saves changes to the device
  Future<void> toggleLibraryStudyMode(BookLibrary library, bool enable) async {
    library.enableStudying = enable;

    // Save changes
    await saveLibrary(library);
  }

  // endregion

  // region Book methods
  void readSelectedBook() {
    if (selectedBooks.length != 1) return;

    if (selectedBooks.isNotEmpty) {
      Navigator.pushNamed(context, '/read', arguments: selectedBooks[0]);
    }
  }

  void editNotesSelectedBook() {
    if (selectedBooks.length != 1) return;

    if (selectedBooks.isNotEmpty) {
      Navigator.pushNamed(context, '/book/notes',
              arguments: app.books
                      .where((element) => element.uuid == selectedBooks[0].uuid)
                      .toList()
                      .isNotEmpty
                  ? app.books
                      .where((element) => element.uuid == selectedBooks[0].uuid)
                      .toList()
                      .first
                  : selectedBooks[0])
          .then((_) => setState(() {}));
    }
  }

  void editSelectedBook() async {
    if (selectedBooks.length != 1) return;

    await app.fetchBooks();
    if (!mounted) {
      return;
    }
    navigateToEditSelectedBookView();
  }

  void navigateToEditSelectedBookView({Book? book}) {
    Navigator.pushNamed(context, RouteConstant.bookChapters,
            arguments: BookToSetUp(
                book: book ??
                    (app.books
                            .where((element) =>
                                element.uuid == selectedBooks[0].uuid)
                            .toList()
                            .isNotEmpty
                        ? app.books
                            .where((element) =>
                                element.uuid == selectedBooks[0].uuid)
                            .toList()
                            .first
                        : selectedBooks[0])))
        .then((_) async {
      await app.fetchBooks();
      setState(() {});
    });
  }

  void mergeSelectedBooks() {
    if (selectedBooks.length < 2) return;

    Navigator.pushNamed(context, '/book/merge', arguments: selectedBooks)
        .then((_) => setState(() {
              selectedBooks = selectedBooks
                  .where((book) => app.books.contains(book))
                  .toList();
            }));
  }

  void deleteSelectedBooks() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Delete selected book(s)?'),
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
                Get.back();
                Get.defaultDialog(
                    title: 'Deleting...',
                    content: const CircularProgressIndicator());
                for (var book in selectedBooks) {
                  await Future.delayed(const Duration(milliseconds: 500));
                  app.deleteBookTemporarily(book);
                }

                selectedBooks.clear();
                Get.back();
                // Force redraw
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  // endregion

  // region Import methods
  /// Opens book import bottom sheet
  void openBookImportSheet(BookLibrary library) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext bc) {
        return BookNewFromSourceSheet(
          library: library,
          onCancel: _onDismissSheet,
          onImportFromClipboard: () => importBookFromClipboard(library),
          onImportFromFile: () => importBookFromFile(library),
          onImportFromUrl: () => importBookFromUrl(library),
        );
      },
    );
  }

  /// Opens book import page with file as source
  void importBookFromFile(BookLibrary library) {
    // TODO: Implement book import from file
  }

  /// Opens book import page with Url as source
  void importBookFromUrl(BookLibrary library) async {
    Navigator.of(context).pop();

    final ClipboardData? text = await Clipboard.getData(Clipboard.kTextPlain);

    if (!mounted) return;

    if (text == null || text.text == null || text.text!.isEmpty) {
      app.showStatusSnackBar(
          context,
          const Status(false,
              message: 'No text contents found in the clipboard...'));
      return;
    }

    final String? url = text.text;

    try {
      if (url == null || url.trim().isEmpty || !Uri.parse(url).isAbsolute) {
        app.showStatusSnackBar(
            context,
            const Status(false,
                message:
                    'It seems that the url you copied is invalid. Please, copy a file url.(ex: https://mybook.com/chapter1'));
        return;
      }
    } catch (e) {
      app.showStatusSnackBar(
          context,
          const Status(false,
              message:
                  'It seems that the url you copied is invalid. Please, copy a file url.(ex: https://mybook.com/chapter1'));
      return;
    }

    try {
      // region Fetch html from URL address
      var response =
          await http.get(Uri.parse(url), headers: {'accept-charset': 'UTF-8'});
      // endregion
      // region Extract plain text from HTML
      final document = parse(utf8.decode(response.bodyBytes));

      final String text =
          parse(document.body?.text ?? '').documentElement!.text;
      // endregion

      var status = await _importBookFromText(library, text);
      if (!mounted) return; // Ensure context is valid across async gaps

      if (status.isOK) {
        navigateToEditSelectedBookView();
      } else {
        app.showStatusSnackBar(context, status);
      }
    } catch (e) {
      app.showStatusSnackBar(
          context,
          Status(false,
              message:
                  'Error fetching and parsing the URL contents. Details: ${e.toString()}'));
    } finally {}
  }



  /// Opens book import page with clipboard as source
  void importBookFromClipboard(BookLibrary library) async {
    Navigator.of(context).pop();
    ClipboardData? text = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return; // Ensure context is valid across async gaps

    if (text == null || text.text == null || text.text!.isEmpty) {
      app.showStatusSnackBar(
          context,
          const Status(false,
              message: 'No text contents found in the clipboard...'));
      return;
    }

    var status = await _importBookFromText(library, text.text ?? '');
    if (!mounted) return; // Ensure context is valid across async gaps

    if (status.isOK) {
      navigateToEditSelectedBookView();
    } else {
      app.showStatusSnackBar(context, status);
    }
  }

  /// Helper method to create & return a new book given the text
  Future<Status<Book>> _importBookFromText(
      BookLibrary library, String text) async {
    if (text.length < 500) {
      return const Status(false,
          message: 'Contents are too small to represent a book...');
    }

    Book book = Book.fromText(
      name: 'Untitled',
      libraryUuid: library.uuid,
      text: text,
    );
    book.uuid = const Uuid().v4();
    var status = await app.saveBook(book,
        applyJson: false, saveInLocalModifications: true);
    if (status.isError) {
      return Status<Book>(false, code: status.code, message: status.message);
    }

    // Trigger reactivity
    selectedBooks
      ..clear()
      ..add(book);

    setState(() => {});

    return Status(true, data: book);
  }

  // endregion
  // endregion

  // region Event methods
  /// Triggered when user hits the currently opened sheet's "cancel" button
  void _onDismissSheet() {
    Navigator.of(context).pop();
  }

  // endregion

  // region State initialization & build
  void appChangesListenerFn() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();

    selectedBooks = [];
    app.addListener(appChangesListenerFn);
  }

  @override
  void dispose() {
    super.dispose();

    app.removeListener(appChangesListenerFn);
  }

  @override
  Widget build(BuildContext context) {
    final totalChaptersForStudy = app.studyBooks
        .fold<int>(0, (count, b) => count + b.onTimeChaptersForStudying.length);

    return Scaffold(
      backgroundColor: const Color(0xffdbe2e7),
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
        title: const Text('My Libraries'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Bootstrap.sliders),
            tooltip: 'Settings',
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.deepPurpleAccent,
        shape: const CircularNotchedRectangle(),
        child: IconTheme(
          data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          child: Row(
            children: <Widget>[
              IconButton(
                tooltip: 'Setup book chapters & properties',
                icon: const Icon(Bootstrap.gear),
                onPressed: selectedBooks.length == 1 ? editSelectedBook : null,
              ),
              IconButton(
                tooltip: 'Merge selected books',
                icon: const Icon(Icons.merge_type),
                onPressed: selectedBooks.length > 1 ? mergeSelectedBooks : null,
              ),
              const Spacer(),
              Obx(
                () => IconButton(
                  icon: Badge(
                    badgeColor: Colors.lightBlueAccent,
                    showBadge: SyncController.find.modifiedBooks.isNotEmpty,
                    badgeContent: Text(
                        SyncController.find.modifiedBooks.length.toString(),
                        style: const TextStyle(color: Colors.white)),
                    child: const Icon(
                      Icons.sync,
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
              IconButton(
                tooltip: 'Delete selected book(s)',
                icon: const Icon(Icons.delete_forever_outlined),
                onPressed:
                    selectedBooks.isNotEmpty ? deleteSelectedBooks : null,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: selectedLibrary == null ||
              selectedLibrary!.enableStudying
          ? FloatingActionButton(
              onPressed: () async {
                await app.fetchBooks();
                if (app.books.isEmpty) {
                  await app.fetchBooks();
                }
                if (!mounted) {
                  return;
                }

                Navigator.of(context)
                    .pushNamed('/study-list',
                        arguments: app.books
                            .where((element) =>
                                selectedBooks.containsUuid(element.uuid))
                            .toList())
                    .then((value) async {
                  await app.fetchBooks();
                  if (app.books.isEmpty) {
                    await app.fetchBooks();
                    log('TRIED, NEW LENGTH: ${app.books.length}');
                  }
                  setState(() {});
                });
              },
              backgroundColor: Colors.deepPurpleAccent,
              child: Badge(
                  showBadge: totalChaptersForStudy > 0,
                  badgeContent: Text(totalChaptersForStudy.toString(),
                      style: const TextStyle(color: Colors.white)),
                  child: const Icon(Bootstrap.bell, color: Colors.white)),
            )
          : FloatingActionButton(
              onPressed: (selectedBooks.isNotEmpty
                  ? () async {
                      await app.fetchBooks();

                      if (!mounted) {
                        return;
                      }
                      Navigator.of(context)
                          .pushNamed('/book/notes',
                              arguments: app.books
                                  .where((element) =>
                                      selectedBooks.containsUuid(element.uuid))
                                  .toList())
                          .then((_) async {
                        await app.fetchBooks();
                        if (app.books.isEmpty) {
                          await app.fetchBooks();
                        }
                        setState(() {});
                      });
                    }
                  : null),
              backgroundColor: selectedBooks.isNotEmpty
                  ? Colors.deepPurpleAccent
                  : Colors.deepPurpleAccent.withOpacity(.75),
              child: Icon(Bootstrap.list_ol,
                  color: selectedBooks.isNotEmpty
                      ? Colors.white
                      : Colors.black38)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: ListView(
        children: <Widget>[
          ...app.libraries.map(
            (lib) => Constants.nonShownLibrariesUuid.contains(lib.uuid)
                ? const SizedBox()
                : LibraryCard(
                    library: lib,
                    selectedBooks: selectedBooks,
                    onEditPressed: () => openLibraryEditor(lib),
                    onDeletePressed: () => deleteLibrary(lib),
                    onAddBookPressed: () => openBookImportSheet(lib),
                    onBookPressed: (Book book) async {
                      if (selectedBooks.containsUuid(book.uuid)) {
                        selectedBooks.remove(selectedBooks.firstWhereOrNull(
                            (element) => element.uuid == book.uuid));
                      } else {
                        if (selectedBooks.isNotEmpty &&
                            book.libraryUuid !=
                                selectedBooks.first.libraryUuid) {
                          // If book doesn't belong to the same library, deselect all previous books before selecting the given book
                          selectedBooks.clear();
                        }

                        selectedBooks.add(book);
                      }

                      setState(() => {});
                    },
                    onBookLongPressed: lib.enableStudying ? (Book book) =>
                        openStudyListFromBook(book) : (Book book) =>
                        openChaptersListFromBook(book),
                    onToggleLibrary: (value) =>
                        toggleLibraryStudyMode(lib, value),
                  ),
          ),
          if (app.libraries.isNotEmpty)
            Card(
              color: Colors.transparent,
              elevation: 0,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  buttonsRow(),
                  const SizedBox(
                    height: 15,
                  ),
                  Image.asset('assets/logo_with_text_new.png', height: 100),
                ],
              ),
            ),
          if (app.libraries.isEmpty) ...[
            if (!app.fetchedLibraries)
              Card(
                color: Colors.transparent,
                elevation: 0,
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    const CircularProgressIndicator(strokeWidth: 2),
                    const SizedBox(height: 20),
                    const Text('Loading libraries...'),
                    const SizedBox(height: 40),
                    SvgPicture.asset(
                      'assets/illustrations/undraw_Synchronize_re_4irq.svg',
                      width: 250,
                    ),
                  ],
                ),
              ),
            if (app.fetchedLibraries)
              Card(
                color: Colors.transparent,
                elevation: 0,
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    const SizedBox(
                      height: 15,
                    ),
                    buttonsRow(),
                    const SizedBox(
                      height: 15,
                    ),
                    Image.asset('assets/logo_with_text_new.png', height: 100),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget buttonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.03,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.2,
          child: Column(
            children: [
              GestureDetector(
                onTap: () => openLibraryEditor(BookLibrary(name: '')),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.deepPurple,
                  ),
                  child: const Icon(
                    Bootstrap.collection_fill,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                '+ New Library',
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.03,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.03,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.2,
          child: Column(
            children: [
              GestureDetector(
                onTap: app.launchNotebarsTutorial,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.deepPurple,
                  ),
                  child: const Icon(
                    Icons.language,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                'Instructions website',
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.03,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.2,
          child: Column(
            children: [
              GestureDetector(
                onLongPress: () => InstructionsUtil.resetBook(
                  jsonAssetPath: Constants.instructionsBookPath,
                  bookUuid: Constants.instructionsBookId,
                  libraryUuid: Constants.instructionBookLibraryUuid,
                ),
                onTap: openInstructionsBook,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.deepPurple,
                  ),
                  child: const Icon(
                    Icons.menu_book,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                'Instructions Book',
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.03,
        ),
      ],
    );
  }

  void openInstructionsBook() async {
    Book book = await InstructionsUtil.getOrCreateLibraryAndBook(
      jsonAssetPath: Constants.instructionsBookPath,
      bookUuid: Constants.instructionsBookId,
      libraryUuid: Constants.instructionBookLibraryUuid,
    );
    await app.fetchBooks();

    if (!mounted) {
      return;
    }

    openChaptersListFromBook(book);
  }

  void openStudyListFromBook(Book book) {
    Navigator.of(context)
        .pushNamed('/study-list', arguments: [book]).then((_) async {
      await app.fetchBooks();
      if (app.books.isEmpty) {
        await app.fetchBooks();
      }
      setState(() {});
    });
  }


  void openChaptersListFromBook(Book book) {
    Navigator.of(context)
        .pushNamed('/book/notes', arguments: [book]).then((_) async {
      await app.fetchBooks();
      if (app.books.isEmpty) {
        await app.fetchBooks();
      }
      setState(() {});
    });
  }
// endregion
}
