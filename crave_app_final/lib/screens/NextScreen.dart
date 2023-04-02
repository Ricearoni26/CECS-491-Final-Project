import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class NextScreen extends StatefulWidget {
  final String selectedCategory;




const NextScreen({Key? key, required this.selectedCategory}) : super(key: key);

  @override
  State<NextScreen> createState() => _NextScreenState();
}

class _NextScreenState extends State<NextScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 70.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                'Recommended Restaurant',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Other widgets can be added here
          ],
        ),
      ),
    );
  }
}

final String yelpApiKey = yelpApiKey;

class Restaurant {
  final String name;
  final String address;
  final double rating;
  final String category;

  Restaurant({
    required this.name,
    required this.address,
    required this.rating,
    required this.category,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      name: json['name'],
      address: json['location']['address1'],
      rating: json['rating'].toDouble(),
      category: json['categories'][0]['title'],
    );
  }
}

class RestaurantRecommendationScreen extends StatefulWidget {
  final String category;

  const RestaurantRecommendationScreen({Key? key, required this.category}) : super(key: key);

  @override
  _RestaurantRecommendationScreenState createState() =>
      _RestaurantRecommendationScreenState();
}

class _RestaurantRecommendationScreenState
    extends State<RestaurantRecommendationScreen> {
  List<Restaurant> _restaurants = [];

  @override
  void initState() {
    super.initState();
    _fetchRestaurants(widget.category);
  }

  Future<void> _fetchRestaurants(String category) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.yelp.com/v3/businesses/search?term=restaurants&location=San+Francisco&categories=$category&limit=5'), // Added &limit=5
        headers: {'Authorization': 'Bearer $yelpApiKey'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _restaurants =
              List.from(jsonData['businesses']).map((json) => Restaurant.fromJson(json)).toList();
        });
      } else {
        print('Error fetching restaurants: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant Recommendations'),
      ),
      body: ListView.builder(
        itemCount: _restaurants.length,
        itemBuilder: (context, index) {
          final restaurant = _restaurants[index];
          if (restaurant.category.toLowerCase() == widget.category.toLowerCase()) {
            return ListTile(
              title: Text(restaurant.name),
              subtitle: Text(restaurant.address),
              trailing: Text(restaurant.rating.toString()),
            );
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }
}


