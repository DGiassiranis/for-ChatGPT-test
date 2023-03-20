
part of 'package:notebars/views/book_notes_view.dart';

enum LastAction {
  addKeyword,
  addNoteWord,
  addKeywordCreateNote,
  addNoteWordCreateNote,
  wordSelected,
  manyWordsSelected,
  deleteNote,
  deleteNoteWordsFromNote,
  deleteKeywordsFromNote,
  deleteImageFromNote,
  noAction,
  multipleDeletionOfNotes,
}

enum DeleteFromNote {
  image,
  note,
  key,
}

enum ShiftingStatus {
  none,
  keyCapital,
  keyLower,
  noteCapital,
  noteLower,
}

//region Lock implementation
enum LockStatus {
  unlocked,
  locked,
}


extension LockStatusMethods on LockStatus {
  LockStatus onTapNextStatus() {
    switch (this) {
      case LockStatus.locked:
        return LockStatus.unlocked;
      default:
        return LockStatus.locked;
    }
  }
}
//endregion

//region Gear Rotation
enum GearRotationMode{
  rotated,
  initialPosition,
  none,
}
//endregion