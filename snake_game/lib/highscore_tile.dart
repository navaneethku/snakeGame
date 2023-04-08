import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HighScoreTile extends StatelessWidget {
  final String documentId;
  HighScoreTile({Key? key, required this.documentId}) : super(key: key);
  CollectionReference highscores =
      FirebaseFirestore.instance.collection("highscores");
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: highscores.doc(documentId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

          return Row(children: [
            Text(data['score'].toString()),
            SizedBox(
              width: 40,
            ),
            Text(data['name']),
          ]);
        } else {
          return Text("loading...");
        }
      },
    );
  }
}
