import 'dart:async';
import 'package:crave_app_final/controllers/draw_map/draw_map_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import '../../apiKeys.dart';
import '../../screens/home_screen.dart';

final _places = GoogleMapsPlaces(apiKey: googleMapsAPIKey);

class MapScreen extends StatefulWidget {
  final Position currentPosition;
  const MapScreen({Key? key, required this.currentPosition}) : super(key: key);
  //const MapScreen({super.key});

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  CameraPosition? _currentCameraPosition;
  late LatLng _currentUserLocation;
  final List<Marker> _markers = [];
  bool _isMoving = false;
  late LatLng _center;
  Position? currentPosition;


  Future<void> _searchNearbyPlaces() async {
    final places = GoogleMapsPlaces(apiKey: googleMapsAPIKey);
    final location = Location(lat: _center.latitude, lng: _center.longitude);
    final result = await places.searchNearbyWithRankBy(
        location,
        "distance",
        type: 'restaurant');

    setState(() {
      _markers.addAll(result.results.map((restaurant) => Marker(
          markerId: MarkerId(restaurant.placeId),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure),
          position: LatLng(restaurant.geometry!.location.lat, restaurant.geometry!.location.lng),
          infoWindow: InfoWindow(
             title: restaurant.name,
             snippet:
             "Ratings: ${restaurant.rating?.toString() ?? "Not Rated"}\nPrice: ${restaurant.priceLevel?.toString()}"),
      )));
    });
  }

  void _clearMarkers() {
    setState(() {
      _markers.clear();
    });
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _isMoving = true;
      _center = position.target;

    });
  }

  void _onCameraIdle() {
    setState(() {
      _isMoving = false;
    });
  }

  _onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller.complete(controller);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  // void _search(String query) async {
  //   final response = await _places.searchNearbyWithRadius(
  //     Location(lat: _center.latitude, lng: _center.longitude),
  //     10000, // 10km
  //     type: query,
  //   );
  //   if (response.isOkay) {
  //     // handle search results
  //   } else {
  //     // handle error
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Align(
          //   alignment: Alignment.center,
          //   child: SizedBox(
          //     child: FloatingActionButton(
          //       heroTag: "draw button",
          //       onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          //       // onPressed: () {Navigator.pushReplacement(context, MaterialPageRoute(
          //       //   builder: (context) => const Drawer(),
          //       // ));},
          //       shape: const RoundedRectangleBorder(),
          //     ),
          //   ),
          // ),
          GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            initialCameraPosition: CameraPosition(
                target: LatLng(
                    widget.currentPosition.latitude,
                    widget.currentPosition.longitude
                ),
              zoom: 14.4,
            ),
            markers: Set.from(_markers),
            onMapCreated: _onMapCreated,
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(15, 50, 50, 0),
            child: LocationSearch()
            ),
          AnimatedOpacity(
            opacity: _isMoving ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 500),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 110, 20, 0),
              child: Align(
                alignment: Alignment.topRight,
                child: ElevatedButton(
                  onPressed: ()  {

                  },
                  child: const Text(
                    "Draw",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Arial",
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: _isMoving ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 500),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 110, 0, 0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ElevatedButton(
                    onPressed: () async {
                      _clearMarkers();
                      _searchNearbyPlaces();
                    },
                    child: const Text(
                        "Redo Search Area",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Arial",
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // child: FloatingActionButton(
            //
            //   heroTag: "draw button",
            //   onPressed: () {Navigator.pushReplacement(context, MaterialPageRoute(
            //     builder: (context) => const DrawMapController(),
            //   ));},
            //   shape: ShapeBorder.lerp(RoundedRectangleBorder(), RoundedRectangleBorder(), 10),
            // ),

        ],
      ),
    );
    // bottomSheet: showModalBottomSheet(
      //   child: ListView(
      //     children: <Widget>[
      //       Container(
      //         height: 200.0,
      //         child: ListView(
      //           scrollDirection: Axis.horizontal,
      //           children: List.generate(10, (int index) {
      //             return Card(
      //               color: Colors.blue[index * 100],
      //               child: SizedBox(
      //                 width: 100.0,
      //                 height: 100.0,
      //                 child: Text("$index"),
      //               ),
      //             );
      //           }),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),

      // Container(
      //   // color: Colors.black,
      //   child: Row(
      //
      //     children: [
      //         Column(
      //         )
      //     ],
      //   ),
      // ),
  }
}




//
//   late LatLng _userCurrentLocation;
//   late LatLng _screenPosition;
//   final Completer<GoogleMapController> _controller = Completer();
//
//   static const CameraPosition _initialCameraPosition = CameraPosition(
//     target: LatLng(33.7838, -118.1141),
//     zoom: 12,
//   );
//
//   LatLng? _searchLocation;
//
//
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }
//
//
//   // void onCameraMove(CameraPosition position) {
//   //   setState(() {
//   //     print("Started Moving");
//   //     _screenPosition = position.target;
//   //   });
//   // }
//
//
//   void onMapCreated(GoogleMapController controller) async {
//     _controller = controller;
//
//     // Get the current visible region of the map
//     LatLngBounds visibleRegion = await mapController.getVisibleRegion();
//
//     // Calculate the center point of the visible region
//     LatLng centerPoint = LatLng(
//       (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) / 2,
//       (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) / 2,
//     );
//
//     // Update the search location and UI accordingly
//     updateSearchLocation(centerPoint);
//   }
//
//
//   void _onCameraIdle() async {
//     GoogleMapController controller = await _controller.future;
//
//     LatLng centerLocation = await controller.getLatLng(ScreenCoordinate(
//       x: MediaQuery.of(context).size.width ~/ 2,
//       y: MediaQuery.of(context).size.height ~/ 2,
//     ));
//
//     setState(() {
//       _searchLocation = centerLocation;
//     });
//   }
//
//
//   Future<Position> _getCurrentLocation() async {
//     return await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SizedBox(
//         height: MediaQuery.of(context).size.height,
//         width: MediaQuery.of(context).size.width,
//         child: GoogleMap(
//           mapType: MapType.normal,
//           myLocationEnabled: true,
//           myLocationButtonEnabled: false,
//           initialCameraPosition: _initialCameraPosition,
//           onMapCreated: _onMapCreated
//         ),
//       ),
//       floatingActionButton: _searchLocation != null
//           ? FloatingActionButton(
//         onPressed: () {
//           // Do something with the search location
//         },
//         tooltip: 'Search',
//         child: const Icon(Icons.search),
//       )
//           : null,
//     );
//   }
// }







  // @override
  // void initState() {
  //   super.initState();
  //   _currentLocation = Geolocator.getCurrentPosition();
  //   _gpsLocation.startPositionStream(_configurePositionStream).catchError((e) {
  //     setState(() {
  //       _exception = e;
  //     });
  //   });
  // }

  // Future<void> _redoSearch() async {
  //   final GoogleMapController controller = await _controller.future;
  //   controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  // }

  // Future <void> _retrieveNearbyRestaurants(LatLng _currentLocation) async {
  //   // PlacesSearchResponse _response = await _places.searchNearbyWithRadius(
  //   //     Location(lat: _currentLocation.latitude, lng: _currentLocation.longitude),
  //   //     20000,
  //   //     type: "restaurant");
  //
  //   PlacesSearchResponse response2 = await _places.searchNearbyWithRankBy(
  //       Location(lat: _currentLocation.latitude, lng: _currentLocation.longitude),
  //       "distance",
  //       type: "restaurant");
  //
  //
  //   Iterable<Marker> restaurantMarkers = response2.results
  //       .map((result) =>
  //       Marker(
  //           markerId: MarkerId(result.name),
  //           icon: BitmapDescriptor.defaultMarkerWithHue(
  //               BitmapDescriptor.hueAzure),
  //           infoWindow:
  //
  //           InfoWindow(
  //             title: result.name,
  //             snippet: "Ratings: ${result.rating?.toString() ?? "Not Rated"}"
  //                 "\nPrice: ${result.priceLevel?.toString() ??
  //                 "No Price Data"}",
  //
  //             // add an Image widget to display the photo
  //             // make sure to replace YOUR_API_KEY with your actual API key
  //             // and set the width and height of the image
  //             // child: result.photos != null && result.photos.isNotEmpty
  //             //     ? Image.network(
  //             //   "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${result.photos![0].photoReference}&key=APIKey",
  //             //   width: 400,
  //             //   height: 300,
  //             // )
  //             //     : const Text("No Photo Available"),
  //           ),
  //           position: LatLng(
  //               result.geometry!.location.lat, result.geometry!.location.lng))).toSet();
  //
  //   setState(() {
  //     _markers.addAll(restaurantMarkers);
  //   });
  // }

  //   Iterable<Marker> _restaurantMarkers = _response2.results
  //       .map((result) => Marker(
  //       markerId: MarkerId(result.name),
  //       // Use an icon with different colors to differentiate between current location
  //       // and the restaurants
  //
  //       icon: BitmapDescriptor.defaultMarkerWithHue(
  //           BitmapDescriptor.hueAzure),
  //       infoWindow: InfoWindow(
  //         title: result.name,
  //         snippet: "Ratings: ${result.rating?.toString() ?? "Not Rated"}"
  //             "\nPrice: ${result.priceLevel?.toString() ?? "No Price Data"}",
  //             photoReference != null
  //           ? '<img src="https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=YOUR_API_KEY" width="400" height="300">'
  //           : "No Photo Available",
  //         // add an Image widget to display the photo
  //         // make sure to replace YOUR_API_KEY with your actual API key
  //         // and set the width and height of the image
  //
  //       ),
  //           //"Price: ${result.priceLevel?.toString() ?? "No Price Avaliable"}"),
  //       // position: LatLng(
  //       //      result.geometry!.location.lat, result.geometry!.location.lng)))
  //       position: LatLng(
  //           result.geometry!.location.lat, result.geometry!.location.lng)))
  //       .toSet();
  //
  //   setState(() {
  //     _markers.addAll(_restaurantMarkers);
  //   });
  // }

  // Future<void> _retrieveNearbyRestaurants(LatLng _userLocation) async {
  //   PlacesSearchResponse _response = await _places.searchNearbyWithRadius(
  //       Location(lat: _userLocation.latitude, lng: _userLocation.longitude),
  //       15000,
  //       type: "restaurant");
  //
  //   Set<Marker> _restaurantMarkers = _response.results
  //       .map((result) => Marker(
  //       markerId: MarkerId(result.name),
  //       // Use an icon with different colors to differentiate between current location
  //       // and the restaurants
  //       icon: BitmapDescriptor.defaultMarkerWithHue(
  //           BitmapDescriptor.hueAzure),
  //       infoWindow: InfoWindow(
  //           title: result.name,
  //           snippet:
  //           "Ratings: ${result.rating?.toString() ?? "Not Rated"}"),
  //       // position: LatLng(
  //       //      result.geometry!.location.lat, result.geometry!.location.lng)))
  //          position: LatLng(
  //               result.geometry!.location.lat, result.geometry!.location.lng)))
  //       .toSet();
  //
  //   setState(() {
  //     _markers.addAll(_restaurantMarkers);
  //   });
  // }
  // void _handlePressButton(Prediction p) async {
  //   if (p != null) {
  //     PlacesDetailsResponse detail =
  //     await _places.getDetailsByPlaceId(p.placeId.toString());
  //     var placeId = p.placeId;
  //     double lat = detail.result.geometry!.location.lat;
  //     double lng = detail.result.geometry!.location.lng;
  //     LatLng latLng = LatLng(lat, lng);
  //     mapController.animateCamera(
  //       CameraUpdate.newLatLng(latLng),
  //     );
  //     mapController.animateCamera(
  //       CameraUpdate.newLatLngZoom(latLng, 15.0),
  //     );
  //   }
  // }
  // void _getCurrentLocation() async {
  //   try {
  //     currentLocation = await locate.Location().getLocation();
  //     mapController.animateCamera(
  //       CameraUpdate.newCameraPosition(
  //         CameraPosition(
  //           target: LatLng(currentLocation.latitude!.toDouble(), currentLocation.longitude!.toDouble()),
  //           zoom: 14,
  //         ),
  //       ),
  //     );
  //   } on Exception catch (e) {
  //     print(e);
  //   }
  // }

  //Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//         future: _currentLocation,
//         builder: (BuildContext context, AsyncSnapshot snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             if (snapshot.hasData) {
//               // The user location returned from the snapshot
//               Position snapshotData = snapshot.data;
//               LatLng userLocation = LatLng(snapshotData.latitude, snapshotData.longitude);
//
//               if (_markers.isEmpty) {
//                 _retrieveNearbyRestaurants(userLocation);
//               }
//               return Scaffold(
//                   body: GoogleMap(
//                       onMapCreated:  (controller) => controller,
//                       myLocationEnabled: true,
//                       myLocationButtonEnabled: false,
//                       initialCameraPosition: CameraPosition(
//                         target: userLocation,
//                         zoom: 14,
//                       ),
//                       markers: _markers
//                     //  ..add(Marker(
//                     //       markerId: const MarkerId("User Location"),
//                     //       infoWindow: const InfoWindow(
//                     //           title: "User Location"),
//                     //       position: _userLocation)),
//                   ),
//                   floatingActionButton: FloatingActionButton(
//                       child: const Text("Redo Search"),
//                       onPressed: () {
//                         controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(userLocation.latitude, userLocation.longitude), 14));
//                         _retrieveNearbyRestaurants(userLocation);
//                       }
//                   )
//               );
//             } else {
//               //return const Center(child: Text("Failed to get user location!"));
//               return const GoogleMap(initialCameraPosition: CameraPosition(
//                   target: LatLng(33.7701, -118.1937),
//                   zoom: 12),
//               );
//             }
//           }
//           return const GoogleMap(initialCameraPosition: CameraPosition(
//               target: LatLng(33.7701, -118.1937),
//               zoom: 12),
//           );
//           return const Center(child: CircularProgressIndicator());
//         });
//   }
// }








// NOT WORKING VERSION BELOW: VERSION 2

//
// class MapControllerState extends State<MapController> {
//   final GPSLocation _gpsLocation = GPSLocation();
//
//
//   //final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
//
//   late final Future<Position> _currentLocation;
//   late final Set<Marker> _markers = {};
//
//   late GoogleMapsController controller;
//   late StreamSubscription<CameraPosition> subscription;
//   late CameraPosition position;
//
//   void _configurePositionStream(Position position) {
//     setState(() {
//       _userPosition = position;
//     });
//   }
//
//   Future<void> getMarkerPosition() async {
//     double screenWidth = MediaQuery.of(context).size.width *
//         MediaQuery.of(context).devicePixelRatio;
//     double screenHeight = MediaQuery.of(context).size.height *
//         MediaQuery.of(context).devicePixelRatio;
//     double middleX = screenWidth / 2;
//     double middleY = screenHeight / 2;
//     ScreenCoordinate screenCoordinate = ScreenCoordinate(x: middleX.round(), y: middleY.round());
//     LatLng? middlePoint = await controller!.getLatLng(screenCoordinate);
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     _gpsLocation.stopPositionStream();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _currentLocation = Geolocator.getCurrentPosition();
//
//     _gpsLocation.startPositionStream(_configurePositionStream).catchError((e) {
//       setState(() {
//         _exception = e;
//       });
//     controller = GoogleMapsController(
//       initialCameraPosition: CameraPosition(
//         target: LatLng(_currentLocation, _currentLocation,
//       )
//     );
//     });
//   }
//     // controller = GoogleMapsController(
//     //   initialCameraPosition: const CameraPosition(
//     //     target: LatLng(37.42796133580664, -122.085749655962),
//     //     zoom: 14.4746,
//     //   ),
//     //   onTap: (latlng) {
//     //     Circle circle;
//     //     circle = Circle(
//     //       circleId: CircleId(
//     //         "ID:" + DateTime.now().millisecondsSinceEpoch.toString(),
//     //       ),
//     //       center: latlng,
//     //       fillColor: Color.fromRGBO(255, 0, 0, 1),
//     //       strokeColor: Color.fromRGBO(155, 0, 0, 1),
//     //       radius: 5,
//     //       onTap: () => controller.removeCircle(circle),
//     //       consumeTapEvents: true,
//     //     );
//     //
//     //     controller.addCircle(circle);
//     //   },
//     // );
//   //
//   //   subscription = controller.onCameraMove$.listen((e) {
//   //     setState(() {
//   //       position = e;
//   //     });
//   //   });
//   // }
//
//   // @override
//   // void initState() {
//   //   super.initState();
//   //   _currentLocation = Geolocator.getCurrentPosition();
//   //   _gpsLocation.startPositionStream(_configurePositionStream).catchError((e) {
//   //     setState(() {
//   //       _exception = e;
//   //     });
//   //   });
//   // }
//
//   // Future<void> _redoSearch() async {
//   //   final GoogleMapController controller = await _controller.future;
//   //   controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
//   // }
//
//   Future <void> _retrieveNearbyRestaurants(LatLng _currentLocation) async {
//     // PlacesSearchResponse _response = await _places.searchNearbyWithRadius(
//     //     Location(lat: _currentLocation.latitude, lng: _currentLocation.longitude),
//     //     20000,
//     //     type: "restaurant");
//
//     PlacesSearchResponse response2 = await _places.searchNearbyWithRankBy(
//         Location(lat: _currentLocation.latitude, lng: _currentLocation.longitude),
//         "distance",
//         type: "restaurant");
//
//
//     Iterable<Marker> restaurantMarkers = response2.results
//         .map((result) =>
//         Marker(
//             markerId: MarkerId(result.name),
//             icon: BitmapDescriptor.defaultMarkerWithHue(
//                 BitmapDescriptor.hueAzure),
//             infoWindow:
//
//             InfoWindow(
//               title: result.name,
//               snippet: "Ratings: ${result.rating?.toString() ?? "Not Rated"}"
//                   "\nPrice: ${result.priceLevel?.toString() ??
//                   "No Price Data"}",
//
//               // add an Image widget to display the photo
//               // make sure to replace YOUR_API_KEY with your actual API key
//               // and set the width and height of the image
//               // child: result.photos != null && result.photos.isNotEmpty
//               //     ? Image.network(
//               //   "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${result.photos![0].photoReference}&key=APIKey",
//               //   width: 400,
//               //   height: 300,
//               // )
//               //     : const Text("No Photo Available"),
//             ),
//             position: LatLng(
//                 result.geometry!.location.lat, result.geometry!.location.lng))).toSet();
//
//     setState(() {
//       _markers.addAll(restaurantMarkers);
//     });
//   }
//
//     //   Iterable<Marker> _restaurantMarkers = _response2.results
//     //       .map((result) => Marker(
//     //       markerId: MarkerId(result.name),
//     //       // Use an icon with different colors to differentiate between current location
//     //       // and the restaurants
//     //
//     //       icon: BitmapDescriptor.defaultMarkerWithHue(
//     //           BitmapDescriptor.hueAzure),
//     //       infoWindow: InfoWindow(
//     //         title: result.name,
//     //         snippet: "Ratings: ${result.rating?.toString() ?? "Not Rated"}"
//     //             "\nPrice: ${result.priceLevel?.toString() ?? "No Price Data"}",
//     //             photoReference != null
//     //           ? '<img src="https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=YOUR_API_KEY" width="400" height="300">'
//     //           : "No Photo Available",
//     //         // add an Image widget to display the photo
//     //         // make sure to replace YOUR_API_KEY with your actual API key
//     //         // and set the width and height of the image
//     //
//     //       ),
//     //           //"Price: ${result.priceLevel?.toString() ?? "No Price Avaliable"}"),
//     //       // position: LatLng(
//     //       //      result.geometry!.location.lat, result.geometry!.location.lng)))
//     //       position: LatLng(
//     //           result.geometry!.location.lat, result.geometry!.location.lng)))
//     //       .toSet();
//     //
//     //   setState(() {
//     //     _markers.addAll(_restaurantMarkers);
//     //   });
//     // }
//
//     // Future<void> _retrieveNearbyRestaurants(LatLng _userLocation) async {
//     //   PlacesSearchResponse _response = await _places.searchNearbyWithRadius(
//     //       Location(lat: _userLocation.latitude, lng: _userLocation.longitude),
//     //       15000,
//     //       type: "restaurant");
//     //
//     //   Set<Marker> _restaurantMarkers = _response.results
//     //       .map((result) => Marker(
//     //       markerId: MarkerId(result.name),
//     //       // Use an icon with different colors to differentiate between current location
//     //       // and the restaurants
//     //       icon: BitmapDescriptor.defaultMarkerWithHue(
//     //           BitmapDescriptor.hueAzure),
//     //       infoWindow: InfoWindow(
//     //           title: result.name,
//     //           snippet:
//     //           "Ratings: ${result.rating?.toString() ?? "Not Rated"}"),
//     //       // position: LatLng(
//     //       //      result.geometry!.location.lat, result.geometry!.location.lng)))
//     //          position: LatLng(
//     //               result.geometry!.location.lat, result.geometry!.location.lng)))
//     //       .toSet();
//     //
//     //   setState(() {
//     //     _markers.addAll(_restaurantMarkers);
//     //   });
//     // }
//     // void _handlePressButton(Prediction p) async {
//     //   if (p != null) {
//     //     PlacesDetailsResponse detail =
//     //     await _places.getDetailsByPlaceId(p.placeId.toString());
//     //     var placeId = p.placeId;
//     //     double lat = detail.result.geometry!.location.lat;
//     //     double lng = detail.result.geometry!.location.lng;
//     //     LatLng latLng = LatLng(lat, lng);
//     //     mapController.animateCamera(
//     //       CameraUpdate.newLatLng(latLng),
//     //     );
//     //     mapController.animateCamera(
//     //       CameraUpdate.newLatLngZoom(latLng, 15.0),
//     //     );
//     //   }
//     // }
//     // void _getCurrentLocation() async {
//     //   try {
//     //     currentLocation = await locate.Location().getLocation();
//     //     mapController.animateCamera(
//     //       CameraUpdate.newCameraPosition(
//     //         CameraPosition(
//     //           target: LatLng(currentLocation.latitude!.toDouble(), currentLocation.longitude!.toDouble()),
//     //           zoom: 14,
//     //         ),
//     //       ),
//     //     );
//     //   } on Exception catch (e) {
//     //     print(e);
//     //   }
//     // }
//
//     //Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//
//     @override
//     Widget build(BuildContext context) {
//       return FutureBuilder(
//           future: _currentLocation,
//           builder: (BuildContext context, AsyncSnapshot snapshot) {
//             if (snapshot.connectionState == ConnectionState.done) {
//               if (snapshot.hasData) {
//                 // The user location returned from the snapshot
//                 Position snapshotData = snapshot.data;
//                 LatLng userLocation = LatLng(snapshotData.latitude, snapshotData.longitude);
//
//                 if (_markers.isEmpty) {
//                   _retrieveNearbyRestaurants(userLocation);
//                 }
//                 return Scaffold(
//                     body: GoogleMap(
//                       onMapCreated:  (controller) => controller,
//                       myLocationEnabled: true,
//                       myLocationButtonEnabled: false,
//                       initialCameraPosition: CameraPosition(
//                         target: userLocation,
//                         zoom: 14,
//                       ),
//                       markers: _markers
//                        //  ..add(Marker(
//                       //       markerId: const MarkerId("User Location"),
//                       //       infoWindow: const InfoWindow(
//                       //           title: "User Location"),
//                       //       position: _userLocation)),
//                     ),
//                     floatingActionButton: FloatingActionButton(
//                         child: const Text("Redo Search"),
//                         onPressed: () {
//                           controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(userLocation.latitude, userLocation.longitude), 14));
//                           _retrieveNearbyRestaurants(userLocation);
//                         }
//                     )
//                 );
//               } else {
//                 //return const Center(child: Text("Failed to get user location!"));
//                 return const GoogleMap(initialCameraPosition: CameraPosition(
//                     target: LatLng(33.7701, -118.1937),
//                     zoom: 12),
//                 );
//               }
//             }
//             return const GoogleMap(initialCameraPosition: CameraPosition(
//                 target: LatLng(33.7701, -118.1937),
//                 zoom: 12),
//             );
//             return const Center(child: CircularProgressIndicator());
//           });
//     }
//   }
//
//
//
//
//
//







// WORKING VERSION BELOW: VERSION 1

// final _places = GoogleMapsPlaces(apiKey: googleMapsAPIKey);
// // GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: googleMapsAPIKey);
//
// class RestaurantMap extends StatefulWidget {
//   const RestaurantMap({super.key});
//
//   @override
//   State<StatefulWidget> createState() {
//     return _RestaurantMapState();
//   }
// }
//
// class _RestaurantMapState extends State<RestaurantMap> {
//   final GPSLocation _gpsLocation = GPSLocation();
//   Position? _userPosition;
//   Exception? _exception;
//
//
//   //late final Future<Position> _currentLocation;
//   late final Set<Marker> _markers = {};
//   late GoogleMapController mapController;
//
//   void _configurePositionStream(Position position){
//     setState(() {
//       _userPosition = position;
//     });
//   }
//
//   @override
//   void dispose(){
//     super.dispose();
//     _gpsLocation.stopPositionStream();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     //_currentLocation = Geolocator.getCurrentPosition();
//     _gpsLocation.startPositionStream(_configurePositionStream).catchError((e) {
//       setState(() {
//         _exception = e;
//       });
//     });
//   }
//
//   Stream<Position?> _retrieveNearbyRestaurants(Position? userPosition) async* {
//     PlacesSearchResponse _response = await _places.searchNearbyWithRadius(
//         Location(lat: _userPosition!.latitude, lng: _userPosition!.longitude),
//         15000,
//         type: "restaurant");
//
//     Set<Marker> _restaurantMarkers = _response.results
//         .map((result) => Marker(
//         markerId: MarkerId(result.name),
//         // Use an icon with different colors to differentiate between current location
//         // and the restaurants
//         icon: BitmapDescriptor.defaultMarkerWithHue(
//             BitmapDescriptor.hueAzure),
//         infoWindow: InfoWindow(
//             title: result.name,
//             snippet:
//             "Ratings: ${result.rating?.toString() ?? "Not Rated"}"),
//         // position: LatLng(
//         //      result.geometry!.location.lat, result.geometry!.location.lng)))
//         position: LatLng(
//             result.geometry!.location.lat, result.geometry!.location.lng)))
//         .toSet();
//
//     setState(() {
//       _markers.addAll(_restaurantMarkers);
//     });
//   }
//
//   // Future<void> _retrieveNearbyRestaurants(LatLng _userLocation) async {
//   //   PlacesSearchResponse _response = await _places.searchNearbyWithRadius(
//   //       Location(lat: _userLocation.latitude, lng: _userLocation.longitude),
//   //       15000,
//   //       type: "restaurant");
//   //
//   //   Set<Marker> _restaurantMarkers = _response.results
//   //       .map((result) => Marker(
//   //       markerId: MarkerId(result.name),
//   //       // Use an icon with different colors to differentiate between current location
//   //       // and the restaurants
//   //       icon: BitmapDescriptor.defaultMarkerWithHue(
//   //           BitmapDescriptor.hueAzure),
//   //       infoWindow: InfoWindow(
//   //           title: result.name,
//   //           snippet:
//   //           "Ratings: ${result.rating?.toString() ?? "Not Rated"}"),
//   //       // position: LatLng(
//   //       //      result.geometry!.location.lat, result.geometry!.location.lng)))
//   //          position: LatLng(
//   //               result.geometry!.location.lat, result.geometry!.location.lng)))
//   //       .toSet();
//   //
//   //   setState(() {
//   //     _markers.addAll(_restaurantMarkers);
//   //   });
//   // }
//   // void _handlePressButton(Prediction p) async {
//   //   if (p != null) {
//   //     PlacesDetailsResponse detail =
//   //     await _places.getDetailsByPlaceId(p.placeId.toString());
//   //     var placeId = p.placeId;
//   //     double lat = detail.result.geometry!.location.lat;
//   //     double lng = detail.result.geometry!.location.lng;
//   //     LatLng latLng = LatLng(lat, lng);
//   //     mapController.animateCamera(
//   //       CameraUpdate.newLatLng(latLng),
//   //     );
//   //     mapController.animateCamera(
//   //       CameraUpdate.newLatLngZoom(latLng, 15.0),
//   //     );
//   //   }
//   // }
//   // void _getCurrentLocation() async {
//   //   try {
//   //     currentLocation = await locate.Location().getLocation();
//   //     mapController.animateCamera(
//   //       CameraUpdate.newCameraPosition(
//   //         CameraPosition(
//   //           target: LatLng(currentLocation.latitude!.toDouble(), currentLocation.longitude!.toDouble()),
//   //           zoom: 14,
//   //         ),
//   //       ),
//   //     );
//   //   } on Exception catch (e) {
//   //     print(e);
//   //   }
//   // }
//
//   //Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//
//   @override
//   Widget build(BuildContext context) {
//     StreamBuilder<Position?>(
//         //stream: Geolocator.getPositionStream(),
//         // initialData: _userPosition,
//         key: const ValueKey(googleMapsAPIKey),
//     // return StreamBuilder(
//     //     stream: Geolocator.getPositionStream(
//     //             locationSettings: const LocationSettings()
//         stream: Geolocator.getPositionStream(
//           locationSettings: const LocationSettings(),
//         ),
//         builder: (BuildContext context, AsyncSnapshot snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             if (snapshot.hasData) {
//               // The user location returned from the snapshot
//               Position snapshotData = snapshot.data;
//               LatLng _userLocation =
//               LatLng(snapshotData.latitude, snapshotData.longitude);
//
//               if (_markers.isEmpty) {
//                 _retrieveNearbyRestaurants(_userPosition);
//               }
//               //_retrieveNearbyRestaurants(_userPosition as LatLng);
//
//               return GoogleMap(
//                 myLocationEnabled: true,
//                 onMapCreated: (GoogleMapController controller) {
//                   mapController = controller;
//                 },
//                 initialCameraPosition: CameraPosition(
//                   target: _userLocation,
//                   zoom: 12,
//                 ),
//                 markers: _markers
//                   ..add(Marker(
//                       markerId: const MarkerId("User Location"),
//                       infoWindow: const InfoWindow(title: "User Location"),
//                       position: _userLocation)),
//               );
//             } else {
//               return const Center(child: Text("Failed to get user location!"));
//             }
//           }
//           return const GoogleMap(initialCameraPosition: CameraPosition(
//               target: LatLng(33.7701, -118.1937),
//               zoom: 12),
//           );
//           // While the connection is not in the done state yet
//         });
//       return const Center(
//         child: CircularProgressIndicator(
//           backgroundColor: Colors.black,
//           color: Colors.green,
//         )
//     );
//   }
// }
