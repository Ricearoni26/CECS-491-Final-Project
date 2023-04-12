// import 'package:flutter/material.dart';
//
// import 'dart:async';
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
//
// class HistoryScreen extends StatefulWidget {
//   const HistoryScreen({Key? key}) : super(key: key);
//
//   @override
//   State<HistoryScreen> createState() => _FoodHistoryState();
// }
//
// class _FoodHistoryState extends State<HistoryScreen> {
//   List<Map<dynamic, dynamic>> likedRestaurants = [];
//
//   @override
//   void initState() {
//     super.initState();
//     //getLikedRestaurants();
//     fetchLiked();
//     getReviews();
//   }
//
//   final DatabaseReference ref = FirebaseDatabase.instance.ref();
//   List<Widget> childWidgets = [];
//
//   @override
//   State<HistoryScreen> createState() => _FoodHistoryState();
// }
//
// class _FoodHistoryState extends State<HistoryScreen> {
//   List<Map<dynamic, dynamic>> likedRestaurants = [];
//
//   @override
//   void initState() {
//     super.initState();
//     getLikedRestaurants();
//     fetchLiked();
//   }
//
//   //final DatabaseReference ref = FirebaseDatabase.instance.ref();
//
//   Future<Object?> getLikedRestaurants() async {
//     final String uid = FirebaseAuth.instance.currentUser!.uid;
//     //final DatabaseReference refUser = FirebaseDatabase.instance.ref('users/$uid');
//     final DatabaseReference refUser = FirebaseDatabase.instance.ref('users/4YJJliz1v9aN0mAmDJ0HllwVj4f2');
//
//
//     refUser.onValue.listen((event) {
//       final data = event.snapshot.value as Map<dynamic, dynamic>;
//       setState(() {
//         likedRestaurants = data['liked_restaurants'];
//         print("Entered here");
//         print(likedRestaurants);
//       });
//     });
//
//   }
//
//   Object? arrayData;
//   List<dynamic> dataList = [];
//   Map<dynamic, dynamic> data = {'Chinese': 'Chens Chinese Restaurant', 'American': 'Crooked Duck', 'Japanese': 'Goyen Sushi & Robata'};
//
//
//   Future<void> fetchLiked() async {
//     final String uid = FirebaseAuth.instance.currentUser!.uid;
//     final DatabaseReference databaseRef = FirebaseDatabase.instance.ref('users/4YJJliz1v9aN0mAmDJ0HllwVj4f2/liked_restaurants');
//
//     DatabaseEvent event = await databaseRef.once();
//     data = event.snapshot.value as Map<dynamic, dynamic>;
//     //arrayData = event.snapshot.value;
//   }
//
//
//   Future<void> getReviews() async {
//     final String uid = FirebaseAuth.instance.currentUser!.uid;
//     final DatabaseReference refUser =
//     FirebaseDatabase.instance.ref('users/$uid/reviews');
//     DatabaseEvent event = await refUser.once();
//     event.snapshot.children.forEach((childSnapshot) {
//       var key = childSnapshot.key as String;
//       var value = childSnapshot.value as String;
//
//       var childWidget = ListTile(
//         title: Text(key),
//         subtitle: Text(value),
//       );
//
//       childWidgets.add(childWidget);
//     });
//
//
//     event.snapshot.children.forEach((childSnapshot) {
//       print('Child key: ${childSnapshot.key}');
//       print('Child value: ${childSnapshot.value}');
//     });
//    //reviews = event.snapshot.children;
//   }
//
//   Object? arrayData;
//   List<dynamic> dataList = [];
//
//
//   Future<void> fetchLiked() async {
//     final String uid = FirebaseAuth.instance.currentUser!.uid;
//     final DatabaseReference databaseRef = FirebaseDatabase.instance.ref('users/4YJJliz1v9aN0mAmDJ0HllwVj4f2/liked_restaurants');
//
//     DatabaseEvent event = await databaseRef.once();
//
//
//     dataList = event.snapshot.value as List<dynamic>;
//     arrayData = event.snapshot.value;
//
//     print("sorry joey");
//     print(dataList[0]);
//     print(dataList[1]);
//     print(dataList[2]);
//
//   }
//
//
//
//   var likedRestaurantsTest = ['test','test2', 'test3','test4','test5'];
//
//
//
//   //var likedRestaurantsTest = ['test','test2', 'test3','test4','test5'];
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Food History'),
//       ),
//       body: ListView.builder(
//
//         itemCount: data.length,
//         itemBuilder: (BuildContext context, int index) {
//
//           final key = data.keys.elementAt(index);
//           final value = data[key];
//           return ListTile(
//             title: Text(key),
//             subtitle: Text(value.toString()),
//           );
//
//         },
//       ),
//
//
//     );
//   }
// }