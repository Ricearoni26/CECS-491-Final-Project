import 'dart:convert';

import 'package:crave_app_final/apiKeys.dart';
import 'package:crave_app_final/screens/CheckIn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

import 'YelpBusinessScreen.dart';

class RecommendationScreen extends StatefulWidget {
  final String category;

  RecommendationScreen({required this.category});

  @override
  _RecommendationScreenState createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  int decodedIndex = 0;
  int hourindex = 0;
  Map<String, dynamic>? restaurant;
  List<String> _availableItems = [];
  List<String> _notAvailableItems = [];
  String alias = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAndLoadBusinesses();
    // Future.delayed(Duration.zero, () {
    //   _fetchBusinessInfo(alias);
    // });
  }

  Future<void> _fetchBusinessInfo(String alias12) async {
    try {
      final String url = 'http://127.0.0.1:5000/amen/$alias12';
      final response = await http.get(Uri.parse(url));
      final List<dynamic> items = json.decode(response.body) as List<dynamic>; // parse response as a list of lists
      setState(() {
        _availableItems = List<String>.from(items[0]);
        _notAvailableItems = List<String>.from(items[1]);
      });
    } catch (e) {
      setState(() {
        _availableItems = ['Error retrieving business information'];
        _notAvailableItems = [];
      });
    }finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> _fetchAndLoadBusinesses() async {
    setState(() {
      isLoading = true;
    });
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
          alias = restaurant!['alias'].toString();
        });
        await _fetchBusinessInfo(alias);
      }
    } catch (e) {
      print('Failed to fetch or load businesses: $e');
    }
  }


  Future<Map<String, dynamic>> fetchData(String alias) async {
    final response =
        await http.get(Uri.parse('https://www.yelp.com/biz/$alias'));
    final document = parser.parse(response.body);
    final table = document.querySelector('.hours-table__09f24__KR8wh');
    final rows = table?.getElementsByTagName('tr');
    final hours = <String>[];
    for (final row in rows!) {
      final day = row.querySelector('.day-of-the-week__09f24__JJea_');
      final time = row.querySelector('.no-wrap__09f24__c3plq');
      if (day != null && time != null) {
        final dayText = day.text;
        final timeText = time.text;
        hours.add('$dayText: $timeText');
      }
    }
    final amenities = document
        .querySelectorAll('.arrange-unit__09f24__rqHTg')
        .map((e) => e.querySelector('.css-1p9ibgf')?.text?.trim() ?? '')
        .where((amenity) => amenity.isNotEmpty)
        .where((amenity) => amenity != "Suggest an edit")
        .toList();
    return {'hours': hours, 'amenities': amenities};
  }


  Future<String> getYelpUrl(String restaurantName, String location) async {
    final response = await http
        .get(Uri.parse('http://127.0.0.1:5000/url/$restaurantName/$location'));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load Yelp URL');
    }
  }

  Future<String> getYelpMenuUrl(String ogUrl) async {
    final response =
        await http.get(Uri.parse('http://127.0.0.1:5000/menuurl/$ogUrl'));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load Yelp menu URL');
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
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
                      Row(
                        children: [
                          Text(
                            restaurant!['name'],
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => YelpBusinessScreen(alias: restaurant!['alias'].toString(), availableItems: _availableItems, notAvailableItems: _notAvailableItems )));
                            },
                            child: Text(
                              "Amenities",
                              style: TextStyle(
                                fontFamily: "Arial", color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
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
                      if (restaurant!['phone'] != null) SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.phone),
                          SizedBox(width: 5),
                          Text(
                            restaurant!['phone'],
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      FutureBuilder<Map<String, dynamic>>(
                        future: fetchData(restaurant!['alias']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            final hours =
                                snapshot.data!['hours'] as List<String>;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10),
                                Text(
                                  'Business Hours:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 5),
                                ...hours.map((hours) => Text(
                                      hours,
                                      style: TextStyle(fontSize: 16),
                                    )),
                              ],
                            );
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _handleYesButton,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              primary: Colors.orange,
                            ),
                            child: Text(
                              "No",
                              style: TextStyle(
                                fontFamily: 'Arial',
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _handleCancelButton,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              primary: Colors.orange,
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                fontFamily: 'Arial',
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _handleYes2Button,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              primary: Colors.orange,
                            ),
                            child: Text(
                              "Yes",
                              style: TextStyle(
                                fontFamily: 'Arial',
                                color: Colors.white,
                              ),
                            ),
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
