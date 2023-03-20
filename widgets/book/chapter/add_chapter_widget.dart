import 'package:flutter/material.dart';

class AddChapterWidget extends StatelessWidget {
  const AddChapterWidget({Key? key, required this.addChapter}) : super(key: key);

  final Function() addChapter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(bottom: 10),
      child: MaterialButton(
        shape: const CircleBorder(),
        padding: EdgeInsets.zero,
        color: Colors.white54,
        elevation: 0,
        onPressed: addChapter,
        child: const Icon(Icons.add_sharp, color: Colors.black,),
      ),
    );
  }
}
