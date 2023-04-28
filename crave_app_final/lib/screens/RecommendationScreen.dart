import 'dart:convert';

import 'package:crave_app_final/apiKeys.dart';
import 'package:crave_app_final/screens/CheckIn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
  late List<Map<String, dynamic>> reviews;
  String yelpId = '';
  late String generatedResponse;
  bool _generatedGpt = false;


  @override
  void initState() {
    super.initState();
    _fetchAndLoadBusinesses().then((_) => {
    getGptResponse(restaurant!['name'].toString(), restaurant!['location']['address1'].toString() +  ' ' + restaurant!['location']['city']),
    _fetchBusinessInfo(alias),
    fetchRestaurantReviews(yelpId),

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
      //final response = await http.get(Uri.parse( "https://function-1-e7rdmlktqa-uc.a.run.app")); MALHAR CHANGE THIS
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
          yelpId = restaurant!['id'].toString();
        });
        // await _fetchBusinessInfo(alias);
      }
    } catch (e) {
      print('Failed to fetch or load businesses: $e');
    }
  }

  void fetchRestaurantReviews(String? restaurantId) async {
    String url = 'https://api.yelp.com/v3/businesses/$restaurantId/reviews';

    // Add the Yelp API key to the request headers for authentication.
    Map<String, String> headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    // Send a GET request to the Yelp API to fetch the reviews for the restaurant.
    http.Response response = await http.get(Uri.parse(url), headers: headers);
    //getGptResponse(restaurant!['name'].toString(), restaurant!['location']['address1'].toString() +  ' ' + restaurant!['location']['address2'].toString());
    // Parse the response JSON and extract the reviews.
    Map<String, dynamic> responseData = json.decode(response.body);
    List<dynamic> reviewsData = responseData['reviews'];
    //reviews = reviewsData.map((review) => review as Map<String, dynamic>).toList();
    setState(() {
      reviews = reviewsData.map((review) => review as Map<String, dynamic>).toList();
    });
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

  Widget _buildgetreviews() {
    return ElevatedButton(
      onPressed: () async {
        // Use the Yelp API to fetch reviews for the current restaurant.
        //String? restaurantId = restaurant!['id'];
        // List<Map<String, dynamic>> reviews = await fetchRestaurantReviews(restaurantId);

        // Navigate to a new page that displays the restaurant reviews.
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RestaurantReviewsPage(reviews: reviews)),
        );
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        'Reviews',
        style: TextStyle(
          fontFamily: 'Arial',
          color: Colors.white,
        ),
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

  Widget _buildWebsiteButton() {
    String? website = restaurant!['url'];
    if (website == null) {
      // If there is no website URL available for the restaurant, return an empty SizedBox.
      return SizedBox();
    }
    return ElevatedButton(
      onPressed: () {
        // Launch the website in a new tab/window when the button is pressed.
        launchUrlString(website);
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        'Visit Website',
        style: TextStyle(
          fontFamily: 'Arial',
          color: Colors.white,
        ),
      ),
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

  Future<void> getGptResponse(String restaurantName, String Location) async {
    final response = await http.get(Uri.parse('http://127.0.0.1:5000/askgpt/'+"give me information about the restaurant ${restaurantName} which is in ${Location}"));
    //final response2 = await http.get(Uri.parse('http://127.0.0.1:5000/askgpt/'+" Whats the google rating and yelp rating for this restaurant ${restaurantDetails.result.name}"));
    setState(() {
      generatedResponse = response.body;  //+ response2.body;
      _generatedGpt = true;
    });
  }

  Widget _buildText() {
    return generatedResponse != null
        ? Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        generatedResponse!,
        style: TextStyle(
          fontFamily: 'Arial',
          fontSize: 16.0,
          color: Colors.black,
          height: 1.5,
        ),
      ),
    )
        : Center(child: CircularProgressIndicator());
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
                Row(
                  children: [
                    Expanded(
                      child: _buildAmenitiesButton(context),
                    ),
                  ],
                ),
                SizedBox(height:10),
                if(_generatedGpt == true) _buildText(),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildgetreviews(),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _buildWebsiteButton(),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                _buildStatusText(context),
                SizedBox(height: 20),
                _buildPhoneNumber(),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildFullMenuButton(context),
                    ),
                  ],
                ),
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


class RestaurantReviewsPage extends StatelessWidget {
  final List<Map<String, dynamic>> reviews;

  const RestaurantReviewsPage({Key? key, required this.reviews}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews'),
      ),
      body: ListView.builder(
        itemCount: reviews.length,
        itemBuilder: (BuildContext context, int index) {
          Map<String, dynamic> review = reviews[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(review['user']['image_url']),
            ),
            title: Text(review['user']['name']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RatingBarIndicator(
                  rating: review['rating'].toDouble(),
                  itemBuilder: (context, index) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 20.0,
                ),
                SizedBox(height: 4),
                Text(review['text']),
                SizedBox(height: 4),
                Text(review['time_created']),
              ],
            ),
          );
        },
      ),
    );
  }
}
