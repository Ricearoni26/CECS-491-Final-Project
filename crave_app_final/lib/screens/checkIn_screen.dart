import 'dart:convert';
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

  @override
  Widget build(BuildContext context) {
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
        // leading: IconButton(
        //   icon: Icon(
        //     Icons.arrow_back_ios,
        //     color: Colors.white,
        //   ),
        //   onPressed: () {},
        // ),
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
                              // TODO: implement leave review button functionality
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => RestaurantReviewPage(restaurant: result)),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                primary: Colors.orange,
                                onPrimary: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24.0),)
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

            ],
          ),
        ),
      ),
    );
  }
}
