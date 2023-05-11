import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'GoogleToYelpPage.dart';


class saveRestaurant extends StatefulWidget {
  const saveRestaurant({Key? key}) : super(key: key);

  @override
  State<saveRestaurant> createState() => _saveRestaurantState();
}


class _saveRestaurantState extends State<saveRestaurant> {


  //Map of previous check-ins
  Map<dynamic, dynamic> savedRestaurantsMap = {};


  //Get saved restaurants from Firebase
  Future<Map<dynamic, dynamic>> fetchSavedRestaurants() async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref('users/$uid/savedRestaurants');

    DatabaseEvent event = await databaseRef.once();
    setState(() {
      savedRestaurantsMap = event.snapshot.value as Map<dynamic, dynamic>;
    });

    return savedRestaurantsMap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        title: Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            'Saved Restaurants',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.white,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20.0),
                Text(
                  'Restaurants',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
                SizedBox(height: 10.0),
                FutureBuilder<Map<dynamic, dynamic>>(
                  future: fetchSavedRestaurants(),
                  builder: (BuildContext context,
                      AsyncSnapshot<Map<dynamic, dynamic>> snapshot) {
                    if (snapshot.hasData) {
                      final savedRestaurants = snapshot.data!;
                      print('rest info');
                      print(savedRestaurants);
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: savedRestaurants.length,
                        itemBuilder: (BuildContext context, int index) {

                          //Get the key-values from savedRestaurantsMap
                          String key = savedRestaurants.keys.elementAt(index);
                          List<dynamic> value = savedRestaurants.values.elementAt(index);

                          print(key);
                          print(value);

                          return ListTile(
                            title: Text(
                              value[0].toString() ?? '',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            subtitle: Text(
                              value[1].toString() ?? '',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            trailing: ElevatedButton(
                              child: Text(
                                'View',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () {
                                //View Restaurant details
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RestaurantPage(placesId: key),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.orange,
                                onPrimary: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24.0),),
                                backgroundColor: Colors.orange,
                              ),),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontFamily: 'Roboto',
                        ),
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ]
          ),
        ),


      ),
    );
  }
}
