import 'dart:async';
import 'package:crave_app_final/apiKeys.dart';
import 'package:crave_app_final/controllers/display_map/map_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

class RestaurantFinder extends StatefulWidget {
  @override
  _RestaurantFinderState createState() => _RestaurantFinderState();
}

class _RestaurantFinderState extends State<RestaurantFinder> {
  late GoogleMapController _mapController;
  late String _searchTerm;
  late LatLng _restaurantLocation;
  final Completer<GoogleMapController> _mapControllerCompleter = Completer();
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _restaurantLocation = LatLng(37.4219999, -122.0840575); // default location
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Align(
          alignment: Alignment.bottomLeft,
            child: Text(
              'On the Road',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
                fontFamily: 'Roboto',
              ),
            ),
        ),
        backgroundColor: Colors.orange,
      ),
      body: Stack(
        children: [
          GoogleMap(
            myLocationEnabled: true,
            initialCameraPosition:
            CameraPosition(target: _restaurantLocation, zoom: 15),
            onMapCreated: (GoogleMapController controller) {
              _mapControllerCompleter.complete(controller);
              _mapController = controller;
            },
            markers: _markers,
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,

            child: TextField(


              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: 'Search for a restaurant',
              ),
              onSubmitted: (String value) {
                setState(() {
                  _searchTerm = value;
                });
                _searchForRestaurant(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _searchForRestaurant(String restaurantName) async {
    final places = GoogleMapsPlaces(apiKey: googleMapsAPIKey);

    PlacesSearchResponse response = await places.searchByText(restaurantName);

    if (response.results.isNotEmpty) {
      PlacesDetailsResponse detailsResponse =
      await places.getDetailsByPlaceId(response.results.first.placeId);

      setState(() {
        _restaurantLocation = LatLng(
            detailsResponse.result.geometry!.location.lat,
            detailsResponse.result.geometry!.location.lng);
        _markers.clear();
        _markers.add(Marker(
            markerId: MarkerId(detailsResponse.result.name),
            position: _restaurantLocation,
            infoWindow: InfoWindow(title: detailsResponse.result.name)));
      });

      _moveCameraToRestaurant();
    }
  }

  void _moveCameraToRestaurant() async {
    final GoogleMapController controller = await _mapControllerCompleter.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: _restaurantLocation, zoom: 15)));
  }
}


// import 'package:crave_app_final/apiKeys.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_webservice/places.dart';
//
// class NavigationPage extends StatefulWidget {
//   final Position currentPosition;
//   const NavigationPage({Key? key, required this.currentPosition}) : super(key: key);
//
//   @override
//   _NavigationPageState createState() => _NavigationPageState();
// }
//
// class _NavigationPageState extends State<NavigationPage> {
//   late GoogleMapController mapController;
//   late LatLng _center;
//   late LatLng _destination;
//   Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
//   final TextEditingController _searchController = TextEditingController();
//   PlacesAutocompleteResponse? _searchResponse;
//   late String _errorMessage;
//
//   @override
//   void initState() {
//     super.initState();
//     //_destination = widget.destination;
//     _getCurrentLocation();
//   }
//
//   void _getCurrentLocation() async {
//
//     setState(() {
//       _center = LatLng(
//           widget.currentPosition.latitude,
//           widget.currentPosition.longitude);
//     });
//   }
//
//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//   }
//
//   void _onSearchTextChanged(String input) async {
//     if (input.isEmpty) {
//       setState(() {
//         _searchResponse = null;
//       });
//       return;
//     }
//
//     final places = GoogleMapsPlaces(apiKey: googleMapsAPIKey);
//
//     PlacesAutocompleteResponse response = await places.autocomplete(input);
//
//     if (response.errorMessage?.isNotEmpty == true) {
//       setState(() {
//         _errorMessage = response.errorMessage!;
//       });
//     } else {
//       setState(() {
//         _errorMessage = "";
//         _searchResponse = response;
//       });
//     }
//   }
//
//   void _onSearchItemSelected(String placeId) async {
//     final places = GoogleMapsPlaces(
//       apiKey: googleMapsAPIKey,
//     );
//
//     PlacesDetailsResponse response = await places.getDetailsByPlaceId(placeId);
//
//     double lat = response.result.geometry!.location.lat;
//     double lng = response.result.geometry!.location.lng;
//
//     setState(() {
//       _destination = LatLng(lat, lng);
//       markers.clear();
//       markers[MarkerId('destination')] = Marker(
//         markerId: MarkerId('destination'),
//         position: _destination,
//         infoWindow: InfoWindow(
//           title: response.result.name,
//           snippet: response.result.formattedAddress,
//         ),
//       );
//     });
//
//     mapController.animateCamera(CameraUpdate.newCameraPosition(
//       CameraPosition(
//         target: _destination,
//         zoom: 15,
//       ),
//     ));
//
//     Navigator.pop(context);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Navigation'),
//         backgroundColor: Colors.blue,
//         elevation: Theme
//             .of(context)
//             .platform == TargetPlatform.iOS ? 0.0 : 4.0,
//       ),
//       body: Stack(
//         children: <Widget>[
//           GoogleMap(
//             onMapCreated: _onMapCreated,
//             initialCameraPosition: CameraPosition(
//               target: _center,
//               zoom: 11,
//             ),
//             markers: Set<Marker>.of(markers.values),
//           ),
//           Positioned(
//             top: 20.0,
//             left: 0.0,
//             right: 0.0,
//             child: Container(
//               margin: EdgeInsets.symmetric(horizontal: 20.0),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10.0),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.5),
//                     spreadRadius: 1,
//                     blurRadius: 7,
//                     offset: Offset(0, 3), // changes position of shadow
//                   ),
//                 ],
//               ),
//               child: TextField(
//                 controller: _searchController,
//                 decoration: InputDecoration(
//                   hintText: 'Search for a location',
//                   contentPadding: EdgeInsets.all(10.0),
//                 ),
//                 onChanged: _onSearchTextChanged,
//               ),
//             ),
//           ),
//           Positioned(
//             top: 80.0,
//             left: 0.0,
//             right: 0.0,
//             bottom: 0.0,
//             child: _searchResponse != null
//                 ? ListView.builder(
//               itemCount: _searchResponse!.predictions.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   leading: Icon(Icons.location_on),
//                   title: Text(_searchResponse!.predictions[index].description!),
//                   onTap: () {
//                     _onSearchItemSelected(
//                         _searchResponse!.predictions[index].placeId!);
//                   },
//                 );
//               },
//             )
//                 : Container(),
//           ),
//           Positioned(
//             bottom: 20.0,
//             left: 20.0,
//             right: 20.0,
//             child: ElevatedButton(
//               child: const Text(
//                 "navigate",
//                 style: TextStyle(
//                   color: Colors.blue,
//                 ),
//
//                 ),
//               onPressed: () {
//                 // if (_destination != null) {
//                 //   Navigator.push(
//                 //     context,
//                 //     MaterialPageRoute(
//                 //       builder: (context) =>
//                 //           const NavigationPage(
//                 //             destination: _destination,
//                 //           ),
//                 //     ),
//                 //   );
//                 // }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }