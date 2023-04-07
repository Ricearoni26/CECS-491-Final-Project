import 'package:flutter/material.dart';

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);


  @override
  State<HistoryScreen> createState() => _FoodHistoryState();
}

class _FoodHistoryState extends State<HistoryScreen> {
  List<Map<dynamic, dynamic>> likedRestaurants = [];

  @override
  void initState() {
    super.initState();
    getLikedRestaurants();
    fetchLiked();
  }

  final DatabaseReference ref = FirebaseDatabase.instance.ref();

  Future<Object?> getLikedRestaurants() async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    //final DatabaseReference refUser = FirebaseDatabase.instance.ref('users/$uid');
    final DatabaseReference refUser = FirebaseDatabase.instance.ref('users/4YJJliz1v9aN0mAmDJ0HllwVj4f2');


    refUser.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        likedRestaurants = data['liked_restaurants'];
        print("Entered here");
        print(likedRestaurants);
      });
    });

  }

  Object? arrayData;

  Future<Object?> fetchLiked() async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref('users/4YJJliz1v9aN0mAmDJ0HllwVj4f2/liked_restaurants');
    DatabaseEvent event = await databaseRef.once();
    arrayData = event.snapshot.value;
    print(arrayData);
    return arrayData;
  }



  var likedRestaurantsTest = ['test','test2', 'test3','test4','test5'];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food History'),
      ),
      body: ListView.builder(

        itemCount: arrayData?.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(likedRestaurants[index].toString()),
          );
        },
      ),


    );
  }
}


