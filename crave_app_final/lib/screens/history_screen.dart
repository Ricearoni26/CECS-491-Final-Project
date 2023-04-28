import 'package:crave_app_final/apiKeys.dart';
import 'package:crave_app_final/screens/reviewHistory.dart';
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
    fetchLiked();
    fetchReviews();
    fetchCheckIn();
  }

  final DatabaseReference ref = FirebaseDatabase.instance.ref();



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


  Map<dynamic, dynamic> getReviewMap = {};

  //Get Reviews of restaurants from Firebase
  Future<void> fetchReviews() async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref('users/$uid/reviews');

    DatabaseEvent event = await databaseRef.once();
    setState(() {
      getReviewMap = event.snapshot.value as Map<dynamic, dynamic>;
    });

  }


  Map<dynamic, dynamic> getCheckInMap = {};

  //Get restaurants the user has checked-in at
  Future<void> fetchCheckIn() async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref('users/$uid/checkIns');

    DatabaseEvent event = await databaseRef.once();
    setState(() {
      getCheckInMap = event.snapshot.value as Map<dynamic, dynamic>;
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
    //print(response.statusCode);
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      return jsonResponse;
      //print('here');
      //print(jsonResponse);
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

      //print(searchRestaurantById(key));
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

    List<Map<dynamic, dynamic> > maps = [getReviewMap, getLikedMap, getCheckInMap];

    return Scaffold(
      appBar: AppBar(
        title: Text('Food History'),
      ),
      body: ListView.builder(
        itemCount: 3, //maps.length,
        itemBuilder: (context, index) {
          return IndexedStack(
            index: index,
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: 7, //getReviewMap.length,
                itemBuilder: (context, subIndex) {
                  String key = getReviewMap.keys.elementAt(subIndex);
                  Map<dynamic, dynamic> value = getReviewMap.values.elementAt(subIndex);


                  String comment = value['comments'].toString();
                  String name = value['restaurantName'].toString();
                  String rating = value['rating'].toString();

                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(name +'\nComment: ' + comment + '\nRated: '+ rating,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  );
                },
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: getCheckInMap.length,
                itemBuilder: (context, subIndex) {
                  String key = getCheckInMap.keys.elementAt(subIndex);
                  List<dynamic> value = getCheckInMap.values.elementAt(subIndex);

                  String name = value[0];
                  String addy = value[1];


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
              ListView.builder(
                shrinkWrap: true,
                itemCount: getLikedMap.length,
                itemBuilder: (context, subIndex) {
                  String key = getLikedMap.keys.elementAt(subIndex);
                  Map<dynamic, dynamic> value = getLikedMap.values.elementAt(subIndex);


                  String category = value['category'];
                  String yelpID = value['id'].toString();
                  //Map<dynamic, dynamic> yelpReturn = searchRestaurantById(yelpID) as Map;
                  //yelpReturn.forEach((key, value) {
                  //  print(key);
                  //});
                  //print(searchRestaurantById(yelpID)['alias']);

                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(category,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  );
                },
              ),

            ],
          );
        },
      ),






      //ListView.builder(
      //  itemCount: widgets.length,
      //  itemBuilder: (BuildContext context, int index) {
      //    return widgets[index];
      //  },
      //),
    );
  }



}


