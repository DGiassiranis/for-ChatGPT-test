import 'package:card_swiper/card_swiper.dart';
import 'package:notebars/classes/book_note.dart';

class BookNoteSyncMove {
  BookNoteSyncMove({
    this.isGroup = false,
    required this.paragraphUuid,
    required this.notes,
    required this.swiperController,
  });

  final bool isGroup;
  final String paragraphUuid;
  final List<BookNote> notes;
  final SwiperController swiperController;
}
