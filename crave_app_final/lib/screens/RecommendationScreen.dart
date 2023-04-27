import 'dart:convert';

import 'package:crave_app_final/apiKeys.dart';
import 'package:crave_app_final/screens/CheckIn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';

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
  bool isLoading = false;
  int lock = 0;

  @override
  void initState() {
    super.initState();
    _fetchAndLoadBusinesses().then((_) => {
    _fetchBusinessInfo(alias)
    });
  }

  Future<void> _fetchBusinessInfo(String alias12) async {
    try {
      final String url = 'http://127.0.0.1:5000/amen/$alias12';
      final response = await http.get(Uri.parse(url));
      final List<dynamic> items = json.decode(response.body)
      as List<dynamic>; // parse response as a list of lists
      if (mounted) {
        setState(() {
          _availableItems = List<String>.from(items[0]);
          _notAvailableItems = List<String>.from(items[1]);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _availableItems = ['Error retrieving business information'];
          _notAvailableItems = [];
        });
      }
    }
  }

  Future<void> _fetchAndLoadBusinesses() async {
    try {
      String fixed = widget.category.replaceAll('/', ' ');
      final encodedCategory = Uri.encodeComponent(fixed);
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/msg/$encodedCategory'));
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
        // await _fetchBusinessInfo(alias);
      }
    } catch (e) {
      print('Failed to fetch or load businesses: $e');
    }
  }

  void _handleNoButton() {
    setState(() {
      decodedIndex++;
      restaurant = null;
    });
    _fetchAndLoadBusinesses();
  }

  void _handleCancelButton() {
    Navigator.pop(context);
  }

  void _handleYesButton() async {
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

  String getDayName(int day) {
    switch (day) {
      case 0:
        return "Mon";
      case 1:
        return "Tue";
      case 2:
        return "Wed";
      case 3:
        return "Thu";
      case 4:
        return "Fri";
      case 5:
        return "Sat";
      case 6:
        return "Sun";
      default:
        return "";
    }
  }

  String getFormattedTime(String time) {
    final hour = int.parse(time.substring(0, 2));
    final minute = time.substring(2, 4);
    final meridian = hour < 12 ? "AM" : "PM";
    final formattedHour = hour > 12 ? hour - 12 : hour;
    return "$formattedHour:$minute $meridian";
  }

  String getFormattedHours(List<dynamic> hours) {
    String formattedHours = "";
    for (var hour in hours) {
      String openTime = getFormattedTime(hour['start']);
      String closeTime = getFormattedTime(hour['end']);
      formattedHours += "${getDayName(hour['day'])}: $openTime - $closeTime\n";
    }
    return formattedHours;
  }

  String getFormattedTransactions(List<dynamic> transactions) {
    if (transactions == null || transactions.isEmpty) {
      return 'N/A';
    }

    List<String> transactionTitles = [];
    for (dynamic transaction in transactions) {
      if (transaction != null && transaction is String) {
        transactionTitles.add(transaction.replaceAll('_', ' '));
      }
    }

    return transactionTitles.join(', ');
  }

  // String getFormattedPhotos(List<dynamic> photos) {
  //   String result = "";
  //
  //   for (int i = 0; i < photos.length; i++) {
  //     result += "${photos[i]['caption']}";
  //     if (i < photos.length - 1) {
  //       result += ", ";
  //     }
  //   }
  //
  //   return result;
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildContent(context),
    );
  }

  Widget details(BuildContext context, Map<String, dynamic> restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Address: ${restaurant['location']['address1']}, ${restaurant['location']['city']}, ${restaurant['location']['state']} ${restaurant['location']['zip_code']}",
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 10),
        Text(
          "Categories: ${restaurant['categories'][0]['title']}, ${restaurant['categories'][1]['title']}",
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 10),
        Text(
          "Rating: ${restaurant['rating']} out of 5 with ${restaurant['review_count']} reviews",
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 10),
        Text(
          "Price Range: ${restaurant['price']}",
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 10),
        // Text(
        //   "Photos: ${getFormattedPhotos(restaurant['photos'])}",
        //   style: TextStyle(fontSize: 16),
        // ),
        // SizedBox(height: 10),
        Text(
          "Open Hours: ${getFormattedHours(restaurant['hours']['open'])}",
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 10),
        Text(
          "Transactions: ${getFormattedTransactions(restaurant['transactions'])}",
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            launch(restaurant['url']);
          },
          child: Text(
            "View on Yelp",
            style: TextStyle(
              fontFamily: "Arial",
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            primary: Colors.orange,
          ),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            launch(restaurant['yelp_menu_url']);
          },
          child: Text(
            "View Menu on Yelp",
            style: TextStyle(
              fontFamily: "Arial",
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            primary: Colors.orange,
          ),
        ),
      ],
    );
  }


  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        "Recommendations",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }


  Widget _buildImage() {
    return restaurant!['image_url'] != null
        ? Image.network(
      restaurant!['image_url'],
      height: 250,
      width: double.infinity,
      fit: BoxFit.cover,
    )
        : SizedBox();
  }

  Widget _buildNameAndAddress() {
    return Column(
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
      ],
    );
  }

  Widget _buildAmenitiesButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _availableItems.isNotEmpty
          ? () {
        // Navigate to the YelpBusinessScreen if there are available items
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => YelpBusinessScreen(
                alias: restaurant!['alias'].toString(),
                availableItems: _availableItems,
                notAvailableItems: _notAvailableItems)));
      }
          : null,
      child: Text(
        "Amenities",
        style: TextStyle(
          fontFamily: "Arial",
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildStatusText(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (restaurant!['hours'] != null) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Hours"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: restaurant!['hours'][0]['open']
                        .map<Widget>((hour) {
                      return Text(
                        "${getDayName(hour['day'])}: ${getFormattedTime(hour['start'])} - ${getFormattedTime(hour['end'])}",
                        style: TextStyle(fontSize: 16),
                      );
                    }).toList(),
                  ),
                  actions: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Close"),
                    ),
                  ],
                );
              },
            );
          }
        },
        child: Row(
          children: [
          Text(
          "Status: ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        if (restaurant!['is_closed'])
          if (restaurant!['is_closed'])
            Text(
              "Closed",
              style: TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
            if (!restaurant!['is_closed'])
              Text(
                "Open",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
          ],
        ),
    );
  }






    // Display "Closed" if the
    Widget _buildPhoneNumber() {
      return restaurant!['phone'] != null
          ? Row(
        children: [
          Icon(Icons.phone),
          SizedBox(width: 5),
          Text(
            restaurant!['phone'],
            style: TextStyle(fontSize: 16),
          ),
        ],
      )
          : SizedBox();
    }

    Widget _buildFullMenuButton(BuildContext context) {
      return ElevatedButton(
        onPressed: () {
// Navigate to the MenuItemsPage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MenuItemsPage(
                restUrl: restaurant!['alias'].toString(),
              ),
            ),
          );
        },
        child: Text(
          "Full menu",
          style: TextStyle(
            fontFamily: "Arial",
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          primary: Colors.orange,
        ),
      );
    }

    Widget _buildYesNoButtons() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
// Handle Yes button press
              _handleYesButton();
            },
            child: Text(
              "Yes",
              style: TextStyle(
                fontFamily: "Arial",
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              primary: Colors.orange,
            ),
          ),
          ElevatedButton(
            onPressed: () {
// Handle Cancel button press
              _handleCancelButton();
            },
            child: Text(
              "Cancel",
              style: TextStyle(
                fontFamily: "Arial",
                color: Colors.black,
              ),
            ),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
            ),
          ),
          ElevatedButton(
            onPressed: () {
// Handle No button press
              _handleNoButton();
            },
            child: Text(
              "No",
              style: TextStyle(
                fontFamily: "Arial",
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.orange,
            ),
          ),
        ],
      );
    }

    Widget _buildContent(BuildContext context) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: restaurant != null
            ? ListView(
          children: [
            _buildImage(),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNameAndAddress(),
                  SizedBox(height: 10),
                  _buildAmenitiesButton(context),
                  SizedBox(height: 10),
                  _buildStatusText(context),
                  SizedBox(height: 20),
                  _buildPhoneNumber(),
                  SizedBox(height: 10),
                  _buildFullMenuButton(context),
                  SizedBox(height: 10),
                  _buildYesNoButtons(),
                ],
              ),
            ),
          ],
        )
            : Center(child: CircularProgressIndicator()),
      );
    }
  }
