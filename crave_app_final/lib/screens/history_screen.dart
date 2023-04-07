import 'package:crave_app_final/apiKeys.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../apiKeys.dart';


class HistoryScreen extends StatelessWidget {
  final DatabaseReference ref = FirebaseDatabase.instance.ref();


  //Retrieve restaurant ID of liked restaurants from Firebase
  Future<String> getLikedRestaurants() async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final DatabaseReference refUser = FirebaseDatabase.instance.ref('users/$uid/liked_restaurants');

    final Completer<String> completer = Completer<String>();

    refUser.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final likedRestList = data;
      print(data)
      //final fullName = '${data['firstName']} ${data['lastName']} ${data['preferences']['Additional services']} ';
      //print('Full name: $fullName');
      //completer.complete(fullName);
    });

    final String fullName = await completer.future;
    print('Returning full name: $fullName');
    return fullName;
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

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse;
    } else {
      throw Exception('Failed to load restaurant details');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food History'),
      ),
      body: Center(
        child: FutureBuilder<String>(
          future: displayUserDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            return Text(snapshot.data ?? '');
          },
        ),
      ),
    );
  }
}
