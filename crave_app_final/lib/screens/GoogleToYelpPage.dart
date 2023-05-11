import 'dart:convert';
import 'package:crave_app_final/apiKeys.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:animated_text_kit/animated_text_kit.dart';


class RestaurantPage extends StatefulWidget {
  final String placesId;

  RestaurantPage({Key? key, required this.placesId}) : super(key: key);

  @override
  _RestaurantPageState createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  final places = GoogleMapsPlaces(apiKey: googleMapsAPIKey);
  late Future<PlacesDetailsResponse> restaurantDetailsFuture;
  Map<String, dynamic>? restaurant;
  late PageController _sliderController;
  List<dynamic>? _reviews = [];
  int check = 1;
  bool _hasYelpReviews = false;
  late String generatedResponse;
  bool _generatedGpt = false;
  late Map<String, dynamic> yelpdata = {};

  @override
  void initState() {
    super.initState();
    _sliderController = PageController(initialPage: 0);
    restaurantDetailsFuture = getRestaurantDetails();
    getYelpReviews();

  }

  Future<PlacesDetailsResponse> getRestaurantDetails() async {
    final response = await places.getDetailsByPlaceId(widget.placesId);
    if (response.status == "OK") {
      getGptResponse(response);
      return response;
    } else {
      throw Exception('Failed to load restaurant details');
    }
  }


  Future<String> _getYelpRating(String businessId) async {
    final String url = 'https://api.yelp.com/v3/businesses/$businessId';
    final headers = {'Authorization': 'Bearer $apiKey'};
    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to load Yelp rating');
    }
    final Map<String, dynamic> data = json.decode(response.body);
    return data['rating'].toString();
  }

  Future<void> getYelpReviews() async {
    final response = await places.getDetailsByPlaceId(widget.placesId);
    final String name = response.result.name;
    final String? formattedAddress = response.result.formattedAddress;
    final String? address = formattedAddress?.split(',')[0];
    final String? city = formattedAddress?.split(',')[1];
    final String? state = formattedAddress?.split(',')[2].split(' ')[1];
    final String url =
        'https://api.yelp.com/v3/businesses/matches?name=$name&address1=$address&city=$city&state=$state&country=US&limit=1&match_threshold=default';
    final headers = {'Authorization': 'Bearer $apiKey'};
    final response2 = await http.get(Uri.parse(url), headers: headers);
    if (response2.statusCode != 200) {
      throw Exception('Failed to load Yelp reviews');
    }
    final Map<String, dynamic> data = json.decode(response2.body);
    final List<dynamic> businesses = data['businesses'];
    final String businessId = businesses.first['id'];
    final String rating = await _getYelpRating(businessId);
    final String url2 = 'https://api.yelp.com/v3/businesses/$businessId/reviews';
    final response3 = await http.get(Uri.parse(url2), headers: headers);
    if (response3.statusCode != 200) {
      throw Exception('Failed to load Yelp reviews');
    }
    final Map<String, dynamic> reviewsData = json.decode(response3.body);
    final List<dynamic> reviews = reviewsData['reviews'];

    setState(() {
      yelpdata = {'rating': rating};
      _reviews = reviews.map((review) => YelpReview.fromJson(review)).toList();
      _hasYelpReviews = true;
    });
  }

  //Map of previous saved restaurants
  Map<dynamic, dynamic> previousSavedRestaurantsMap = {};

  //Get previous saved restaurants from Firebase
  Future<void> fetchSavedRestaurants() async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref('users/$uid/savedRestaurants');

    DatabaseEvent event = await databaseRef.once();
    setState(() {
      previousSavedRestaurantsMap = event.snapshot.value as Map<dynamic, dynamic>;
    });

  }

  //TODO: Implement unsave ability
  //Restaurants the User wants to save
  Future<void> storeSaveRestaurant(PlacesDetailsResponse restaurantDetails) async{

    FirebaseDatabase database = FirebaseDatabase.instance;
    final user = FirebaseAuth.instance.currentUser!;
    String UID = user.uid!;

    DatabaseReference ref = FirebaseDatabase.instance.ref('users').child(UID).child('savedRestaurants');

    Map<String, List<String> > savePlace = {};

    // Store name and Google Places ID
    String id = restaurantDetails.result.placeId.toString();
    String name = restaurantDetails.result.name.toString();
    String addy = restaurantDetails.result.vicinity.toString();
    savePlace[id] = [name, addy];

    //Remove saved restaurant if selected again
    if(previousSavedRestaurantsMap.containsKey(id))
    {

      ////Nullify previous stored values
      savePlace[id] = [];

    }


    //Update saved Restaurants
    await ref.update(savePlace);

    //await ref.set(checkInRest);
    print('storing place');

  }


  @override
  Widget build(BuildContext context) {

    //Get previous restaurants
    fetchSavedRestaurants();

    //Checks if restaurant is selected/has been saved to Firebase
    bool savedPlace = false;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Restaurant Details",
          style: TextStyle(
            fontFamily: 'Arial',
            color: Colors.black,
            fontSize: 24.0,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: FutureBuilder<PlacesDetailsResponse>(
        future: restaurantDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final restaurantDetails = snapshot.data!;

            //Check if restaurant was previously saved
            if(previousSavedRestaurantsMap.containsKey(restaurantDetails.result.id))
            {

              savedPlace = true;

            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        child: _buildImageGallery(restaurantDetails),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildName(restaurantDetails),
                            SizedBox(height: 8),
                            _buildAddress(restaurantDetails),
                            SizedBox(height: 8),
                            _buildRating(restaurantDetails, yelpdata),// _hasYelpReviews ? _buildRating2(yelpdata) : SizedBox(height: 0),
                            SizedBox(height: 8),
                            _buildDetails(context, restaurantDetails),
                            //SizedBox(height: 8),
                            //_buildOpeningHours(restaurantDetails),
                            SizedBox(height: 16),
                            if(_generatedGpt) _buildText(),
                            // SizedBox(height: 16),
                            // _buildWebsite(restaurantDetails),
                            SizedBox(height: 16),
                            _buildPhoneNumber(restaurantDetails),
                            SizedBox(height: 16),
                            _buildReviewsSection(restaurantDetails),
                            SizedBox(height: 16),
                            _buildWebsite(restaurantDetails),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () async {
                                // Handle the 'Save Restaurant' button press here
                                //TODO - allow unsave

                                //Store restaurant into saved
                                await storeSaveRestaurant(restaurantDetails);

                                //Notify User of update
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Updated!')));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: savedPlace ? Colors.greenAccent : Colors.orange,
                                side: BorderSide(color: Colors.black54), // Set the border color
                              ),
                              child: Center(
                                child: Text(
                                  savedPlace ? "Saved" : 'Save Restaurant',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Arial",
                                    fontSize: 23,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }


  Widget _buildYelpReviews() {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Yelp Reviews',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Arial',
            fontSize: 24.0,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        separatorBuilder: (BuildContext context, int index) => Divider(
          thickness: 1.0,
          height: 0.0,
          color: Colors.grey[300],
        ),
        itemCount: _reviews!.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      '${_reviews![index].user}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        fontFamily: 'Arial',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                Row(
                  children: <Widget>[
                    RatingBarIndicator(
                      rating: _reviews![index].rating.toDouble(),
                      itemCount: 5,
                      itemSize: 20.0,
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      '${_reviews![index].rating}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        fontFamily: 'Arial',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                Text(
                  _reviews![index].text,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: 'Arial',

                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> getGptResponse(PlacesDetailsResponse restaurantDetails) async {
    final response = await http.get(Uri.parse('http://127.0.0.1:5000/askgpt/'+"give me information about the restaurant ${restaurantDetails.result.name} which is in ${restaurantDetails.result.formattedAddress}"));
    //final response2 = await http.get(Uri.parse('http://127.0.0.1:5000/askgpt/'+" Whats the google rating and yelp rating for this restaurant ${restaurantDetails.result.name}"));
    setState(() {
      generatedResponse = response.body;  //+ response2.body;
      _generatedGpt = true;
    });
  }



  Widget _buildReviewsSection(PlacesDetailsResponse restaurantDetails) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildreviews(restaurantDetails),
              SizedBox(height: 16),
            ],
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if(_hasYelpReviews) _buildreviews2(),
              SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
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


  Widget _buildreviews2() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => _buildYelpReviews()),
          );
        },
        child: Text(
          'Yelp Reviews',
          style: TextStyle(
            fontFamily: 'Arial',
            fontWeight: FontWeight.bold,
            fontSize: 15.0,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          primary: Colors.orange,
          onPrimary: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
      ),
    );
  }

  Widget _buildName(PlacesDetailsResponse restaurantDetails) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        restaurantDetails.result.name,
        style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOpen(PlacesDetailsResponse restaurantDetails, VoidCallback onPressed) {
    if (restaurantDetails.result.openingHours != null && restaurantDetails.result.openingHours!.openNow != null) {
      bool isOpen = restaurantDetails.result.openingHours!.openNow;
      return TextButton(
        onPressed: onPressed,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 8),
            Icon(
              isOpen ? Icons.check_circle : Icons.cancel,
              color: isOpen ? Colors.green : Colors.red,
            ),
            SizedBox(width: 8),
            Text(
              isOpen ? "Open now" : "Closed now",
              style: TextStyle(
                fontFamily: 'arial',
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      );
    } else {
      return SizedBox(height: 0);
    }
  }





  Widget _buildImageGallery(PlacesDetailsResponse restaurantDetails) {
    List<Widget> imageWidgets = [];
    int totalImages = 0;

    PageController _sliderController = PageController(); // create PageController instance

    if (restaurantDetails.result.photos != null &&
        restaurantDetails.result.photos!.isNotEmpty) {
      totalImages = restaurantDetails.result.photos!.length;
      for (var i = 0; i < totalImages; i++) {
        String photoReference = restaurantDetails.result.photos![i]
            .photoReference;
        String photoUrl =
            'https://maps.googleapis.com/maps/api/place/photo?maxwidth=1000&photoreference=$photoReference&key=$googleMapsAPIKey';
        imageWidgets.add(
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (_sliderController != null) {
                if (details.primaryVelocity! > 0) {
                  _sliderController.previousPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                } else if (details.primaryVelocity! < 0) {
                  _sliderController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                }
              }
            },
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(photoUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      }
    } else {
      totalImages = 1;
      imageWidgets.add(
        Image.asset(
          'assets/images/no_image_available.png',
          fit: BoxFit.fill,
        ),
      );
    }

    return Container(
      height: 700, // Set the height to your desired value
      child: Stack(
        children: [
          Container(
            color: Colors.white,
            child: PageView(
              controller: _sliderController,
              // pass PageController instance to PageView
              children: imageWidgets,
            ),
          ),
          Positioned(
            bottom: 8,
            left: 16,
            child: Row(
              children: [
                Icon(Icons.image, size: 16),
                SizedBox(width: 8),
                Text(
                  '${_sliderController.hasClients ? _sliderController.page!
                      .toInt() + 1 : 1}/$totalImages',
                  style: TextStyle(
                    fontSize: 16,
                    //fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildAddress(PlacesDetailsResponse restaurantDetails) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.location_on,
          size: 24,
          color: Colors.black54,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            restaurantDetails.result.addressComponents[0].longName +
                ', ' +
                restaurantDetails.result.addressComponents[1].longName +
                ', ' +
                restaurantDetails.result.addressComponents[2].longName,
            style: TextStyle(
              fontSize: 18,
              //fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRating(PlacesDetailsResponse restaurantDetails, Map<String, dynamic> yelpdata) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.only(right: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Google Rating',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 24,
                      color: Colors.black54,
                    ),
                    SizedBox(width: 8),
                    Text(
                      restaurantDetails.result.rating.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Yelp Rating',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 24,
                      color: Colors.black54,
                    ),
                    SizedBox(width: 8),
                    _hasYelpReviews && yelpdata.isNotEmpty
                        ? Text(
                      yelpdata['rating'],
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    )
                        : Text(
                      'Not available',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildRating2(Map<String, dynamic>? yelpdata) {
    if (yelpdata != null) {
      final String rating = yelpdata['rating'].toString();
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 8),
          Text(
            "Yelp Rating: " + rating,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
        ],
      );
    } else {
      return SizedBox(height: 0);
    }
  }

  Widget _buildDetails(BuildContext context, PlacesDetailsResponse details) {
    return Column(
      children: [
        // ... other widgets here
        _buildOpen(
          details,
              () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    "Opening Hours",
                    style: TextStyle(
                      fontFamily: "Arial",
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  content: _buildOpeningHours(details),
                  actions: [
                    TextButton(
                      child: Text(
                        "Close",
                        style: TextStyle(
                          fontFamily: "Arial",
                          fontSize: 16.0,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }




  Widget _buildOpeningHours(PlacesDetailsResponse restaurantDetails) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.schedule,
          size: 24,
          color: Colors.black54,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: restaurantDetails.result.openingHours?.weekdayText
                ?.map((e) => Text(
              e,
              style: TextStyle(
                fontFamily: 'arial',
                fontSize: 18,
                color: Colors.black87,
              ),
            ))
                .toList() ??
                [],
          ),
        ),
      ],
    );
  }



  Widget _buildWebsite(PlacesDetailsResponse restaurantDetails) {
    return Row(
      children: [
        Expanded(
          child: TextButton.icon(
            onPressed: () async {
              if (await canLaunch(restaurantDetails.result.website ?? '')) {
                await launch(restaurantDetails.result.website!);
              }
            },
            icon: Icon(
              Icons.language,
              size: 24,
              color: Colors.white,
            ),
            label: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                "Website",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Arial',
                  color: Colors.white,
                ),
              ),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(color: Colors.orange),
                ),
              ),
              overlayColor: MaterialStateProperty.all<Color>(Colors.black12),
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildPhoneNumber(PlacesDetailsResponse restaurantDetails) {
    return GestureDetector(
      onTap: () {
        String num = restaurantDetails.result.formattedPhoneNumber.toString();
        num = num.replaceAll("-",'');
        num = num.replaceAll('(', '');
        num = num.replaceAll(')', '');
        num = num.replaceAll(' ', '');
        print(num);
        var url = Uri.parse("tel:$num");
        launchUrl(url);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.phone,
            size: 24,
            color: Colors.black54,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              restaurantDetails.result.formattedPhoneNumber ?? 'Not Available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

//   Widget _buildreviews(PlacesDetailsResponse restaurantDetails) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Icon(
//           Icons.phone,
//           size: 24,
//           color: Colors.black54,
//         ),
//         SizedBox(width: 8),
//         Expanded(
//           child: Text(
//             restaurantDetails.result.reviews[0].text ?? 'Not Available',
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.black87,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }


  Widget _buildtextreviews(List<Review> reviews) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Reviews',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        separatorBuilder: (BuildContext context, int index) => Divider(
          thickness: 1.0,
          height: 0.0,
          color: Colors.grey[300],
        ),
        itemCount: reviews.length,
        itemBuilder: (BuildContext context, int index) {
          final reviewTime = DateTime.fromMillisecondsSinceEpoch(
            reviews[index].time.toInt() * 1000,
            isUtc: true,
          );
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      '${reviews[index].authorName}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      '${DateFormat.yMd().add_jm().format(reviewTime)}',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                Row(
                  children: <Widget>[
                    RatingBarIndicator(
                      rating: reviews[index].rating.toDouble(),
                      itemCount: 5,
                      itemSize: 20.0,
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      '${reviews[index].rating}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                Text(
                  reviews[index].text,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }







  Widget _buildreviews(PlacesDetailsResponse restaurantDetails) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => _buildtextreviews(restaurantDetails.result.reviews)),
            ),
            child: Text(
              'Google Reviews',
              style: TextStyle(
                fontFamily: 'Arial',
                fontWeight: FontWeight.bold,
                fontSize: 15.0,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.orange,
              onPrimary: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
          ),
        ],
      ),
    );
  }



}

class YelpReview {
  final String id;
  final String text;
  final int rating;
  final String user;

  YelpReview({
    required this.id,
    required this.text,
    required this.rating,
    required this.user,
  });

  factory YelpReview.fromJson(Map<String, dynamic> json) {
    return YelpReview(
      id: json['id'],
      text: json['text'],
      rating: json['rating'],
      user: json['user']['name'],
    );
  }
}

