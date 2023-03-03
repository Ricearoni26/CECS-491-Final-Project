import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {

  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String comment = getComment() as String;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Payments Screen'),

          backgroundColor: Colors.orange,
        ),
        body: Card(
          child: ListTile(
            title: Text(comment),
          ),
        )
    );
  }


  Future<String> getComment() async{
    final user = FirebaseAuth.instance.currentUser!;
    String UID = user.uid!;
    DatabaseReference ref = FirebaseDatabase.instance.ref('users').child(UID).child('rating');
    // await ref.set({'comment': comment, 'rating' : rating});

    final snapshot = await ref.child('rating').get();
    if (snapshot.exists) {
      print(snapshot.value);
    } else {
      print('No data available.');
    }
    Object? comment = snapshot.value;
    return comment.toString();
  }
}
