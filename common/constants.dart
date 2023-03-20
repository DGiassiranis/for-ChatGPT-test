abstract class Constants{

  static String youtubePlaylistIOS = 'youtube://youtube.com/playlist?list=PLsxUW8K1_wwPlyAZ50pwQLRrF4MV9skTS';
  static String youtubePlaylistAndroid = 'https://youtube.com/playlist?list=PLsxUW8K1_wwPlyAZ50pwQLRrF4MV9skTS';
  static String notebarsTutorial = 'https://www.notebars.gr/instructions';


  static Uri get youtubePlaylistIOSUri => Uri.parse(youtubePlaylistIOS);
  static Uri get youtubePlaylistAndroidUri => Uri.parse(youtubePlaylistAndroid);
  static Uri get notebarsTutorialUri => Uri.parse(notebarsTutorial);

  static String instructionsBookVersion = 'v1.0.4';
  static String preExistedBookVersion = 'v1.0.1';
  static String preExistedBookVersion2 = 'v1.0.2';
  static String preExistedBookVersion3 = 'v1.0.3';
  static String instructionsBookPath = 'assets/json/instructions_book.json';
  static String instructionsBookId = 'notebars_instruction_book_$instructionsBookVersion';
  static String instructionBookLibraryUuid = 'notebars_instruction_book_$instructionsBookVersion';
  static String preExistedInstructionBookLibraryUuid = 'notebars_instruction_book_$preExistedBookVersion';
  static String preExistedInstructionBookLibraryUuid2 = 'notebars_instruction_book_$preExistedBookVersion2';
  static String preExistedInstructionBookLibraryUuid3 = 'notebars_instruction_book_$preExistedBookVersion3';

  static List<String> nonShownLibrariesUuid = [
    instructionBookLibraryUuid,
    ...preExistedLibrariesIds,
  ];
  static List<String> preExistedLibrariesIds = [
    preExistedInstructionBookLibraryUuid,
    preExistedInstructionBookLibraryUuid2,
    preExistedInstructionBookLibraryUuid3,
  ];
}