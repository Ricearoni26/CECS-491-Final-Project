import 'dart:convert';

import 'package:crave_app_final/apiKeys.dart';
import 'package:flutter/material.dart';
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
      final response = await http
          .get(Uri.parse('http://127.0.0.1:5000/msg/${widget.category}'));
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

  void _handleYes2Button() {
    if (restaurant != null) {
      final recommendationMessage = "You should try ${restaurant!['name']}!";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(recommendationMessage),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recommendations"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Center(
          child: restaurant != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(restaurant!['name'],
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    if (restaurant!['location'] != null &&
                        restaurant!['location']['address1'] != null)
                      Text(restaurant!['location']['address1'],
                          style: TextStyle(fontSize: 16)),
                    if (restaurant!['phone'] != null)
                      Text(restaurant!['phone'],
                          style: TextStyle(fontSize: 16)),
                    SizedBox(height: 10),
                    if (restaurant!['image_url'] != null)
                      Image.network(
                        restaurant!['image_url'],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    SizedBox(height: 10),
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
                )
              : CircularProgressIndicator(),
        ),
      ),
    );
  }
}
