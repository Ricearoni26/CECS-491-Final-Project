import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class checkInHistory extends StatefulWidget {
  const checkInHistory({Key? key}) : super(key: key);

  @override
  State<checkInHistory> createState() => _checkInHistoryState();
}

class _checkInHistoryState extends State<checkInHistory> {
  Map<dynamic, dynamic> getCheckInMap = {};

  Future<void> fetchCheckIn() async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref('users/$uid/checkIns');

    DatabaseEvent event = await databaseRef.once();
    setState(() {
      getCheckInMap = event.snapshot.value as Map<dynamic, dynamic>;
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
    itemCount: getCheckInMap.length,
    itemBuilder: (context, subIndex) {
    String key = getCheckInMap.keys.elementAt(subIndex);
    List<dynamic> value = getCheckInMap.values.elementAt(subIndex);

    String name = value[0];
    String addy = value[1];


    return Padding(
    padding: EdgeInsets.symmetric(vertical: 8.0),
    child: Text(name + '\n'+ addy,
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
