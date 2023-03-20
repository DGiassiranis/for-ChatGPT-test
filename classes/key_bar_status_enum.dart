part of 'package:notebars/classes/book_note.dart';


enum KeyBarStatus {
  key,
  keyTransparent,
  question;

  ///[KeyBarStatus] JsonKey
  static const String jsonKey = 'key_bar_status';

  ///Code values;
  static const String keyCodeValue = 'key';
  static const String keyTransparentCodeValue = 'key_transparent';
  static const String questionCodeValue = 'question';

  static KeyBarStatus getStatusFromCode(String?  code){
  switch(code){
    case KeyBarStatus.keyCodeValue:
      return KeyBarStatus.key;
    case KeyBarStatus.keyTransparentCodeValue:
      return KeyBarStatus.keyTransparent;
    case KeyBarStatus.questionCodeValue:
      return KeyBarStatus.question;
    default:
      return KeyBarStatus.key;
  }
}
}

extension KeyBarStatusExt on KeyBarStatus{

  String get code {
    switch(this){
      case KeyBarStatus.key:
        return KeyBarStatus.keyCodeValue;
      case KeyBarStatus.keyTransparent:
        return 'key_transparent';
      case KeyBarStatus.question:
        return 'question';
    }

  }

  ///KeyBarCircuit
  KeyBarStatus get nextStatus {
    switch(this) {
      case KeyBarStatus.key:
        return KeyBarStatus.keyTransparent;
      case KeyBarStatus.keyTransparent:
        return KeyBarStatus.question;
      case KeyBarStatus.question:
        return KeyBarStatus.key;
    }
  }
}