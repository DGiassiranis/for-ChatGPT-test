/// -----------------------------------------------------------------------
///  [2021] - [2022] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'book.dart';
import 'book_chapter.dart';

class BookChapterForStudy {
  const BookChapterForStudy({required this.book, required this.chapter});

  final Book book;
  final BookChapter chapter;
}

extension BookChapterForStudyExtensions on List<BookChapterForStudy> {

  List<BookChapterForStudy> sortByTimeToStudy({bool ascending = true}) {
    ///if the compareTo method return < 0; the first object should be first,
    ///if the compareTo method return > 0; then the second object should be first
    ///if the compareTo method return 0; then the two compared objects are equal
    sort((firstObject, secondObject) {
      /// First, sort by study eligibility (late, on-time, early, none)
      var order = firstObject.chapter.studyEligibilityState.compareTo(secondObject.chapter.studyEligibilityState);
      if (order != 0) {
        return order;
      }

      if (firstObject.chapter.studyState == StudyState.none) {
        /// For chapters not studied yet, sort by book name and chapter's position (when chapters belong to the same book)
        order = firstObject.book.name.compareTo(secondObject.book.name);
        if (order != 0) {
          return order;
        }
      } else {
        /// Second, sort by time to study
        order = firstObject.chapter.timeToStudy.compareTo(secondObject.chapter.timeToStudy);
        if (order != 0) {
          return order;
        }
      }
      /// in case that nothing found
      /// just keep the same order as the database
      order = -1;
      return order < 0 ? -1 : (order > 0 ? 1 : 0);
    });


    return this;
  }

  List<BookChapterForStudy> sortByPositionsInDataBase() {
    ///Here you just need to return the list as it came to the device
    return this;
  }

}
