import 'package:crave_app_final/apiKeys.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../apiKeys.dart';

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
    //getLikedRestaurants();
    fetchLiked();
    fetchReviews();
    fetchCheckIn();
    //getReviews();
  }

  final DatabaseReference ref = FirebaseDatabase.instance.ref();
  List<Widget> childWidgetsReview = [];



  Future<Object?> getLikedRestaurants() async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final DatabaseReference refUser = FirebaseDatabase.instance.ref('users/$uid');
    //final DatabaseReference refUser = FirebaseDatabase.instance.ref('users/4YJJliz1v9aN0mAmDJ0HllwVj4f2');



    refUser.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        likedRestaurants = data['liked_restaurants'];
        print("Entered here");
        print(likedRestaurants);
      });

    });

  }

  //Map<dynamic, dynamic> data = {'Chinese': 'Chens Chinese Restaurant', 'American': 'Crooked Duck', 'Japanese': 'Goyen Sushi & Robata'};
  //Map<dynamic, dynamic> staticReview = {'Cha for Tea-LongBeach': 4, 'Bobaguys': 4};

  Map<dynamic, dynamic> getLikedMap = {};

  Future<void> fetchLiked() async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref('users/$uid/liked_restaurants');

    DatabaseEvent event = await databaseRef.once();
    setState(() {
      getLikedMap = event.snapshot.value as Map<dynamic, dynamic>;
    });
    //data = event.snapshot.value as Map<dynamic, dynamic>;
    //arrayData = event.snapshot.value;
  }


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


  Future<void> getReviews() async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final DatabaseReference refUser =
    FirebaseDatabase.instance.ref('users/$uid/reviews');
    DatabaseEvent event = await refUser.once();
    event.snapshot.children.forEach((childSnapshot) {
      var key = childSnapshot.key as String;
      var value = childSnapshot.value as String;

      var childWidget = ListTile(
        title: Text(key),
        subtitle: Text(value.toString()),
      );

      childWidgetsReview.add(childWidget);
    });


    event.snapshot.children.forEach((childSnapshot) {
      print('Child key: ${childSnapshot.key}');
      print('Child value: ${childSnapshot.value}');
    });
   //reviews = event.snapshot.children;
  }



  //var likedRestaurantsTest = ['test','test2', 'test3','test4','test5'];


  //Search Yelp API using restaurant ID
  Future<dynamic> searchRestaurantById(String restaurantId) async {
    final String baseUrl = 'https://api.yelp.com/v3/businesses/';
    final String yelpApiKey = apiKey;
    final String endpoint = baseUrl + restaurantId;

    final response = await http.get(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Bearer $yelpApiKey',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> businesses = jsonResponse['businesses'];
      final List<String> categories = [];

      businesses.forEach((business) {
        final List<dynamic> businessCategories = business['categories'];
        businessCategories.forEach((category) {
          categories.add(category['title']);
        });
      });

      return categories.toSet()
          .toList(); // Remove duplicates and return as List
    } else {
      throw Exception('Failed to load categories');
    }
  }



  @override
  Widget build(BuildContext context) {

    List<Widget> widgets1 = [];
    List<Widget> widgets2 = [];
    List<Widget> widgets3 = [];

    // Create a list tile widget for map1
    ListTile map1Title = ListTile(
      title: Text('Map 1'),
    );

    // Create a list tile widget for map2
    ListTile map2Title = ListTile(
      title: Text('Map 2'),
    );


    // Create a list tile widget for map2
    ListTile map3Title = ListTile(
      title: Text('Map 3'),
    );

    // Create a list of widgets for Liked Restaurants
    getLikedMap.forEach((key, value) {
      Widget widget = ListTile(
        title: Text(key),
        subtitle: Text(value.toString()),
      );
      widgets1.add(widget);
    });

    // Create a list of widgets for user reviews
    getReviewMap.forEach((key, value) {
      Widget widget = ListTile(
        title: Text(key),
        subtitle: Text(value.toString()),
      );
      widgets2.add(widget);
    });


    // Create a list of widgets for user reviews
    getCheckInMap.forEach((key, value) {
      Widget widget = ListTile(
        title: Text(key),
        subtitle: Text(value.toString()),
      );
      widgets3.add(widget);
    });


    // Concatenate the two lists of widgets using the + operator
    List<Widget> widgets = widgets1 + widgets2 + widgets3;

    return Scaffold(
      appBar: AppBar(
        title: Text('Food History'),
      ),
      body: ListView.builder(
        itemCount: widgets.length,
        itemBuilder: (BuildContext context, int index) {
          return widgets[index];
        },
      ),
    );
  }



}


