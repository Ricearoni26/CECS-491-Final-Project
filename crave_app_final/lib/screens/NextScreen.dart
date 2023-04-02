import 'package:crave_app_final/apiKeys.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class RecommendationScreen extends StatefulWidget {
  final String category;

  RecommendationScreen({required this.category});

  @override
  _RecommendationScreenState createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  List _businesses = [];

  @override
  void initState() {
    super.initState();
    _fetchBusinesses();
  }

  void _fetchBusinesses() async {
    final response = await http.get(
      Uri.parse(
        'https://api.yelp.com/v3/businesses/search?location=San+Francisco&categories=${widget.category}',
      ),
      headers: {
        'Authorization': 'Bearer $apiKey',
      },
    );
    final data = json.decode(response.body);
    setState(() {
      _businesses = data['businesses'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recommendation Screen'),
      ),
      body: ListView.builder(
        itemCount: _businesses.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_businesses[index]['name']),
            subtitle: Text(_businesses[index]['location']['address1']),
            trailing: Text(_businesses[index]['rating'].toString()),
          );
        },
      ),
    );
  }
}




