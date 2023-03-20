import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notebars/getx/controller/deleted_books_controller.dart';
import 'package:notebars/global.dart';

class DeletedBooksView extends GetView<DeletedBooksController> {
  const DeletedBooksView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
        title: const Text('Deleted Books'),
        centerTitle: true,
      ),
      body: ObxValue(
          (Rx<bool> loaded) => !loaded.value
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  itemCount: controller.deletedBooks.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.all(8),
                    child: GestureDetector(
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Confirmation'),
                              content: const Text(
                                  'Are you sure that you want to permanent delete this book?'),
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
                                    Navigator.pop(context);
                                    controller.loaded.value = false;
                                    await controller.deleteBookPermanent(
                                        controller.deletedBooks[index]);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.delete_forever_outlined,
                            color: Colors.deepPurple,
                          ),
                          title: Text(
                            controller.deletedBooks[index].name,
                          ),
                          subtitle: Text(
                            app.libraries
                                    .firstWhereOrNull((element) =>
                                        element.uuid ==
                                        controller
                                            .deletedBooks[index].libraryUuid)
                                    ?.name ??
                                '',
                            style: TextStyle(
                              color: Colors.blueGrey.withOpacity(0.7),
                            ),
                          ),
                          trailing: TextButton(
                            onPressed: () {
                              controller
                                  .restoreBook(controller.deletedBooks[index]);
                            },
                            child: const Text('RESTORE'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
          controller.loaded),
    );
  }
}
