import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:crave_app_final/apiKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'dart:async';


class SearchPlacesScreen extends StatefulWidget {
  final Position currentPosition;
  const SearchPlacesScreen({Key? key, required this.currentPosition}) : super(key: key);

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

final homeScaffoldKey = GlobalKey<ScaffoldState>();

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {
  //Position? currentPosition;
  late CameraPosition initialCameraPosition;
  Set<Marker> markersList = {};
  late GoogleMapController googleMapController;
  final Mode _mode = Mode.overlay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: homeScaffoldKey,
      appBar: AppBar(
        title: const Text("Google Search Places"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                  widget.currentPosition.latitude,
                  widget.currentPosition.longitude
              ),
              zoom: 14.4,
            ),
            markers: markersList,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              googleMapController = controller;
            },
          ),
          ElevatedButton(onPressed: _handlePressButton, child: const Text("Search Places"))
        ],
      ),
    );
  }

  Future<void> _handlePressButton() async {
    Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: googleMapsAPIKey,
        onError: onError,
        mode: _mode,
        language: 'en',
        strictbounds: false,
        types: [""],
        decoration: InputDecoration(
            hintText: 'Search',
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.white))
        ),
        components: [Component(Component.country,"usa")]);


    displayPrediction(p!,homeScaffoldKey.currentState);
  }

  void onError(PlacesAutocompleteResponse response){

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Message',
        message: response.errorMessage!,
        contentType: ContentType.failure,
      ),
    ));

    // homeScaffoldKey.currentState!.showSnackBar(SnackBar(content: Text(response.errorMessage!)));
  }

  Future<void> displayPrediction(Prediction p, ScaffoldState? currentState) async {

    GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: googleMapsAPIKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders()
    );

    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);

    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;

    markersList.clear();
    markersList.add(Marker(markerId: const MarkerId("0"),position: LatLng(lat, lng),infoWindow: InfoWindow(title: detail.result.name)));

    setState(() {});

    googleMapController.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0));

  }
}


// import 'package:crave_app_final/apiKeys.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_google_places/flutter_google_places.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_webservice/places.dart' show GoogleMapsPlaces, PlacesAutocompleteResponse, Prediction;
// import 'dart:async';
//
// class RestaurantSearch extends StatefulWidget {
//   @override
//   _RestaurantSearchState createState() => _RestaurantSearchState();
// }
//
// class _RestaurantSearchState extends State<RestaurantSearch> {
//   final Completer<GoogleMapController> _controller = Completer();
//   final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: googleMapsAPIKey);
//   final TextEditingController _searchController = TextEditingController();
//   List<Prediction> _placesList = [];
//   final LatLng _center = LatLng(0, 0); // San Francisco coordinates
//   String _errorMessage = '';
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   void _onMapCreated(GoogleMapController controller) {
//     _controller.complete(controller);
//   }
//
//   void _onSearchTextChanged(String text) async {
//     if (text.isEmpty) {
//       setState(() {
//         _placesList = [];
//       });
//       return;
//     }
//
//     PlacesAutocompleteResponse response = await _places.autocomplete(text, language: "en");
//
//     if (response.errorMessage?.isNotEmpty == true ||
//         response.status == "REQUEST_DENIED") {
//       setState(() {
//         _errorMessage = response.errorMessage!;
//       });
//       return;
//     }
//
//     setState(() {
//       _errorMessage = '';
//       _placesList = response.predictions;
//     });
//   }
//
//
//   void _onPlaceSelected(PlacesAutocompleteResponse result) async {
//     final GoogleMapController controller = await _controller.future;
//     controller.animateCamera(CameraUpdate.newLatLng(result.location));
//
//     setState(() {
//       _searchController.text = result.description;
//       _placesList = [];
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: TextField(
//           controller: _searchController,
//           decoration: const InputDecoration(
//             hintText: 'Search for a restaurant...',
//             border: InputBorder.none,
//           ),
//           onChanged: _onSearchTextChanged,
//         ),
//       ),
//       body: Stack(
//         children: [
//           GoogleMap(
//             onMapCreated: _onMapCreated,
//             initialCameraPosition: CameraPosition(
//               target: _center,
//               zoom: 10.0,
//             ),
//             markers: _placesList
//                 .map((result) => Marker(
//               markerId: MarkerId(result.placeId),
//               position: LatLng(result.geometry!.location.lat,
//                   result.geometry!.location.lng),
//               onTap: () {
//                 _onPlaceSelected(result);
//               },
//             ))
//                 .toSet(),
//           ),
//           if (_errorMessage.isNotEmpty)
//             Center(
//               child: Text(_errorMessage),
//             ),
//           if (_placesList.isNotEmpty)
//             Positioned(
//               top: kToolbarHeight + 10,
//               left: 0.0,
//               right: 0.0,
//               child: Container(
//                 height: 200.0,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10.0),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.3),
//                       blurRadius: 5.0,
//                       spreadRadius: 2.0,
//                     ),
//                   ],
//                 ),
//                 child: ListView.builder(
//                   itemCount: _placesList.length,
//                   itemBuilder: (context, index) {
//                     PlacesAutocompleteResult result = _placesList[index];
//                     return ListTile(
//                       title: Text(result.name),
//                       subtitle: Text(result.formattedAddress ?? ''),
//                       onTap: () {
//                         _onPlaceSelected(result);
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
//
//
//
//
//
// // import 'package:crave_app_final/apiKeys.dart';
// // import 'package:flutter/material.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // import 'package:google_maps_webservice/places.dart';
// // import 'dart:async';
// //
// // class RestaurantSearch extends StatefulWidget {
// //   @override
// //   _RestaurantSearchState createState() => _RestaurantSearchState();
// // }
// //
// // class _RestaurantSearchState extends State<RestaurantSearch> {
// //   final Completer<GoogleMapController> _controller = Completer();
// //   final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: googleMapsAPIKey);
// //   final TextEditingController _searchController = TextEditingController();
// //   List<PlacesSearchResult> _placesList = [];
// //   LatLng _center = LatLng(37.7749, -122.4194); // San Francisco coordinates
// //   String _errorMessage = '';
// //
// //   @override
// //   void dispose() {
// //     _searchController.dispose();
// //     super.dispose();
// //   }
// //
// //   void _onMapCreated(GoogleMapController controller) {
// //     _controller.complete(controller);
// //   }
// //
// //   void _onSearchTextChanged(String text) async {
// //     if (text.isEmpty) {
// //       setState(() {
// //         _placesList = [];
// //       });
// //       return;
// //     }
// //
// //     PlacesAutocompleteResponse response =
// //     await _places.autocomplete(text, language: "en");
// //
// //     if (response.errorMessage?.isNotEmpty == true ||
// //         response.status == "REQUEST_DENIED") {
// //       setState(() {
// //         _errorMessage = response.errorMessage!;
// //       });
// //       return;
// //     }
// //
// //     setState(() {
// //       _errorMessage = '';
// //       _placesList = response.results;
// //     });
// //   }
// //
// //   void _onPlaceSelected(PlacesSearchResult result) async {
// //     final GoogleMapController controller = await _controller.future;
// //     controller.animateCamera(CameraUpdate.newLatLng(result.geometry.location));
// //
// //     setState(() {
// //       _searchController.text = result.name;
// //       _placesList = [];
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: TextField(
// //           controller: _searchController,
// //           decoration: const InputDecoration(
// //             hintText: 'Search for a restaurant...',
// //             border: InputBorder.none,
// //           ),
// //           onChanged: _onSearchTextChanged,
// //         ),
// //       ),
// //       body: Stack(
// //         children: [
// //           GoogleMap(
// //             onMapCreated: _onMapCreated,
// //             initialCameraPosition: CameraPosition(
// //               target: _center,
// //               zoom: 10.0,
// //             ),
// //             markers: _placesList
// //                 .map((result) =>
// //                 Marker(
// //                   markerId: MarkerId(result.placeId),
// //                   position: LatLng(
// //                       result.geometry!.location.lat,
// //                       result.geometry!.location.lng),
// //                   onTap: () {
// //                     _onPlaceSelected(result);
// //                   },
// //                 ))
// //                 .toSet(),
// //           ),
// //           if (_errorMessage.isNotEmpty)
// //             Center(
// //               child: Text(_errorMessage),
// //             ),
// //           if (_placesList.isNotEmpty)
// //             Positioned(
// //               top: kToolbarHeight + 10,
// //               left: 0.0,
// //               right: 0.0,
// //               child: Container(
// //                 height: 200.0,
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(10.0),
// //                   boxShadow: [
// //                     BoxShadow(
// //                       color: Colors.black.withOpacity(0.3),
// //                       blurRadius: 5.0,
// //                       spreadRadius: 2.0,
// //                     ),
// //                   ],
// //                 ),
// //                 child: ListView.builder(
// //                   itemCount: _placesList.length,
// //                   itemBuilder: (context, index) {
// //                     PlacesSearchResult result = _placesList[index];
// //                     return ListTile(
// //                       title: Text(result.name),
// //                       subtitle: Text(result.formattedAddress ?? ''),
// //                       onTap: () {
// //                         _onPlaceSelected(result);
// //                       },
// //                     );
// //                   },
// //                 ),
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// //
// //
// // // import 'dart:async';
// // //
// // // import 'package:flutter/material.dart';
// // // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // // import 'package:google_maps_webservice/places.dart';
// // //
// // // class RestaurantFinder extends StatefulWidget {
// // //   @override
// // //   _RestaurantFinderState createState() => _RestaurantFinderState();
// // // }
// // //
// // // class _RestaurantFinderState extends State<RestaurantFinder> {
// // //   late GoogleMapController _mapController;
// // //   late LatLng _restaurantLocation;
// // //   final Completer<GoogleMapController> _mapControllerCompleter = Completer();
// // //   final Set<Marker> _markers = {};
// // //   final TextEditingController _searchController = TextEditingController();
// // //   late List<PlacesSearchResult> _placesList;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _restaurantLocation = LatLng(37.4219999, -122.0840575); // default location
// // //     _placesList = [];
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: Text('Restaurant Finder'),
// // //         backgroundColor: Colors.red,
// // //       ),
// // //       body: Stack(
// // //         children: [
// // //           GoogleMap(
// // //             initialCameraPosition:
// // //             CameraPosition(target: _restaurantLocation, zoom: 15),
// // //             onMapCreated: (GoogleMapController controller) {
// // //               _mapControllerCompleter.complete(controller);
// // //               _mapController = controller;
// // //             },
// // //             markers: _markers,
// // //           ),
// // //           Positioned(
// // //             top: 10,
// // //             left: 10,
// // //             right: 10,
// // //             child: Container(
// // //               color: Colors.white,
// // //               child: TextField(
// // //                 controller: _searchController,
// // //                 decoration: InputDecoration(
// // //                   hintText: 'Search for a restaurant',
// // //                   contentPadding: EdgeInsets.symmetric(horizontal: 16),
// // //                 ),
// // //                 onChanged: _onSearchChanged,
// // //               ),
// // //             ),
// // //           ),
// // //           if (_placesList.isNotEmpty)
// // //             Positioned(
// // //               top: 70,
// // //               left: 10,
// // //               right: 10,
// // //               child: Container(
// // //                 height: 200,
// // //                 color: Colors.white,
// // //                 child: ListView.builder(
// // //                   itemCount: _placesList.length,
// // //                   itemBuilder: (context, index) {
// // //                     final place = _placesList[index];
// // //                     return ListTile(
// // //                       title: Text(place.name),
// // //                       subtitle: Text(place.formattedAddress ?? ''),
// // //                       onTap: () => _onPlaceSelected(place),
// // //                     );
// // //                   },
// // //                 ),
// // //               ),
// // //             ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   void _onSearchChanged(String input) async {
// // //     if (input.isEmpty) {
// // //       setState(() {
// // //         _placesList.clear();
// // //       });
// // //       return;
// // //     }
// // //
// // //     final places = GoogleMapsPlaces(apiKey: 'YOUR_API_KEY_HERE');
// // //     PlacesAutocompleteResponse response =
// // //     await places.autocomplete(input, types: ['establishment']);
// // //
// // //     if (response.errorMessage?.isNotEmpty == true ||
// // //         response.status == 'REQUEST_DENIED') {
// // //       print('Autocomplete error: ${response.errorMessage}');
// // //       return;
// // //     }
// // //
// // //     if (response.predictions.isNotEmpty) {
// // //       List<PlacesSearchResult> searchResults = [];
// // //
// // //       for (var prediction in response.predictions) {
// // //         PlacesDetailsResponse details =
// // //         await places.getDetailsByPlaceId(prediction.placeId);
// // //
// // //         if (details.result.geometry?.location != null) {
// // //           searchResults.add(details.result);
// // //         }
// // //       }
// // //
// // //       searchResults.sort((a, b) {
// // //         double distanceA = _calculateDistance(
// // //             a.geometry!.location.lat, a.geometry!.location.lng);
// // //         double distanceB = _calculateDistance(
// // //             b.geometry!.location.lat, b.geometry!.location.lng);
// // //         return distanceA.compareTo(distanceB);
// // //       });
// // //
// // //       setState(() {
// // //         _placesList = searchResults;
// // //       });
// // //     }
// // //   }
// // // }
// // //
