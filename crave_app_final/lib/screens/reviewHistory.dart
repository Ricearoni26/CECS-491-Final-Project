import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class reviewHistory extends StatefulWidget {
  const reviewHistory({Key? key}) : super(key: key);

  @override
  State<reviewHistory> createState() => _reviewHistoryState();
}

class _reviewHistoryState extends State<reviewHistory> {


  Map<dynamic, dynamic> getReviewMap = {};

  Future<void> fetchReviews() async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref('users/$uid/reviews');

    DatabaseEvent event = await databaseRef.once();
    setState(() {
      getReviewMap = event.snapshot.value as Map<dynamic, dynamic>;
    });

    //data = event.snapshot.value as Map<dynamic, dynamic>;
    //arrayData = event.snapshot.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text('Reviews'),
    ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: getReviewMap.length,
        itemBuilder: (context, subIndex) {
        String key = getReviewMap.keys.elementAt(subIndex);
        Map<dynamic, dynamic> value = getReviewMap.values.elementAt(subIndex);

        String comment = value['comments'].toString();
        String name = value['restaurantName'].toString();
        String rating = value['rating'].toString();

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(name +'\nComment: ' + comment + '\nRated: '+ rating,
            style: TextStyle(
            fontSize: 14.0,
            color: Colors.black,
            fontFamily: 'Roboto',
            ),
          ),
          );
        },
      ),
    );
  }
}
