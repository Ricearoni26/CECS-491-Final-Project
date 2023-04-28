import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../apiKeys.dart';

class likedHistory extends StatefulWidget {
  const likedHistory({Key? key}) : super(key: key);

  @override
  State<likedHistory> createState() => _likedHistoryState();
}

class _likedHistoryState extends State<likedHistory> {

  Map<dynamic, dynamic> getLikedMap = {};

  //Get Liked Restaurants from Firebase
  Future<void> fetchLiked() async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref('users/$uid/liked_restaurants');

    DatabaseEvent event = await databaseRef.once();
    setState(() {
      getLikedMap = event.snapshot.value as Map<dynamic, dynamic>;
    });

  }



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
    print(response.statusCode);
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      print('here');
      print(jsonResponse);
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Liked Restaurants'),
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: getLikedMap.length,
        itemBuilder: (context, subIndex) {
          String key = getLikedMap.keys.elementAt(subIndex);
          Map<dynamic, dynamic> value = getLikedMap.values.elementAt(subIndex);

          String yelpID = value['id'].toString();
          String name = '';
          String addy = '';
          searchRestaurantById(yelpID);

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
