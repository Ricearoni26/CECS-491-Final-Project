import 'dart:convert';

import 'package:crave_app_final/apiKeys.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;

class RecommendationScreen extends StatefulWidget {
  final String category;

  RecommendationScreen({required this.category});

  @override
  _RecommendationScreenState createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  int decodedIndex = 0;
  Map<String, dynamic>? restaurant;

  @override
  void initState() {
    super.initState();

    _fetchAndLoadBusinesses();
  }

  Future<void> _fetchAndLoadBusinesses() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/msg/${widget.category}'));
      final decoded = json.decode(response.body) as List<dynamic>;
      if (decoded.isNotEmpty) {
        final restaurantId = decoded[decodedIndex];
        final yelpResponse = await http.get(
            Uri.parse('https://api.yelp.com/v3/businesses/$restaurantId'),
            headers: {'Authorization': 'Bearer $apiKey'});
        final yelpDecoded =
        json.decode(yelpResponse.body) as Map<String, dynamic>;
        setState(() {
          restaurant = yelpDecoded;
        });
      }
    } catch (e) {
      print('Failed to fetch or load businesses: $e');
    }
  }

  // Future<Map<String, dynamic>> getRestaurantDetails(String restaurantName) async {
  //   final String apiKey = googleMapsAPIKey;
  //   final String url = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json" +
  //       "?input=${Uri.encodeQueryComponent(restaurantName)}" +
  //       "&inputtype=textquery" +
  //       "&fields=name,rating,types,photos,reviews,opening_hours" +
  //       "&key=$apiKey";
  //
  //   final response = await http.get(Uri.parse(url));
  //   if (response.statusCode != 200) {
  //     throw Exception("Failed to get restaurant details");
  //   }
  //
  //   final result = jsonDecode(response.body);
  //   if (result["status"] != "OK") {
  //     throw Exception("No restaurant found with name: $restaurantName");
  //   }
  //
  //   final placeId = result["candidates"][0]["place_id"];
  //   final detailsUrl = "https://maps.googleapis.com/maps/api/place/details/json" +
  //       "?place_id=$placeId" +
  //       "&fields=name,rating,types,photos,reviews,opening_hours" +
  //       "&key=$apiKey";
  //
  //   final detailsResponse = await http.get(Uri.parse(detailsUrl));
  //   if (detailsResponse.statusCode != 200) {
  //     throw Exception("Failed to get restaurant details");
  //   }
  //
  //   final detailsResult = jsonDecode(detailsResponse.body);
  //   if (detailsResult["status"] != "OK") {
  //     throw Exception("Failed to get restaurant details");
  //   }
  //
  //   final Map<String, dynamic> restaurantDetails = {
  //     "name": detailsResult["result"]["name"],
  //     "rating": detailsResult["result"]["rating"],
  //     "types": detailsResult["result"]["types"],
  //     "photos": detailsResult["result"]["photos"],
  //     "reviews": detailsResult["result"]["reviews"],
  //     "opening_hours": detailsResult["result"]["opening_hours"]
  //   };
  //
  //   return restaurantDetails;
  // }

  void _handleYesButton() {
    setState(() {
      decodedIndex++;
      restaurant = null;
    });
    _fetchAndLoadBusinesses();
  }

  void _handleCancelButton() {
    Navigator.pop(context);
  }

  void _handleYes2Button() async {
    if (restaurant != null) {
      final restaurantId = restaurant!['id'];
      final category = widget.category;
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userId = currentUser.uid;
        final likedRestaurantRef = FirebaseDatabase.instance
            .reference()
            .child('users')
            .child(userId)
            .child('liked_restaurants')
            .push();
        likedRestaurantRef.set({
          'id': restaurantId,
          'category': category,
        });
        final recommendationMessage =
            "You should try ${restaurant!['name']}! Added to liked restaurants";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(recommendationMessage),
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recommendations"),
      ),
      body: restaurant != null
          ? ListView(
        children: [
          if (restaurant!['image_url'] != null)
            Image.network(
              restaurant!['image_url'],
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant!['name'],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                if (restaurant!['location'] != null &&
                    restaurant!['location']['address1'] != null)
                  Text(
                    restaurant!['location']['address1'],
                    style: TextStyle(fontSize: 16),
                  ),
                if (restaurant!['location'] != null &&
                    restaurant!['location']['city'] != null)
                  Text(
                    restaurant!['location']['city'],
                    style: TextStyle(fontSize: 16),
                  ),
                if (restaurant!['location'] != null &&
                    restaurant!['location']['state'] != null)
                  Text(
                    restaurant!['location']['state'],
                    style: TextStyle(fontSize: 16),
                  ),
                if (restaurant!['location'] != null &&
                    restaurant!['location']['zip_code'] != null)
                  Text(
                    restaurant!['location']['zip_code'],
                    style: TextStyle(fontSize: 16),
                  ),
                if (restaurant!['phone'] != null)
                  SizedBox(height: 10),
                Text(
                  restaurant!['phone'],
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _handleYesButton,
                      child: Text("No"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _handleCancelButton,
                      child: Text("Cancel"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _handleYes2Button,
                      child: Text("Yes"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      )
          : Center(child: CircularProgressIndicator()),
    );
  }
}

