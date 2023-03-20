/// -----------------------------------------------------------------------
///  [2021] - [2022] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:notebars/common/color_constant.dart';

import '../../classes/book_chapter.dart';
import '../../classes/book_chapter_for_study.dart';
import '../../extensions.dart';
import '../../global.dart';

class BookChapterStudyListItem extends StatelessWidget {
  const BookChapterStudyListItem({Key? key, required this.chapterForStudy, this.onResetTimer, this.onRestartTimer, this.onStudy, this.onSkipReps, required this.lastVisited, required this.index})
      : super(key: key);

  final BookChapterForStudy chapterForStudy;
  final Function(BookChapterForStudy)? onResetTimer;
  final Function(BookChapterForStudy)? onRestartTimer;
  final Function(BookChapterForStudy, int index)? onStudy;
  final int index;
  final Function(BookChapterForStudy)? onSkipReps;
  final bool lastVisited;

  String durationToTimeLapsed(Duration duration) {
    var abs = duration.abs();
    if (abs.inDays > 0) {
      return '${abs.inDays} days';
    } else if (abs.inHours > 0) {
      return '${abs.inHours} hours';
    } else if (abs.inMinutes > 0) {
      return '${abs.inMinutes} mins';
    } else {
      return 'few secs';
    }
  }

  String durationToTimeParts(Duration duration) {
    var parts = <String>[];

    if (duration.elapsedYears > 0) {
      parts.add('${duration.elapsedYears} y');
    }
    if (duration.elapsedMonths > 0) {
      parts.add('${duration.elapsedMonths}m');
    }
    if (duration.elapsedDays > 0) {
      parts.add('${duration.elapsedDays}d');
    }

    parts.add('${duration.elapsedHours.toString().padLeft(2, '0')}:${duration.elapsedMinutes.toString().padLeft(2, '0')}');

    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          child: Slidable(
            startActionPane: chapterForStudy.chapter.studyState.no > 0
                ? ActionPane(
                    motion: const ScrollMotion(),
                    extentRatio: 0.2,
                    children: <Widget>[
                      SlidableAction(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        icon: Bootstrap.stop_circle,
                        onPressed: onResetTimer != null ? (_) => onResetTimer!(chapterForStudy) : null,
                      ),
                    ],
                  )
                : null,
            endActionPane: (chapterForStudy.chapter.studyState.no == 0 || chapterForStudy.chapter.studyEligibilityState == StudyEligibilityState.early)
                ? ActionPane(
                    motion: const ScrollMotion(),
                    extentRatio: 0.3,
                    children: <Widget>[
                      if (chapterForStudy.chapter.studyState.no == 0)
                        Expanded(child: InkWell(
                          onTap: onSkipReps != null ? () => onSkipReps!(chapterForStudy) : null,
                          child: Container(
                            height: double.infinity,
                            color: Colors.deepOrangeAccent, child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                              Icons.timer_outlined,
                              size: 30,
                              color: Colors.white,
                            ),
                              Text(
                                ' x ${app.settings["quickChangeState"] ?? 3}',
                                style: const TextStyle(color: Colors.white),
                              )
                            ],
                          ),),
                        ),),
                      if (chapterForStudy.chapter.studyState.no > 0)
                        SlidableAction(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.deepPurpleAccent,
                          icon: Bootstrap.arrow_counterclockwise,
                          onPressed: onRestartTimer != null ? (_) => onRestartTimer!(chapterForStudy) : null,
                        ),
                    ],
                  )
                : ActionPane(
              motion: const ScrollMotion(),
              extentRatio: 0.2,
              children: <Widget>[
                if (chapterForStudy.chapter.studyState.no > 0)
                  SlidableAction(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepPurpleAccent,
                    icon: Bootstrap.arrow_counterclockwise,
                    onPressed: onRestartTimer != null ? (_) => onRestartTimer!(chapterForStudy) : null,
                  ),
              ],
            ),
            child: ListTile(
              dense: true,
              isThreeLine: chapterForStudy.chapter.studyState.no > 0,
              contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
              leading: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: chapterForStudy.chapter.studyState.no > 0 && chapterForStudy.chapter.studyState.no < 9
                    ? Badge(
                        badgeColor: chapterForStudy.chapter.studyEligibilityState.color,
                        badgeContent: Text(chapterForStudy.chapter.studyState.no.toString(), style: const TextStyle(color: Colors.white)),
                        elevation: 0,
                        child: Icon(Bootstrap.stopwatch, size: 36, color: chapterForStudy.chapter.studyEligibilityState.color),
                      ) :
                    chapterForStudy.chapter.studyState.no == 0 ?  Icon(Bootstrap.play_circle, size: 36, color: chapterForStudy.chapter.studyEligibilityState.color) :
                    Icon(CupertinoIcons.check_mark, size: 36, color: ColorConstants.blueColor)
                ,
              ),
              minLeadingWidth: 0, // Reduce leading icon's width as much as possible
              title: Text(
                '${chapterForStudy.book.name} ${chapterForStudy.chapter.orderOfChapter(chapterForStudy.book)}',
                style: const TextStyle(fontFamily: 'Roboto', fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(chapterForStudy.chapter.name, style: const TextStyle(fontSize: 13, color: Colors.black)),
                  const SizedBox(height: 5),
                  if (chapterForStudy.chapter.studyState.no > 0 && chapterForStudy.chapter.studyState.no < 9 )
                    Row(
                      children: [
                        const Icon(Bootstrap.check_circle, size: 16),
                        const SizedBox(width: 5),
                        Text('${durationToTimeLapsed(chapterForStudy.chapter.timeSinceLastStudy)} ago', style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 25),
                        Icon(chapterForStudy.chapter.studyEligibilityState == StudyEligibilityState.onTime ? Bootstrap.play_fill : Icons.timer_outlined,
                            size: 16, color: chapterForStudy.chapter.studyEligibilityState.color),
                        const SizedBox(width: 5),
                        Text(
                            '${(chapterForStudy.chapter.studyEligibilityState == StudyEligibilityState.late ? 'late by' : (chapterForStudy.chapter.studyEligibilityState == StudyEligibilityState.onTime ? 'within' : 'in'))} ${durationToTimeLapsed(chapterForStudy.chapter.timeToStudy)}',
                            style: TextStyle(fontSize: 12, color: chapterForStudy.chapter.studyEligibilityState.color)),
                      ],
                    ),
                  if (chapterForStudy.chapter.studyState.no == 9) Text('The study is complete.', style: TextStyle(color: ColorConstants.blueColor),)
                ],
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 60),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        app.getLibraryByBook(chapterForStudy.book).name,
                        softWrap: true,
                        style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w300),
                      ),
                      Wrap(
                          alignment: WrapAlignment.center,
                          children: chapterForStudy.chapter.repetitions.repeat((_) => Icon(
                                Icons.star,
                                color: chapterForStudy.chapter.studyEligibilityState.color,
                                size: 16,
                              ))),
                    ],
                  ),
                ),
              ),
              onTap: onStudy != null ? () {
                onStudy!(chapterForStudy, index);
              } : null,
            ),
          ),
        ),
        if(lastVisited) const Positioned(
          top: 0,
          right: 10,
          child: Icon(Icons.bookmark, color: Colors.deepPurpleAccent,),),
      ],
    );
  }
}
