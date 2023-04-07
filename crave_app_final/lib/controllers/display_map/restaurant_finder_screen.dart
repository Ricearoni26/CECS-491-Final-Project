import 'package:crave_app_final/apiKeys.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

class RestaurantSearch extends StatefulWidget {
  final Position currentPosition;
  const RestaurantSearch({Key? key, required this.currentPosition}) : super(key: key);

  @override
  _RestaurantSearchState createState() => _RestaurantSearchState();
}

class _RestaurantSearchState extends State<RestaurantSearch> {
  late GoogleMapController _controller;
  GoogleMapsPlaces _placesApi = GoogleMapsPlaces(apiKey: googleMapsAPIKey);
  TextEditingController _searchController = TextEditingController();
  late String _currentQuery;
  List<Prediction> _predictions = [];
  PlaceDetails? _selectedPlace;
  late Position currentCameraPosition;

  @override
  void initState() {
    super.initState();
    currentCameraPosition = widget.currentPosition;
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }


  Future<void> _onSearch() async {
    final String query = _searchController.text;

    if (query.isEmpty) {
      setState(() {
        _predictions = [];
      });
      return;
    }

    final PlacesAutocompleteResponse response = await _placesApi.autocomplete(
      query,
      location: Location(lat: widget.currentPosition.latitude, lng: widget.currentPosition.longitude),
      radius: 50000,
    );

    if (response.isOkay) {
      final List<Prediction> predictions = response.predictions;

      // Get details for each prediction and calculate distance from current location
      final Iterable<PlaceDetails?> placeDetails = await Future.wait(predictions.map((prediction) async {
        final PlacesDetailsResponse detailsResponse = await _placesApi.getDetailsByPlaceId(prediction.placeId!);
        if (detailsResponse.isOkay) {
          return detailsResponse.result;
        } else {
          print("Get place details error: ${detailsResponse.errorMessage}");
          return null;
        }
      }).toList());

      final List<PlaceDetails> nonNullPlaceDetails = placeDetails.whereType<PlaceDetails>().toList();


      nonNullPlaceDetails.sort((b, a) {
        final double distanceToA = Geolocator.distanceBetween(
          widget.currentPosition.latitude,
          widget.currentPosition.longitude,
          a.geometry!.location.lat,
          a.geometry!.location.lng,
        );
        final double distanceToB = Geolocator.distanceBetween(
          widget.currentPosition.latitude,
          widget.currentPosition.longitude,
          b.geometry!.location.lat,
          b.geometry!.location.lng,
        );
        return distanceToA.compareTo(distanceToB);
      });

      setState(() {
        _predictions = placeDetails.map((place) => Prediction(description: place?.name, placeId: place?.placeId)).toList();
      });
    } else {
      print("Autocomplete error: ${response.errorMessage}");
    }
  }


  // Future<void> _onSearch() async {
  //   final String query = _searchController.text;
  //
  //   if (query.isEmpty) {
  //     setState(() {
  //       _predictions = [];
  //     });
  //     return;
  //   }
  //
  //   final PlacesAutocompleteResponse response = await _placesApi.autocomplete(
  //     query,
  //     location: Location(lat: widget.currentPosition.latitude, lng: widget.currentPosition.longitude),
  //     radius: 50000,
  //
  //   );
  //
  //   if (response.isOkay) {
  //     setState(() {
  //       _predictions = response.predictions;
  //       _predictions.sort((a, b) => a.distanceMeters!.compareTo(b.distanceMeters!));
  //     });
  //   } else {
  //     print("Autocomplete error: ${response.errorMessage}");
  //   }
  // }

  Future<void> _onPredictionTap(Prediction prediction) async {
    final PlacesDetailsResponse response = await _placesApi.getDetailsByPlaceId(prediction.placeId!);

    if (response.isOkay) {
      setState(() {
        _selectedPlace = response.result;
        _currentQuery = prediction.description!;
        _predictions = [];
      });

      final CameraUpdate cameraUpdate = CameraUpdate.newLatLng(LatLng(
        _selectedPlace!.geometry!.location.lat,
        _selectedPlace!.geometry!.location.lng,
      ));
      _controller.animateCamera(cameraUpdate);
    } else {
      print("Get place details error: ${response.errorMessage}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: LatLng(widget.currentPosition.latitude, widget.currentPosition.longitude), zoom: 10),
            markers: _selectedPlace != null && _selectedPlace!.geometry != null && _selectedPlace!.geometry?.location != null
                ? Set<Marker>.from([
              Marker(
                markerId: MarkerId(_selectedPlace!.placeId),
                position: LatLng(
                  _selectedPlace!.geometry!.location.lat,
                  _selectedPlace!.geometry!.location.lng,
                ),
                infoWindow: InfoWindow(
                  title: _selectedPlace!.name ?? '',
                  snippet: _selectedPlace!.formattedAddress ?? '',
                ),
              )
            ])
                : Set<Marker>(),
          ),
          Positioned(
            top: 40.0,
            left: 10.0,
            right: 10.0,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search for a restaurant",
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) => _onSearch(),
                    ),
                    SizedBox(height: 10.0),
                    if (_predictions.isNotEmpty)
                      ..._predictions.map((prediction) => ListTile(
                        title: Text(prediction.description ?? ''),
                        onTap: () => _onPredictionTap(prediction),
                      )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class _RestaurantSearchState extends State<RestaurantSearch> {
//   late GoogleMapController _controller;
//   GoogleMapsPlaces _placesApi = GoogleMapsPlaces(apiKey: googleMapsAPIKey);
//   TextEditingController _searchController = TextEditingController();
//   late String _currentQuery;
//   List<Prediction> _predictions = [];
//   PlaceDetails? _selectedPlace;
//   late Position currentCameraPosition;
//
//   @override
//   void initState() {
//     super.initState();
//     currentCameraPosition = widget.currentPosition;
//   }
//
//   void _onMapCreated(GoogleMapController controller) {
//     _controller = controller;
//   }
//
//   Future<void> _onSearch() async {
//     final String query = _searchController.text;
//
//     if (query.isEmpty) {
//       setState(() {
//         _predictions = [];
//       });
//       return;
//     }
//
//     final PlacesAutocompleteResponse response = await _placesApi.autocomplete(
//       query,
//       location: Location(lat: widget.currentPosition.latitude, lng: widget.currentPosition.longitude),
//       radius: 50000,
//     );
//
//     if (response.isOkay) {
//       setState(() {
//         _predictions = response.predictions;
//       });
//     } else {
//       print("Autocomplete error: ${response.errorMessage}");
//     }
//   }
//
//   Future<void> _onPredictionTap(Prediction prediction) async {
//     final PlacesDetailsResponse response = await _placesApi.getDetailsByPlaceId(prediction.placeId!);
//
//     if (response.isOkay) {
//       setState(() {
//         _selectedPlace = response.result;
//         _currentQuery = prediction.description!;
//         _predictions = [];
//       });
//
//       final CameraUpdate cameraUpdate = CameraUpdate.newLatLng(LatLng(
//         _selectedPlace!.geometry!.location.lat,
//         _selectedPlace!.geometry!.location.lng,
//       ));
//       _controller.animateCamera(cameraUpdate);
//     } else {
//       print("Get place details error: ${response.errorMessage}");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           GoogleMap(
//             onMapCreated: _onMapCreated,
//             initialCameraPosition: CameraPosition(target: LatLng(widget.currentPosition.latitude, widget.currentPosition.longitude), zoom: 10),
//             markers: _selectedPlace != null && _selectedPlace.geometry != null && _selectedPlace.geometry.location != null
//                 ? Set<Marker>.from([
//               Marker(
//                 markerId: MarkerId(_selectedPlace.placeId),
//                 position: LatLng(
//                   _selectedPlace.geometry!.location.lat,
//                   _selectedPlace.geometry!.location.lng,
//                 ),
//                 infoWindow: InfoWindow(
//                   title: _selectedPlace.name ?? '',
//                   snippet: _selectedPlace.formattedAddress ?? '',
//                 ),
//               )
//             ])
//                 : null,
//           ),
//           Positioned(
//             top: 40.0,
//             left: 10.0,
//             right: 10.0,
//             child: Card(
//               child: Padding(
//                 padding: EdgeInsets.all(10.0),
//                 child: Column(
//                   children: [
//                     TextField(
//                       controller: _searchController,
//                       decoration: InputDecoration(
//                         hintText: "Search for a restaurant",
//                         border: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
//                       ),
//                       onChanged: (value) {
//                         setState(() {
//                           _currentQuery = value;
//                         });
//                       },
//                       onSubmitted: (value) {
//                         _onSearch();
//                       },
//                     ),
//                     SizedBox(height: 10.0),
//                     ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: _predictions.length,
//                       itemBuilder: (context, index) {
//                         final prediction = _predictions[index];
//                         return ListTile(
//                           title: Text(prediction.description ?? ''),
//                           onTap: () {
//                             _onPredictionTap(prediction);
//                           },
//                         );
//                       },
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }



// import 'package:crave_app_final/apiKeys.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_webservice/places.dart';
//
// class RestaurantSearch extends StatefulWidget {
//   final Position currentPosition;
//   const RestaurantSearch({Key? key, required this.currentPosition}) : super(key: key);
//
//   @override
//   _RestaurantSearchState createState() => _RestaurantSearchState();
// }
//
// class _RestaurantSearchState extends State<RestaurantSearch> {
//   late GoogleMapController _controller;
//   GoogleMapsPlaces _placesApi = GoogleMapsPlaces(apiKey: googleMapsAPIKey);
//   TextEditingController _searchController = TextEditingController();
//   late String _currentQuery;
//   List<Prediction> _predictions = [];
//   late PlaceDetails _selectedPlace;
//   late Position currentCameraPosition;
//
//   @override
//   void initState() {
//     super.initState();
//     currentCameraPosition = widget.currentPosition;
//   }
//
//   void _onMapCreated(GoogleMapController controller) {
//     _controller = controller;
//   }
//
//   Future<void> _onSearch() async {
//     final String query = _searchController.text;
//
//     if (query.isEmpty) {
//       setState(() {
//         _predictions = [];
//       });
//       return;
//     }
//
//     final PlacesAutocompleteResponse response = await _placesApi.autocomplete(
//       query,
//       location: Location(lat: widget.currentPosition.latitude, lng: widget.currentPosition.latitude),
//       radius: 50000,
//     );
//
//     if (response.isOkay) {
//       setState(() {
//         _predictions = response.predictions;
//       });
//     } else {
//       print("Autocomplete error: ${response.errorMessage}");
//     }
//   }
//
//   Future<void> _onPredictionTap(Prediction prediction) async {
//     final PlacesDetailsResponse response = await _placesApi.getDetailsByPlaceId(prediction.placeId!);
//
//     if (response.isOkay) {
//       setState(() {
//         _selectedPlace = response.result;
//         _currentQuery = prediction.description!;
//         _predictions = [];
//       });
//
//       final CameraUpdate cameraUpdate = CameraUpdate.newLatLng(LatLng(
//         _selectedPlace.geometry!.location.lat,
//         _selectedPlace.geometry!.location.lng,
//       ));
//       _controller.animateCamera(cameraUpdate);
//     } else {
//       print("Get place details error: ${response.errorMessage}");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Stack(
//           children: [
//           GoogleMap(
//           onMapCreated: _onMapCreated,
//           initialCameraPosition: CameraPosition(target: LatLng(37.7749, -122.4194), zoom: 10),
//           markers: _selectedPlace != null && _selectedPlace.geometry != null && _selectedPlace.geometry.location != null
//               ? Set<Marker>.from([
//             Marker(
//               markerId: MarkerId(_selectedPlace.placeId),
//               position: LatLng(
//                 _selectedPlace.geometry!.location.lat,
//                 _selectedPlace.geometry!.location.lng,
//               ),
//               infoWindow: InfoWindow(
//                 title: _selectedPlace.name,
//                 snippet: _selectedPlace.formattedAddress,
//               ),
//             )
//           ])?
//               : null,
//         );
//         Positioned(
//             top: 40.0,
//             left: 10.0,
//             right: 10.0,
//             child: Card(
//             child: Padding(
//             padding: EdgeInsets.all(10.0),
//         child: Column(
//           children: [
//           TextField(
//           controller: _searchController,
//           decoration: InputDecoration(
//             hintText: "Search for a restaurant",
//             border: InputBorder.none,
//             suffixIcon: IconButton(
//               icon: Icon(Icons.search),
//               onPressed: _onSearch,
//             ),
//           ),
//         ),
//         SizedBox(height: 10.0),
//         if (_predictions.isNotEmpty)
//     Container(
//         height: 200.0,
//         child: ListView.builder(
//         itemCount: _predictions.length,
//         itemBuilder: (context, index) {
//       final prediction = _predictions[index];
//       return ListTile(
//             title: Text(prediction.description!),
//             onTap: () => _onPredictionTap(prediction),
//           );
//         },
//         ),
//     ),
//           ],
//         ),
//             ),
//             ),
//         ),
//           ],
//         ),
//     );
//   }
// }
//
//
//
//
// // import 'dart:async';
// // import 'package:crave_app_final/apiKeys.dart';
// // import 'package:flutter/material.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // import 'package:google_maps_webservice/places.dart';
// // import 'package:location/location.dart' as location;
// //
// // class RestaurantSearchPage extends StatefulWidget {
// //   @override
// //   _RestaurantSearchPageState createState() => _RestaurantSearchPageState();
// // }
// //
// // class _RestaurantSearchPageState extends State<RestaurantSearchPage> {
// //   final _searchController = TextEditingController();
// //   final _placesController = Completer<GoogleMapController>();
// //   final _placesApi = GoogleMapsPlaces(apiKey: googleMapsAPIKey);
// //   final _locationApi = location.Location();
// //
// //   String _currentQuery = '';
// //   List<Prediction> _predictions = [];
// //   PlaceDetails? _selectedPlace;
// //   LatLng? _currentLocation;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _getLocation();
// //   }
// //
// //   Future<void> _getLocation() async {
// //     final locationData = await _locationApi.getLocation();
// //     _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Stack(
// //         children: [
// //           GoogleMap(
// //             onMapCreated: (controller) {
// //               _placesController.complete(controller);
// //             },
// //             initialCameraPosition: CameraPosition(
// //               target: _currentLocation ?? const LatLng(37.7749, -122.4194),
// //               zoom: 14,
// //             ),
// //             markers: Set.of(
// //               _selectedPlace == null
// //                   ? []
// //                   : [
// //                 Marker(
// //                   markerId: MarkerId(_selectedPlace!.placeId),
// //                   position: LatLng(_selectedPlace!.geometry!.location.lat, _selectedPlace!.geometry!.location.lng),
// //                   infoWindow: InfoWindow(title: _selectedPlace!.name),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           Positioned(
// //             top: 50,
// //             left: 10,
// //             right: 10,
// //             child: Container(
// //               height: 60,
// //               decoration: BoxDecoration(
// //                 color: Colors.white,
// //                 borderRadius: BorderRadius.circular(30),
// //               ),
// //               child: Row(
// //                 children: [
// //                   IconButton(
// //                     icon: Icon(Icons.arrow_back),
// //                     onPressed: () {
// //                       setState(() {
// //                         _currentQuery = '';
// //                         _predictions = [];
// //                       });
// //                       _searchController.clear();
// //                     },
// //                   ),
// //                   Expanded(
// //                     child: TextField(
// //                       controller: _searchController,
// //                       decoration: InputDecoration(
// //                         hintText: "Search for a restaurant",
// //                         border: InputBorder.none,
// //                       ),
// //                       onChanged: (value) async {
// //                         if (value.isEmpty) {
// //                           setState(() {
// //                             _currentQuery = '';
// //                             _predictions = [];
// //                           });
// //                           return;
// //                         }
// //
// //                         final result = await _placesApi.autocomplete(
// //                           value,
// //                           location: Location(lat: _currentLocation!.latitude, lng: _currentLocation!.longitude),
// //                           language: "en",
// //                           types: ["restaurant"],
// //                         );
// //
// //                         setState(() {
// //                           _currentQuery = value;
// //                           _predictions = result.predictions;
// //                         });
// //                       },
// //                     ),
// //                   ),
// //                   IconButton(
// //                     icon: Icon(Icons.search),
// //                     onPressed: () async {
// //                       if (_selectedPlace != null) {
// //                         final controller = await _placesController.future;
// //                         controller.animateCamera(
// //                           CameraUpdate.newLatLng(LatLng(_selectedPlace!.geometry!.location.lat, _selectedPlace!.geometry!.location.lng)),
// //                         );
// //                       }
// //                     },
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //           Positioned(
// //             top: 120,
// //             left: 10,
// //             right: 10,
// //             bottom: 10,
// //             child: _buildSearchResults(),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildSearchResults() {
// //     if (_currentQuery == '') {
// //       return ListView.builder(
// //         itemCount: _predictions.length,
// //         itemBuilder: (context, index) {
// //           final prediction = _predictions[index];
// //           return ListTile(
// //             title: Text(prediction.description!),
// //             onTap: () async {
// //               final placeDetails = await _placesApi.getDetailsByPlaceId(
// //                   prediction.placeId!);
// //               setState(() {
// //                 _selectedPlace = placeDetails.result;
// //                 _currentQuery = prediction.description!;
// //                 _predictions = [];
// //               });
// //             },
// //           );
// //         },
// //       );
// //     }
// //
// //     return Container();
// //   }
// // }
// //
// //
// //
// // // import 'dart:convert';
// // // import 'dart:async';
// // // import 'package:crave_app_final/apiKeys.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // // import 'package:http/http.dart' as http;
// // //
// // // const apiKey = googleMapsAPIKey;
// // //
// // // Future<List<dynamic>> searchPlaces(String query) async {
// // //   final url =
// // //       "https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=$apiKey";
// // //   final response = await http.get(Uri.parse(url));
// // //
// // //   if (response.statusCode == 200) {
// // //     final data = jsonDecode(response.body);
// // //     final results = data["results"] as List<dynamic>;
// // //     return results;
// // //   } else {
// // //     throw Exception("Failed to search places");
// // //   }
// // // }
// // //
// // // LatLng getLatLng(dynamic place) {
// // //   final location = place["geometry"]["location"];
// // //   final lat = location["lat"];
// // //   final lng = location["lng"];
// // //   return LatLng(lat, lng);
// // // }
// // //
// // // class RestaurantSearchPage extends StatefulWidget {
// // //   @override
// // //   _RestaurantSearchPageState createState() => _RestaurantSearchPageState();
// // // }
// // //
// // // class _RestaurantSearchPageState extends State<RestaurantSearchPage> {
// // //   final _searchController = TextEditingController();
// // //   final _mapController = Completer<GoogleMapController>();
// // //   List<dynamic> _places = [];
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: TextField(
// // //           controller: _searchController,
// // //           decoration: InputDecoration(
// // //             hintText: "Search for a restaurant",
// // //             border: InputBorder.none,
// // //           ),
// // //           onSubmitted: (value) async {
// // //             final results = await searchPlaces(value);
// // //             setState(() {
// // //               _places = results;
// // //             });
// // //           },
// // //         ),
// // //       ),
// // //       body: Stack(
// // //         children: [
// // //           GoogleMap(
// // //             onMapCreated: (controller) {
// // //               _mapController.complete(controller);
// // //             },
// // //             initialCameraPosition: CameraPosition(
// // //               target: LatLng(37.7749, -122.4194),
// // //               zoom: 12,
// // //             ),
// // //             markers: Set<Marker>.of(_places.map(
// // //                   (place) => Marker(
// // //                 markerId: MarkerId(place["place_id"]),
// // //                 position: getLatLng(place),
// // //                 infoWindow: InfoWindow(
// // //                   title: place["name"],
// // //                 ),
// // //               ),
// // //             )),
// // //           ),
// // //           Positioned(
// // //             bottom: 16,
// // //             left: 16,
// // //             right: 16,
// // //             child: Container(
// // //               height: 150,
// // //               child: ListView.builder(
// // //                 itemCount: _places.length,
// // //                 scrollDirection: Axis.horizontal,
// // //                 itemBuilder: (context, index) {
// // //                   final place = _places[index];
// // //                   return GestureDetector(
// // //                     onTap: () async {
// // //                       await navigateToRestaurant(place);
// // //                     },
// // //                     child: Card(
// // //                       child: Container(
// // //                         width: 200,
// // //                         child: Column(
// // //                           crossAxisAlignment: CrossAxisAlignment.start,
// // //                           children: [
// // //                             Text(
// // //                               place["name"],
// // //                               style: TextStyle(
// // //                                 fontWeight: FontWeight.bold,
// // //                               ),
// // //                             ),
// // //                             SizedBox(height: 8),
// // //                             Text(place["formatted_address"]),
// // //                             SizedBox(height: 8),
// // //                             Text(place["rating"].toString()),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   );
// // //                 },
// // //               ),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   Future<void> navigateToRestaurant(dynamic place) async {
// // //     final latLng = getLatLng(place);
// // //     final controller = await _mapController.future;
// // //     controller.animateCamera(CameraUpdate.newLatLng(latLng));
// // //   }
// // // }
// // //
// // //
// // //
// // //
// // //
// // //
// // //
// // //
// // //
// // //
// // //
// // // // import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
// // // // import 'package:crave_app_final/apiKeys.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter_google_places/flutter_google_places.dart';
// // // // import 'package:geolocator/geolocator.dart';
// // // // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // // // import 'package:google_maps_webservice/places.dart';
// // // // import 'package:google_api_headers/google_api_headers.dart';
// // // // import 'dart:async';
// // // //
// // // //
// // // // class SearchPlacesScreen extends StatefulWidget {
// // // //   final Position currentPosition;
// // // //   const SearchPlacesScreen({Key? key, required this.currentPosition}) : super(key: key);
// // // //
// // // //   @override
// // // //   State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
// // // // }
// // // //
// // // // final homeScaffoldKey = GlobalKey<ScaffoldState>();
// // // //
// // // // class _SearchPlacesScreenState extends State<SearchPlacesScreen> {
// // // //   late CameraPosition initialCameraPosition;
// // // //   Set<Marker> markersList = {};
// // // //   late GoogleMapController googleMapController;
// // // //   final Mode _mode = Mode.overlay;
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       key: homeScaffoldKey,
// // // //       appBar: AppBar(
// // // //         title: const Text("Temp Search Map"),
// // // //       ),
// // // //       body: Stack(
// // // //         children: [
// // // //           GoogleMap(
// // // //             myLocationButtonEnabled: false,
// // // //             initialCameraPosition: CameraPosition(
// // // //               target: LatLng(
// // // //                   widget.currentPosition.latitude,
// // // //                   widget.currentPosition.longitude
// // // //               ),
// // // //               zoom: 14.4,
// // // //             ),
// // // //             markers: markersList,
// // // //             mapType: MapType.normal,
// // // //             onMapCreated: (GoogleMapController controller) {
// // // //               googleMapController = controller;
// // // //             },
// // // //           ),
// // // //           Align(
// // // //             alignment: Alignment.topRight,
// // // //               child: ElevatedButton(
// // // //                   onPressed: _handlePressButton,
// // // //                   child: const Text("Search Places",
// // // //                   style: TextStyle(color: Colors.white),))
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Future<void> _handlePressButton() async {
// // // //     Prediction? p = await PlacesAutocomplete.show(
// // // //         context: context,
// // // //         apiKey: googleMapsAPIKey,
// // // //         onError: onError,
// // // //         mode: _mode,
// // // //         language: 'en',
// // // //         strictbounds: false,
// // // //         types: [""],
// // // //         decoration: InputDecoration(
// // // //             hintText: 'Search',
// // // //             focusedBorder: OutlineInputBorder(
// // // //                 borderRadius: BorderRadius.circular(20),
// // // //                 borderSide: BorderSide(color: Colors.white))
// // // //         ),
// // // //         components: [Component(Component.country,"usa")]);
// // // //
// // // //
// // // //     displayPrediction(p!,homeScaffoldKey.currentState);
// // // //   }
// // // //
// // // //   void onError(PlacesAutocompleteResponse response){
// // // //
// // // //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
// // // //       elevation: 0,
// // // //       behavior: SnackBarBehavior.floating,
// // // //       backgroundColor: Colors.transparent,
// // // //       content: AwesomeSnackbarContent(
// // // //         title: 'Message',
// // // //         message: response.errorMessage!,
// // // //         contentType: ContentType.failure,
// // // //       ),
// // // //     ));
// // // //
// // // //     // homeScaffoldKey.currentState!.showSnackBar(SnackBar(content: Text(response.errorMessage!)));
// // // //   }
// // // //
// // // //   Future<void> displayPrediction(Prediction p, ScaffoldState? currentState) async {
// // // //
// // // //     GoogleMapsPlaces places = GoogleMapsPlaces(
// // // //         apiKey: googleMapsAPIKey,
// // // //         apiHeaders: await const GoogleApiHeaders().getHeaders()
// // // //     );
// // // //
// // // //     PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);
// // // //
// // // //     final lat = detail.result.geometry!.location.lat;
// // // //     final lng = detail.result.geometry!.location.lng;
// // // //
// // // //     markersList.clear();
// // // //     markersList.add(Marker(
// // // //         markerId: const MarkerId("0"),
// // // //         position: LatLng(lat, lng),
// // // //         infoWindow: InfoWindow(
// // // //             title: detail.result.name
// // // //         )));
// // // //
// // // //     setState(() {});
// // // //
// // // //     googleMapController.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0));
// // // //
// // // //   }
// // // // }
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // // // import 'package:crave_app_final/apiKeys.dart';
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:flutter_google_places/flutter_google_places.dart';
// // // // // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // // // // import 'package:google_maps_webservice/places.dart' show GoogleMapsPlaces, PlacesAutocompleteResponse, Prediction;
// // // // // import 'dart:async';
// // // // //
// // // // // class RestaurantSearch extends StatefulWidget {
// // // // //   @override
// // // // //   _RestaurantSearchState createState() => _RestaurantSearchState();
// // // // // }
// // // // //
// // // // // class _RestaurantSearchState extends State<RestaurantSearch> {
// // // // //   final Completer<GoogleMapController> _controller = Completer();
// // // // //   final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: googleMapsAPIKey);
// // // // //   final TextEditingController _searchController = TextEditingController();
// // // // //   List<Prediction> _placesList = [];
// // // // //   final LatLng _center = LatLng(0, 0); // San Francisco coordinates
// // // // //   String _errorMessage = '';
// // // // //
// // // // //   @override
// // // // //   void dispose() {
// // // // //     _searchController.dispose();
// // // // //     super.dispose();
// // // // //   }
// // // // //
// // // // //   void _onMapCreated(GoogleMapController controller) {
// // // // //     _controller.complete(controller);
// // // // //   }
// // // // //
// // // // //   void _onSearchTextChanged(String text) async {
// // // // //     if (text.isEmpty) {
// // // // //       setState(() {
// // // // //         _placesList = [];
// // // // //       });
// // // // //       return;
// // // // //     }
// // // // //
// // // // //     PlacesAutocompleteResponse response = await _places.autocomplete(text, language: "en");
// // // // //
// // // // //     if (response.errorMessage?.isNotEmpty == true ||
// // // // //         response.status == "REQUEST_DENIED") {
// // // // //       setState(() {
// // // // //         _errorMessage = response.errorMessage!;
// // // // //       });
// // // // //       return;
// // // // //     }
// // // // //
// // // // //     setState(() {
// // // // //       _errorMessage = '';
// // // // //       _placesList = response.predictions;
// // // // //     });
// // // // //   }
// // // // //
// // // // //
// // // // //   void _onPlaceSelected(PlacesAutocompleteResponse result) async {
// // // // //     final GoogleMapController controller = await _controller.future;
// // // // //     controller.animateCamera(CameraUpdate.newLatLng(result.location));
// // // // //
// // // // //     setState(() {
// // // // //       _searchController.text = result.description;
// // // // //       _placesList = [];
// // // // //     });
// // // // //   }
// // // // //
// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Scaffold(
// // // // //       appBar: AppBar(
// // // // //         title: TextField(
// // // // //           controller: _searchController,
// // // // //           decoration: const InputDecoration(
// // // // //             hintText: 'Search for a restaurant...',
// // // // //             border: InputBorder.none,
// // // // //           ),
// // // // //           onChanged: _onSearchTextChanged,
// // // // //         ),
// // // // //       ),
// // // // //       body: Stack(
// // // // //         children: [
// // // // //           GoogleMap(
// // // // //             onMapCreated: _onMapCreated,
// // // // //             initialCameraPosition: CameraPosition(
// // // // //               target: _center,
// // // // //               zoom: 10.0,
// // // // //             ),
// // // // //             markers: _placesList
// // // // //                 .map((result) => Marker(
// // // // //               markerId: MarkerId(result.placeId),
// // // // //               position: LatLng(result.geometry!.location.lat,
// // // // //                   result.geometry!.location.lng),
// // // // //               onTap: () {
// // // // //                 _onPlaceSelected(result);
// // // // //               },
// // // // //             ))
// // // // //                 .toSet(),
// // // // //           ),
// // // // //           if (_errorMessage.isNotEmpty)
// // // // //             Center(
// // // // //               child: Text(_errorMessage),
// // // // //             ),
// // // // //           if (_placesList.isNotEmpty)
// // // // //             Positioned(
// // // // //               top: kToolbarHeight + 10,
// // // // //               left: 0.0,
// // // // //               right: 0.0,
// // // // //               child: Container(
// // // // //                 height: 200.0,
// // // // //                 decoration: BoxDecoration(
// // // // //                   color: Colors.white,
// // // // //                   borderRadius: BorderRadius.circular(10.0),
// // // // //                   boxShadow: [
// // // // //                     BoxShadow(
// // // // //                       color: Colors.black.withOpacity(0.3),
// // // // //                       blurRadius: 5.0,
// // // // //                       spreadRadius: 2.0,
// // // // //                     ),
// // // // //                   ],
// // // // //                 ),
// // // // //                 child: ListView.builder(
// // // // //                   itemCount: _placesList.length,
// // // // //                   itemBuilder: (context, index) {
// // // // //                     PlacesAutocompleteResult result = _placesList[index];
// // // // //                     return ListTile(
// // // // //                       title: Text(result.name),
// // // // //                       subtitle: Text(result.formattedAddress ?? ''),
// // // // //                       onTap: () {
// // // // //                         _onPlaceSelected(result);
// // // // //                       },
// // // // //                     );
// // // // //                   },
// // // // //                 ),
// // // // //               ),
// // // // //             ),
// // // // //         ],
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // // // import 'package:crave_app_final/apiKeys.dart';
// // // // // // import 'package:flutter/material.dart';
// // // // // // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // // // // // import 'package:google_maps_webservice/places.dart';
// // // // // // import 'dart:async';
// // // // // //
// // // // // // class RestaurantSearch extends StatefulWidget {
// // // // // //   @override
// // // // // //   _RestaurantSearchState createState() => _RestaurantSearchState();
// // // // // // }
// // // // // //
// // // // // // class _RestaurantSearchState extends State<RestaurantSearch> {
// // // // // //   final Completer<GoogleMapController> _controller = Completer();
// // // // // //   final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: googleMapsAPIKey);
// // // // // //   final TextEditingController _searchController = TextEditingController();
// // // // // //   List<PlacesSearchResult> _placesList = [];
// // // // // //   LatLng _center = LatLng(37.7749, -122.4194); // San Francisco coordinates
// // // // // //   String _errorMessage = '';
// // // // // //
// // // // // //   @override
// // // // // //   void dispose() {
// // // // // //     _searchController.dispose();
// // // // // //     super.dispose();
// // // // // //   }
// // // // // //
// // // // // //   void _onMapCreated(GoogleMapController controller) {
// // // // // //     _controller.complete(controller);
// // // // // //   }
// // // // // //
// // // // // //   void _onSearchTextChanged(String text) async {
// // // // // //     if (text.isEmpty) {
// // // // // //       setState(() {
// // // // // //         _placesList = [];
// // // // // //       });
// // // // // //       return;
// // // // // //     }
// // // // // //
// // // // // //     PlacesAutocompleteResponse response =
// // // // // //     await _places.autocomplete(text, language: "en");
// // // // // //
// // // // // //     if (response.errorMessage?.isNotEmpty == true ||
// // // // // //         response.status == "REQUEST_DENIED") {
// // // // // //       setState(() {
// // // // // //         _errorMessage = response.errorMessage!;
// // // // // //       });
// // // // // //       return;
// // // // // //     }
// // // // // //
// // // // // //     setState(() {
// // // // // //       _errorMessage = '';
// // // // // //       _placesList = response.results;
// // // // // //     });
// // // // // //   }
// // // // // //
// // // // // //   void _onPlaceSelected(PlacesSearchResult result) async {
// // // // // //     final GoogleMapController controller = await _controller.future;
// // // // // //     controller.animateCamera(CameraUpdate.newLatLng(result.geometry.location));
// // // // // //
// // // // // //     setState(() {
// // // // // //       _searchController.text = result.name;
// // // // // //       _placesList = [];
// // // // // //     });
// // // // // //   }
// // // // // //
// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     return Scaffold(
// // // // // //       appBar: AppBar(
// // // // // //         title: TextField(
// // // // // //           controller: _searchController,
// // // // // //           decoration: const InputDecoration(
// // // // // //             hintText: 'Search for a restaurant...',
// // // // // //             border: InputBorder.none,
// // // // // //           ),
// // // // // //           onChanged: _onSearchTextChanged,
// // // // // //         ),
// // // // // //       ),
// // // // // //       body: Stack(
// // // // // //         children: [
// // // // // //           GoogleMap(
// // // // // //             onMapCreated: _onMapCreated,
// // // // // //             initialCameraPosition: CameraPosition(
// // // // // //               target: _center,
// // // // // //               zoom: 10.0,
// // // // // //             ),
// // // // // //             markers: _placesList
// // // // // //                 .map((result) =>
// // // // // //                 Marker(
// // // // // //                   markerId: MarkerId(result.placeId),
// // // // // //                   position: LatLng(
// // // // // //                       result.geometry!.location.lat,
// // // // // //                       result.geometry!.location.lng),
// // // // // //                   onTap: () {
// // // // // //                     _onPlaceSelected(result);
// // // // // //                   },
// // // // // //                 ))
// // // // // //                 .toSet(),
// // // // // //           ),
// // // // // //           if (_errorMessage.isNotEmpty)
// // // // // //             Center(
// // // // // //               child: Text(_errorMessage),
// // // // // //             ),
// // // // // //           if (_placesList.isNotEmpty)
// // // // // //             Positioned(
// // // // // //               top: kToolbarHeight + 10,
// // // // // //               left: 0.0,
// // // // // //               right: 0.0,
// // // // // //               child: Container(
// // // // // //                 height: 200.0,
// // // // // //                 decoration: BoxDecoration(
// // // // // //                   color: Colors.white,
// // // // // //                   borderRadius: BorderRadius.circular(10.0),
// // // // // //                   boxShadow: [
// // // // // //                     BoxShadow(
// // // // // //                       color: Colors.black.withOpacity(0.3),
// // // // // //                       blurRadius: 5.0,
// // // // // //                       spreadRadius: 2.0,
// // // // // //                     ),
// // // // // //                   ],
// // // // // //                 ),
// // // // // //                 child: ListView.builder(
// // // // // //                   itemCount: _placesList.length,
// // // // // //                   itemBuilder: (context, index) {
// // // // // //                     PlacesSearchResult result = _placesList[index];
// // // // // //                     return ListTile(
// // // // // //                       title: Text(result.name),
// // // // // //                       subtitle: Text(result.formattedAddress ?? ''),
// // // // // //                       onTap: () {
// // // // // //                         _onPlaceSelected(result);
// // // // // //                       },
// // // // // //                     );
// // // // // //                   },
// // // // // //                 ),
// // // // // //               ),
// // // // // //             ),
// // // // // //         ],
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // // }
// // // // // //
// // // // // //
// // // // // //
// // // // // // // import 'dart:async';
// // // // // // //
// // // // // // // import 'package:flutter/material.dart';
// // // // // // // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // // // // // // import 'package:google_maps_webservice/places.dart';
// // // // // // //
// // // // // // // class RestaurantFinder extends StatefulWidget {
// // // // // // //   @override
// // // // // // //   _RestaurantFinderState createState() => _RestaurantFinderState();
// // // // // // // }
// // // // // // //
// // // // // // // class _RestaurantFinderState extends State<RestaurantFinder> {
// // // // // // //   late GoogleMapController _mapController;
// // // // // // //   late LatLng _restaurantLocation;
// // // // // // //   final Completer<GoogleMapController> _mapControllerCompleter = Completer();
// // // // // // //   final Set<Marker> _markers = {};
// // // // // // //   final TextEditingController _searchController = TextEditingController();
// // // // // // //   late List<PlacesSearchResult> _placesList;
// // // // // // //
// // // // // // //   @override
// // // // // // //   void initState() {
// // // // // // //     super.initState();
// // // // // // //     _restaurantLocation = LatLng(37.4219999, -122.0840575); // default location
// // // // // // //     _placesList = [];
// // // // // // //   }
// // // // // // //
// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context) {
// // // // // // //     return Scaffold(
// // // // // // //       appBar: AppBar(
// // // // // // //         title: Text('Restaurant Finder'),
// // // // // // //         backgroundColor: Colors.red,
// // // // // // //       ),
// // // // // // //       body: Stack(
// // // // // // //         children: [
// // // // // // //           GoogleMap(
// // // // // // //             initialCameraPosition:
// // // // // // //             CameraPosition(target: _restaurantLocation, zoom: 15),
// // // // // // //             onMapCreated: (GoogleMapController controller) {
// // // // // // //               _mapControllerCompleter.complete(controller);
// // // // // // //               _mapController = controller;
// // // // // // //             },
// // // // // // //             markers: _markers,
// // // // // // //           ),
// // // // // // //           Positioned(
// // // // // // //             top: 10,
// // // // // // //             left: 10,
// // // // // // //             right: 10,
// // // // // // //             child: Container(
// // // // // // //               color: Colors.white,
// // // // // // //               child: TextField(
// // // // // // //                 controller: _searchController,
// // // // // // //                 decoration: InputDecoration(
// // // // // // //                   hintText: 'Search for a restaurant',
// // // // // // //                   contentPadding: EdgeInsets.symmetric(horizontal: 16),
// // // // // // //                 ),
// // // // // // //                 onChanged: _onSearchChanged,
// // // // // // //               ),
// // // // // // //             ),
// // // // // // //           ),
// // // // // // //           if (_placesList.isNotEmpty)
// // // // // // //             Positioned(
// // // // // // //               top: 70,
// // // // // // //               left: 10,
// // // // // // //               right: 10,
// // // // // // //               child: Container(
// // // // // // //                 height: 200,
// // // // // // //                 color: Colors.white,
// // // // // // //                 child: ListView.builder(
// // // // // // //                   itemCount: _placesList.length,
// // // // // // //                   itemBuilder: (context, index) {
// // // // // // //                     final place = _placesList[index];
// // // // // // //                     return ListTile(
// // // // // // //                       title: Text(place.name),
// // // // // // //                       subtitle: Text(place.formattedAddress ?? ''),
// // // // // // //                       onTap: () => _onPlaceSelected(place),
// // // // // // //                     );
// // // // // // //                   },
// // // // // // //                 ),
// // // // // // //               ),
// // // // // // //             ),
// // // // // // //         ],
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }
// // // // // // //
// // // // // // //   void _onSearchChanged(String input) async {
// // // // // // //     if (input.isEmpty) {
// // // // // // //       setState(() {
// // // // // // //         _placesList.clear();
// // // // // // //       });
// // // // // // //       return;
// // // // // // //     }
// // // // // // //
// // // // // // //     final places = GoogleMapsPlaces(apiKey: 'YOUR_API_KEY_HERE');
// // // // // // //     PlacesAutocompleteResponse response =
// // // // // // //     await places.autocomplete(input, types: ['establishment']);
// // // // // // //
// // // // // // //     if (response.errorMessage?.isNotEmpty == true ||
// // // // // // //         response.status == 'REQUEST_DENIED') {
// // // // // // //       print('Autocomplete error: ${response.errorMessage}');
// // // // // // //       return;
// // // // // // //     }
// // // // // // //
// // // // // // //     if (response.predictions.isNotEmpty) {
// // // // // // //       List<PlacesSearchResult> searchResults = [];
// // // // // // //
// // // // // // //       for (var prediction in response.predictions) {
// // // // // // //         PlacesDetailsResponse details =
// // // // // // //         await places.getDetailsByPlaceId(prediction.placeId);
// // // // // // //
// // // // // // //         if (details.result.geometry?.location != null) {
// // // // // // //           searchResults.add(details.result);
// // // // // // //         }
// // // // // // //       }
// // // // // // //
// // // // // // //       searchResults.sort((a, b) {
// // // // // // //         double distanceA = _calculateDistance(
// // // // // // //             a.geometry!.location.lat, a.geometry!.location.lng);
// // // // // // //         double distanceB = _calculateDistance(
// // // // // // //             b.geometry!.location.lat, b.geometry!.location.lng);
// // // // // // //         return distanceA.compareTo(distanceB);
// // // // // // //       });
// // // // // // //
// // // // // // //       setState(() {
// // // // // // //         _placesList = searchResults;
// // // // // // //       });
// // // // // // //     }
// // // // // // //   }
// // // // // // // }
// // // // // // //
