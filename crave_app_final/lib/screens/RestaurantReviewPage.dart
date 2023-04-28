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
  String _comments = '';
  int _counter = 0;

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
            fontFamily: 'Roboto',
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Builder(
        builder: (BuildContext context) => Padding(
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
              TextFormField(
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Enter your comments here...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _comments = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton (
                child: Text('Submit'),
                onPressed: ()  {
                  //print(widget.restaurant.placeId.toString());
                  DatabaseReference reviewsRef = FirebaseDatabase.instance.reference().child('users/${FirebaseAuth.instance.currentUser!.uid}/reviews');
                  reviewsRef.push().set({
                    'restaurantId': widget.restaurant.placeId,
                    'restaurantName': widget.restaurant.name,
                    'rating': _rating,
                    'comments': _comments,
                    'timestamp': ServerValue.timestamp,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review submitted successfully.')));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
