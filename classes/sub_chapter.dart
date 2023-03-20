//
//
// import 'package:aneya_core/core.dart';
// import 'package:aneya_json/json.dart';
// import 'package:notebars/classes/book_chapter.dart';
// import 'package:notebars/classes/book_paragraph.dart';
// import 'package:notebars/extensions.dart';
// import 'package:uuid/uuid.dart';
//
// class SubChapter{
//
//   /*Properties' Region*/
//   String uuid;
//   String name;
//   StudyState studyState;
//   DateTime lastRead = DateTime(1980);
//   int repetitions;
//
//   late List<BookParagraph> paragraphs;
//   /*End of Properties region*/
//
//   /*Constructor's region*/
//   SubChapter({required this.uuid, required this.name, this.studyState = StudyState.none, this.repetitions = 0, DateTime? lastRead, List<BookParagraph>? paragraphs,}){
//     this.lastRead = lastRead ?? DateTime(1980);
//     this.paragraphs = paragraphs ?? [];
//   }
//   /*End of Constructor region*/
//
//   /*Initializations Region */
//
//   static SubChapter parseTextAsSubChapter(String text){
//
//     List<String> lines = text.asLines();
//     List<String> paragraphs = [];
//
//     lines.removeWhere((element) => element.isEmpty);
//
//     for(String line in lines){
//
//       if(paragraphs.isNotEmpty){
//         if(paragraphs.last.endsWith('.') || line.startsWithUpperCase){
//           paragraphs.add('\n');
//           paragraphs.add(line);
//         }else if(paragraphs.last != '\n'){
//           paragraphs.last = '${paragraphs.last } $line';
//         }else{
//           paragraphs.add(line);
//         }
//       }else{
//         paragraphs.add(line);
//       }
//
//     }
//     paragraphs.removeWhere((element) => element == '\n');
//
//     var words = paragraphs.first.asWords();
//
//     return SubChapter.fromText(uuid: const Uuid().v4(), name: '1. ${words.sublist(0, words.length < 6 ? words.length : 5).join(' ')}', paragraphs: paragraphs);
//   }
//
//
//   Json toJson() => {
//     'uuid': uuid,
//     'name': name,
//     'paragraphs': paragraphs.map((p) => p.toJson()).toList(),
//   };
//
//   factory SubChapter.fromJson(Json json) => SubChapter(uuid: json['uuid'], name: '',).applyJson(json);
//
//   static SubChapter _fromJson(Json json) => SubChapter(uuid: json['uuid'] ?? '', name: json['name'] ?? '', repetitions: json['repetitions'], lastRead: json['lastRead'], paragraphs: json.containsKey('paragraphs') ? json['paragraphs'] is List<BookParagraph> ?  ([...json['paragraphs'] as List<BookParagraph>]) : json['paragraphs'] is List<String> ? [...])
//
//   static SubChapter fromText({
//   required String uuid,
//     required String name,
//     required List<String> paragraphs,
// }) => SubChapter(uuid: 'uuid', name: 'name',);
//
//   applyJson(Json json, [bool strict = false]) {
//     if (strict == true) {
//       uuid = json.getString('uuid', '');
//       name = json.getString('name', '');
//       lastRead = json.getDateTime('lastRead', DateTime(1980));
//       studyState = StudyState.fromString(json.getString('studyState', ''));
//       repetitions = json.getInt('repetitions', 0);
//
//       if (json.containsKey('paragraphs')) {
//         if (json['paragraphs'] is List<BookParagraph>) {
//           paragraphs
//             ..clear()
//             ..addAll((json['paragraphs'] as List<BookParagraph>));
//         } else if (json['paragraphs'] is List<String>) {
//           parseLines(json['paragraphs'] as List<String>);
//         } else if (json['paragraphs'] is List) {
//           paragraphs
//             ..clear()
//             ..addAll((json['paragraphs'] as List).map((json) => BookParagraph.fromJson(Json.from(json))));
//         } else {
//           paragraphs.clear();
//         }
//       } else {
//         paragraphs.clear();
//       }
//     } else {
//       uuid = json.getString('uuid', uuid);
//       name = json.getString('name', name);
//       lastRead = json.getDateTime('lastRead', lastRead);
//       studyState = StudyState.fromString(json.getString('studyState', studyState.code));
//       repetitions = json.getInt('repetitions', repetitions);
//
//       if (json.containsKey('paragraphs')) {
//         if (json['paragraphs'] is List<BookParagraph>) {
//           paragraphs
//             ..clear()
//             ..addAll((json['paragraphs'] as List<BookParagraph>));
//         } else if (json['paragraphs'] is List<String>) {
//           parseLines(json['paragraphs'] as List<String>);
//         } else if (json['paragraphs'] is List) {
//           paragraphs
//             ..clear()
//             ..addAll((json['paragraphs'] as List).map((cfg) => BookParagraph.fromJson(Json.from(cfg))));
//         }
//       }
//     }
//
//     return this;
//   }
//
//
// /*End of Initializations Region*/
//
// }