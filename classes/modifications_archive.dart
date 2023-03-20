import 'package:aneya_json/json.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notebars/classes/book_library.dart';
import 'package:notebars/extensions.dart';

const uuidKey = 'uuid';
const titleKey = 'title';
const colorKey = 'color';
const librariesKey = 'libraries';
const modifiedBooksKey = 'modifiedBooks';
const lastModifiedKey = 'lastModified';
const statusKey = 'status';
const googleDriveIdKey = 'driveId';
const modifiedFilesKey = 'modifiedFilesKey';

class ModificationsArchive {
  static const String defaultDateFormat = 'dd-MM-yyyy HH:mm:ss';
  static const String archiveBox = 'archive';
  static DateFormat dateFormat = DateFormat(defaultDateFormat);

  ModificationsArchive({
    this.googleDriveId = '',
    required this.uuid,
    required this.libraries,
  });

  String googleDriveId;
  final String uuid;
  List<BookLibraryV2> libraries;

  Json toJson() => {
        googleDriveIdKey: googleDriveId,
        uuidKey: uuid,
        librariesKey: libraries.map((e) => e.toJson()).toList(),
      };

  factory ModificationsArchive.fromJson(Json json) => ModificationsArchive(
      googleDriveId: json[googleDriveIdKey],
      uuid: json[uuidKey],
      libraries: (json[librariesKey] as List<dynamic>)
          .map((e) => BookLibraryV2.fromJson(Json.from(e)))
          .toList());

  ///[requiredActionEnum] will be [RequiredActionEnum.download] if we compare remoteArchive.compareArchives(localArchive)
  ///and respectively
  ///[RequiredActionEnum.upload] if we compare localArchive.compareArchives(remoteArchive)
  ///for reasons that I am too tired to explain right now
  ///
  ///If we compare any others archives, we should think about what action we need to add;
  ///so the [requiredActionEnum] is just the default action, if the [otherArchive.libraries] have [ModifiedFile] that is after than the current library
  ///we are gonna use the reversed action, Namely:
  ///[requiredActionEnum] == [RequiredActionEnum.download] ? [RequiredActionEnum.upload] : [RequiredActionEnum.download]
  void compareArchives(ModificationsArchive otherArchive,
      RequiredActionEnum requiredActionEnum) {
    for (BookLibraryV2 thisLibrary in libraries) {
      ///fetch the library of the object if exists;
      BookLibraryV2? library = otherArchive.libraries
          .firstWhereOrNull((element) => element.uuid == thisLibrary.uuid);

      ///First we compare the libraries,

      ///if it does not exist -> [library == null]
      ///the we have to put it inside the libraries
      if (library == null) {
        for (int index = 0; index < thisLibrary.modifiedBooks.length; index++) {
          thisLibrary.modifiedBooks[index].requiredAction = requiredActionEnum;
        }
        otherArchive.libraries.add(thisLibrary);
        continue;
      }

      ///Second we need to cross the lists of modifiedBooks;
      for (int index = 0; index < thisLibrary.modifiedBooks.length; index++) {
        ModifiedFile? book = library.modifiedBooks.firstWhereOrNull(
            (element) => element.uuid == thisLibrary.modifiedBooks[index].uuid);
        if (book == null) {
          thisLibrary.modifiedBooks[index].requiredAction = requiredActionEnum;
          continue;
        }
        if (thisLibrary.modifiedBooks[index].lastModified
                    .difference(book.lastModified)
                    .inMinutes >
                1 ||
            thisLibrary.modifiedBooks[index].lastModified
                    .difference(book.lastModified)
                    .inMinutes <
                -1) {
          library.modifiedBooks[library.modifiedBooks.indexOf(book)]
              .requiredAction = thisLibrary.modifiedBooks[index].lastModified
                  .isAfter(book.lastModified)
              ? requiredActionEnum
              : requiredActionEnum.reversed;
        }
      }
    }
  }
}

class BookLibraryV2 {
  BookLibraryV2({
    required this.uuid,
    required this.title,
    required this.color,
    required this.modifiedBooks,
  });

  String uuid;
  String title;
  Color color;
  List<ModifiedFile> modifiedBooks;

  Json toJson() => {
        uuidKey: uuid,
        titleKey: title,
        colorKey: color.toHex(),
        modifiedBooksKey: modifiedBooks.map((e) => e.toJson()).toList(),
      };

  factory BookLibraryV2.fromJson(Json json) => BookLibraryV2(
      uuid: json[uuidKey],
      title: json[titleKey],
      color: (json[colorKey] != null
          ? (json[colorKey] as String).toColor()
          : Colors.deepPurple),
      modifiedBooks: (json[modifiedBooksKey] as List<dynamic>)
          .map((e) => ModifiedFile.fromJson(Json.from(e)))
          .toList());

  ///[calculateFinalArchive]
  ///Here, we need to cross the tables of two [ModificationsArchive] objects
  ///Firstly, we need to put inside the [modifiedFiles] any object that does not exist in the other archive
  ///Then, we need to see which modification date is later;
  void calculateFinalArchive(BookLibraryV2 otherLibrary) {
    for (ModifiedFile otherModifiedBook in otherLibrary.modifiedBooks) {
      ///crosses the tables here
      if (modifiedBooks.firstWhereOrNull(
              (file) => file.uuid == otherModifiedBook.uuid) !=
          null) continue;
      modifiedBooks.add(otherModifiedBook);
    }

    ///Here we check which modification date is later
    ///Because we are going to modify the list inside the for loop
    ///We need an indexed for
    for (int index = 0; index < modifiedBooks.length; index++) {
      ModifiedFile modifiedFile = modifiedBooks[index];
      if (otherLibrary.modifiedBooks
              .firstWhereOrNull((file) => file.uuid == modifiedFile.uuid) ==
          null) continue;
      ModifiedFile otherFile = otherLibrary.modifiedBooks
          .firstWhere((file) => file.uuid == modifiedFile.uuid);

      ///checks if the book file has modified
      if (modifiedFile.lastModified.isBefore(otherFile.lastModified)) {
        modifiedBooks.remove(modifiedFile);
        modifiedBooks.add(otherFile);
      }
    }
  }

  factory BookLibraryV2.fromBookLibrary(
          BookLibrary bookLibrary, List<ModifiedFile> booksModified) =>
      BookLibraryV2(
          uuid: bookLibrary.uuid,
          title: bookLibrary.name,
          color: bookLibrary.color,
          modifiedBooks: booksModified);
}

extension ListBookLibraryV2Ext on List<BookLibraryV2> {
  bool containsLibrary(String uuid) =>
      firstWhereOrNull((element) => element.uuid == uuid) != null;
}

class ModifiedFile {
  ModifiedFile(
      {required this.uuid,
      required this.lastModified,
      this.requiredAction,
      this.status = BookDeletionStatus.active});

  final String uuid;
  DateTime lastModified;
  BookDeletionStatus status;

  RequiredActionEnum? requiredAction = RequiredActionEnum.synchronized;

  Json toJson() => {
        uuidKey: uuid,
        lastModifiedKey: ModificationsArchive.dateFormat.format(lastModified),
        statusKey: status.code,
      };

  factory ModifiedFile.fromJson(Json json) {
    return ModifiedFile(
      uuid: json[uuidKey],
      lastModified:
          ModificationsArchive.dateFormat.parse(json[lastModifiedKey]),
      status: BookDeletionStatus.fromCode(json[statusKey]),
    );
  }
}

enum BookDeletionStatus {
  active('active'),
  tempDeleted('temp_deleted'),
  permDeleted('perm_deleted');

  const BookDeletionStatus(this.code);

  final String code;

  static BookDeletionStatus fromCode(String? code) {
    if (code == 'temp_deleted') {
      return tempDeleted;
    } else if (code == 'perm_deleted') {
      return permDeleted;
    }
    return active;
  }
}

extension ListModifiedFileExt on List<ModifiedFile> {
  bool containsBook(String uuid) =>
      firstWhereOrNull((element) => element.uuid == uuid) != null;

  List<ModifiedFile> sortByTime() {

    sort((current, next){
      return next.lastModified.compareTo(current.lastModified);
    });

    return this;
  }

}

class RequiredAction {
  const RequiredAction({required this.uuid, required this.actionRequired});

  final String uuid;
  final RequiredActionEnum actionRequired;
}

enum RequiredActionEnum {
  upload,
  download,
  synchronized,
}

extension RequiredActionEnumExt on RequiredActionEnum {
  RequiredActionEnum get reversed {
    switch (this) {
      case RequiredActionEnum.upload:
        return RequiredActionEnum.download;
      case RequiredActionEnum.download:
        return RequiredActionEnum.upload;
      case RequiredActionEnum.synchronized:
        return RequiredActionEnum.synchronized;
    }
  }
}
