import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:rating_dialog/rating_dialog.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({Key? key}) : super(key: key);

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dummy Ratings Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Restaurant Review',
            ),
            RatingDialog(
              initialRating: 1.0,
              // your app's name?
              title: const Text(
                'Rating Dialog',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // encourage your user to leave a high rating?
              message: const Text(
                'Tap a star to set your rating. Add more description here if you want.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ),
              // your app's logo?
              submitButtonText: 'Submit',
              commentHint: 'Describe your experience',
              onCancelled: () => print('cancelled'),
              onSubmitted: (response) {
                //print('rating: ${response.rating}, comment: ${response.comment}');

                // TODO: add your own logic
                if (response.rating > 3.0) {
                  pushReview(response.rating, response.comment);
                  // send their comments to your email or anywhere you wish
                  // ask the user to contact you instead of leaving a bad review
                } else {
                  //rateAndReviewApp();
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Future<void> pushReview(double rating, String comment) async{
    final user = FirebaseAuth.instance.currentUser!;
    String uid = user.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref('users').child(uid).child('rating');
    await ref.set({'comment': comment, 'rating' : rating});

    final snapshot = await ref.child('rating').get();
    if (snapshot.exists) {
      print(snapshot.value);
    } else {
      print('No data available.');
    }
  }

}