import 'dart:convert';
import 'dart:ffi';
import 'package:crave_app_final/screens/ProfilePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import '../apiKeys.dart';
import 'RestaurantReviewPage.dart';

class CheckIn extends StatefulWidget {
  const CheckIn({Key? key}) : super(key: key);

  @override
  State<CheckIn> createState() => _CheckInState();
}

class _CheckInState extends State<CheckIn> {

  Future<List<String>> getRestaurantInfo(String location) async {
    // final String apiKey2 = apiKey;
    final String url =
        'https://api.yelp.com/v3/businesses/search?location=$location';

    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $apiKey',
    });

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
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


  Future<PlacesSearchResponse> fetchRestaurants() async {
    // Request permission to access the device's location
    var permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      // Retrieve the device's current location
      var position = await Geolocator.getCurrentPosition();
      if (position != null) {
        final places = GoogleMapsPlaces(apiKey: googleMapsAPIKey);
        double latitude = position.latitude;
        double longitude = position.longitude;
        final location = Location(lat: latitude, lng: longitude);
        final result = await places.searchNearbyWithRadius(
          location,
          3000, // radius in meters
          type: 'restaurant',
        );
        if (result.status == "OK") {
          return result;
        } else {
          print('Search failed with status: ${result.status}.');
        }
      }
    } else {
      print('Location permission denied');
    }
    // Return an empty PlacesSearchResponse object if there was an error
    return PlacesSearchResponse(status: "ERROR", results: []);
  }


  //Map<dynamic, dynamic> getCheckInMap = {};
  Map<String, String> getCheckInMap = {};

  Future<void> fetchCheckIn() async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref('users/$uid/checkIns');

    DatabaseEvent event = await databaseRef.once();
    setState(() {
      getCheckInMap = event.snapshot.value as Map<String, String>;
    });
    //data = event.snapshot.value as Map<dynamic, dynamic>;
    //arrayData = event.snapshot.value;
  }

  List visitedRest = [];
  Map<String, String> checkInRest = {};


  @override
  Widget build(BuildContext context) {
    fetchCheckIn();
    //List<String> newList = List.from(getCheckInMap);
    print("check in:");
    print(getCheckInMap);
    checkInRest = getCheckInMap;


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        title: Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            'Check-In',
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
              FutureBuilder<PlacesSearchResponse>(
                future: fetchRestaurants(),
                builder: (BuildContext context,
                    AsyncSnapshot<PlacesSearchResponse> snapshot) {
                  if (snapshot.hasData) {
                    final restaurants = snapshot.data!.results;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: 8,
                      itemBuilder: (BuildContext context, int index) {
                        final result = restaurants[index];
                        return ListTile(
                          title: Text(
                            result.name ?? '',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          subtitle: Text(
                            result.vicinity ?? '',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          trailing: ElevatedButton(
                            child: Text(
                              'Check-In',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold,
                               ),
                            ),
                            onPressed: () {
                              // TODO: store restaurant info
                              //print(result.placeId);

                              String realId = result.id.toString();
                              print('id'+ realId);

                              String id = result.placeId.toString();
                              String name = result.name.toString();
                              visitedRest.add('test');
                              checkInRest[name] = id;
                              //checkInRest[result.name] = result.id!;
                              //checkInRest[result.name] = result.formattedAddress!;
                              //visitedRest.add(result.name);
                              //visitedRest.add((result.formattedAddress))
                              //result.
                              print('Here');


                            },
                            style: ElevatedButton.styleFrom(
                                primary: Colors.orange,
                                onPrimary: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24.0),),
                                //TODO: CHANGE COLOR ON SELECT
                                //backgroundColor: isSelected ? Colors.greenAccent : Colors.orange,
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
              SizedBox(height: 20.0),
              ElevatedButton(onPressed: (){
                storeCheckIn();

                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage() ) );
              },
                child:
                  Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  ),
              )



            ],
          ),
        ),
      ),



    );


  }

  //Store Check-in into firebase
  Future storeCheckIn() async{
    FirebaseDatabase database = FirebaseDatabase.instance;
    final user = FirebaseAuth.instance.currentUser!;
    String UID = user.uid!;

    DatabaseReference ref = FirebaseDatabase.instance.ref('users').child(UID).child('checkIns');

    //Update check-ins
    await ref.update(checkInRest);
    //await ref.set(checkInRest);
    print('storing');

  }


}
