import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_webservice/places.dart';

class RestaurantReviewPage extends StatefulWidget {
  final PlacesSearchResult restaurant;

  RestaurantReviewPage({required this.restaurant});

  @override
  _RestaurantReviewPageState createState() => _RestaurantReviewPageState();
}

class _RestaurantReviewPageState extends State<RestaurantReviewPage> {
  double _rating = 0;
  Set<String> _selectedComments = Set();
  List<String> _preMadeComments = [
    'Great food!',
    'Bad food',
    'Good service',
    'Poor service',
    'Horrible atmosphere',
    'Nice atmosphere',
    'cheap',
    'Overpriced',
    'Will definitely come back!',
    'Friendly staff',
    'Unfriendly staff',
    'Fast service',
    'Excellent drinks',
    'Cozy ambiance',
    'Limited menu options',
    'Uncomfortable seating',
    'Slow kitchen',
    'Dirty restrooms',
    'Inattentive waitstaff',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Review ${widget.restaurant.name}',
          style: TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'arial',
            color: Colors.grey,
          ),
        ),
        actions: [
        ],
      ),
      body: Builder(
        builder: (BuildContext context) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text('Rating'),
                SizedBox(height: 10),
                RatingBar(
                  initialRating: _rating,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  ratingWidget: RatingWidget(
                    full: Icon(Icons.star, color: Colors.amber),
                    half: Icon(Icons.star_half, color: Colors.amber),
                    empty: Icon(Icons.star_border, color: Colors.amber),
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _rating = rating;
                    });
                  },
                ),
                SizedBox(height: 20),
                Text('Comments'),
                SizedBox(height: 10),
                Wrap(
                  children: _preMadeComments.map((comment) {
                    bool isSelected = _selectedComments.contains(comment);
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.0),
                          color: isSelected ? Colors.orange : Colors.white,
                          border: Border.all(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedComments.remove(comment);
                              } else {
                                _selectedComments.add(comment);
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Text(
                              comment,
                              style: TextStyle(
                                fontSize: 20.0,
                                fontFamily: 'Arial',
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                //onChanged: (value) {
                //  setState(() {
                //    _comments = value;
                //  });
                //},
             // ),
              SizedBox(height: 20),
              ElevatedButton (
                child: Text('Submit'),
                onPressed: ()  {
                  //print(widget.restaurant.placeId.toString());
                  DatabaseReference reviewsRef = FirebaseDatabase.instance.ref().child('users/${FirebaseAuth.instance.currentUser!.uid}/reviews');
                  print(_selectedComments);
                  reviewsRef.push().set({
                    'restaurantId': widget.restaurant.placeId,
                    'restaurantName': widget.restaurant.name,
                    'rating': _rating,
                    'comments': _selectedComments,
                    'timestamp': ServerValue.timestamp,
                  });

                  print('Stored');
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review submitted successfully.')));
                  Navigator.pop(context);
                },
              ),
            ],

          ),
        ),
      ),
    ),
    );
  }
}
