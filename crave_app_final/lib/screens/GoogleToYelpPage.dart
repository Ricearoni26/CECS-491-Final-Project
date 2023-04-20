import 'dart:convert';
import 'package:crave_app_final/apiKeys.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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

  @override
  void initState() {
    super.initState();
    _sliderController = PageController(initialPage: 0);
    restaurantDetailsFuture = getRestaurantDetails();
  }


  Future<PlacesDetailsResponse> getRestaurantDetails() async {
    final response = await places.getDetailsByPlaceId(widget.placesId);
    final String url =
        'https://api.yelp.com/v3/businesses/matches?name=${response.result.name}&address1=${response.result.formattedAddress?.split(',')[0]}&city=${response.result.formattedAddress?.split(',')[1]}&state=${response.result.formattedAddress?.split(',')[2].split(' ')[1]}&country=US&limit=1&match_threshold=default';
    final headers = {'Authorization': 'Bearer $apiKey'};
    final response2 = await http
        .get(Uri.parse(url), headers: {'Authorization': 'Bearer $apiKey'});

    if (response.status == "OK") {
      final Map<String, dynamic> data = json.decode(response2.body);
      final List<dynamic> businesses = data['businesses'];
      if (businesses.isNotEmpty) {
        final Map<String, dynamic> business = businesses.first;
        restaurant = business;
      }
      return response;
    } else {
      throw Exception('Failed to load restaurant details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<PlacesDetailsResponse>(
        future: restaurantDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final restaurantDetails = snapshot.data!;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200.0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildImageGallery(restaurantDetails),
                    centerTitle: true,
                    title: Text(
                      restaurantDetails.result.name,
                      style: TextStyle(
                        fontFamily: 'Arial', // use custom font
                        color: Colors.white,
                        fontSize: 24.0, // increase font size
                        //fontWeight: FontWeight.bold, // make it bold
                        letterSpacing: 1.5, // add some letter spacing
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withOpacity(0.5),
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        _buildAddress(restaurantDetails),
                        SizedBox(height: 8),
                        _buildRating(restaurantDetails),
                        SizedBox(height: 8),
                        _buildOpeningHours(restaurantDetails),
                        SizedBox(height: 16),
                        _buildWebsite(restaurantDetails),
                        SizedBox(height: 16),
                        _buildPhoneNumber(restaurantDetails),
                        SizedBox(height: 16),
                        _buildreviews(restaurantDetails),
                        SizedBox(height: 16),
                      ],
                    ),
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

  Widget _buildSliverAppBar(PlacesDetailsResponse restaurantDetails) {
    return SliverAppBar(
      expandedHeight: 200.0,
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(
          'https://maps.googleapis.com/maps/api/place/photo?maxwidth=1000&photoreference=${restaurantDetails.result.photos[0].photoReference}&key=${googleMapsAPIKey}' ??
              '',
          fit: BoxFit.cover,
        ),
        centerTitle: true,
        title: Text(
          restaurantDetails.result.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery(PlacesDetailsResponse restaurantDetails) {
    List<Widget> imageWidgets = [];
    int totalImages = 0;

    PageController _sliderController = PageController(); // create PageController instance

    if (restaurantDetails.result.photos != null &&
        restaurantDetails.result.photos!.isNotEmpty) {
      totalImages = restaurantDetails.result.photos!.length;
      for (var i = 0; i < totalImages; i++) {
        String photoReference = restaurantDetails.result.photos![i].photoReference;
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
          fit: BoxFit.cover,
        ),
      );
    }

    return Stack(
      children: [
        Container(
          color: Colors.white,
          child: PageView(
            controller: _sliderController, // pass PageController instance to PageView
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
                '${_sliderController.hasClients ? _sliderController.page!.toInt() + 1 : 1}/$totalImages',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
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
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRating(PlacesDetailsResponse restaurantDetails) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildOpeningHours(PlacesDetailsResponse restaurantDetails) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.public,
          size: 24,
          color: Colors.black54,
        ),
        SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              if (await canLaunch(restaurantDetails.result.website ?? '')) {
                await launch(restaurantDetails.result.website!);
              }
            },
            child: Text(
              restaurantDetails.result.website ?? 'Not Available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneNumber(PlacesDetailsResponse restaurantDetails) {
    return Row(
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
    );
  }

  Widget _buildreviews(PlacesDetailsResponse restaurantDetails) {
    return Row(
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
            restaurantDetails.result.reviews[0].text ?? 'Not Available',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

