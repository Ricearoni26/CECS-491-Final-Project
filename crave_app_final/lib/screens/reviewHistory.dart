import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class viewHistory extends StatefulWidget {
  const viewHistory({Key? key}) : super(key: key);

  @override
  State<viewHistory> createState() => _viewHistoryState();
}

class _viewHistoryState extends State<viewHistory> {


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

        String comment = '';
        if(value['comments'] == Null){
        comment = 'No comment made.';
        }
        else
        {

        comment = value['comments'].toString();

        }
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
