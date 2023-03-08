import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:crave_app_final/apiKeys.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as locate;
import 'location_controller.dart';

final _places = GoogleMapsPlaces(apiKey: googleMapsAPIKey);

class MapLandmark {

  MapLandmark(this.pos){
    screenPoint = ScreenPoint();
  }

  late Position pos;
  late ScreenPoint screenPoint;
}

class ScreenPoint {

  ScreenPoint({x = 0, y = 0});

  late int x;
  late int y;
}


class MapPainter extends CustomPainter {

  final GoogleMapController _mapController;
  late final Map<String, MapLandmark> _landmarksMap;
  Paint? p;
  final bool _debugPaint = false;

  final BuildContext context;

  MapPainter(this.context, this._landmarksMap, this._mapController) {
    p = Paint()
      ..strokeWidth = 5.0
      ..color = Colors.orange
      ..style = PaintingStyle.stroke;
  }

  void _updateLandmarks() async {

    //double dpi = MediaQuery.of(context).devicePixelRatio;
    double dpi = MediaQuery.of(context).devicePixelRatio;
    LatLngBounds bounds = await _mapController.getVisibleRegion();
    ScreenCoordinate topRight = await _mapController.getScreenCoordinate(bounds.northeast);
    ScreenCoordinate bottomLeft = await _mapController.getScreenCoordinate(bounds.southwest);

    _landmarksMap.values.forEach((element) async {
      ScreenCoordinate sc = await _mapController.getScreenCoordinate(LatLng(element.pos.latitude, element.pos.longitude));
      element.screenPoint.x = ((sc.x - bottomLeft.x) / dpi).floor();
      element.screenPoint.y = ((sc.y - topRight.y) / dpi).floor();
    });

    //setState(() {});
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_landmarksMap != null && _landmarksMap.length > 0) {
      _landmarksMap.forEach((id, value) {
        canvas.drawCircle(Offset(
            value.screenPoint.x.toDouble(), value.screenPoint.y.toDouble()), 8, p!);
      });
    } else {
      canvas.drawCircle(const Offset(70, 70), 25, p!);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class RestaurantMap extends StatefulWidget {
  const RestaurantMap({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RestaurantMapState();
  }
}

class _RestaurantMapState extends State<RestaurantMap> {
  final GPSLocation _gpsLocation = GPSLocation();
  Position? _userPosition;
  Exception? _exception;


  late final Future<Position> _currentLocation;
  late final Set<Marker> _markers = {};
  late GoogleMapController mapController;

  void _configurePositionStream(Position position){
    setState(() {
      _userPosition = position;
    });
  }

  @override
  void dispose(){
    super.dispose();
    _gpsLocation.stopPositionStream();
  }

  @override
  void initState() {
    super.initState();
    _currentLocation = Geolocator.getCurrentPosition();
    _gpsLocation.startPositionStream(_configurePositionStream).catchError((e) {
      setState(() {
        _exception = e;
      });
    });
  }

  Future <void> _retrieveNearbyRestaurants(LatLng _userLocation) async {
    PlacesSearchResponse _response = await _places.searchNearbyWithRadius(

        Location(lat: _userLocation.latitude, lng: _userLocation.longitude),
        20000,
        type: "restaurant");


    Iterable<Marker> _restaurantMarkers = _response.results
        .map((result) => Marker(
        markerId: MarkerId(result.name),
        // Use an icon with different colors to differentiate between current location
        // and the restaurants
        icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(
            title: result.name,
            snippet:
            "Ratings: ${result.rating?.toString() ?? "Not Rated"}"),
            //"Price: ${result.priceLevel?.toString() ?? "No Price Avaliable"}"),
        // position: LatLng(
        //      result.geometry!.location.lat, result.geometry!.location.lng)))
        position: LatLng(
            result.geometry!.location.lat, result.geometry!.location.lng)))
        .toSet();

    setState(() {
      _markers.addAll(_restaurantMarkers);
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _currentLocation,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            // The user location returned from the snapshot
            Position snapshotData = snapshot.data;
            LatLng _userLocation =
            LatLng(snapshotData.latitude, snapshotData.longitude);

            if (_markers.isEmpty) {
              _retrieveNearbyRestaurants(_userLocation);
            }
            return GoogleMap(
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: _userLocation,
                zoom: 12,
              ),
              markers: _markers..add(Marker(
                    markerId: const MarkerId("User Location"),
                    infoWindow: const InfoWindow(title: "User Location"),
                    position: _userLocation)),
            );
          } else {
            return const Center(child: Text("Failed to get user location!"));
          }
        }
          // return const GoogleMap(initialCameraPosition: CameraPosition(
          //     target: LatLng(33.7701, -118.1937),
          //     zoom: 12),
          // );
          // While the connection is not in the done state yet
         return const Center(child: CircularProgressIndicator());
      });
  }
}

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
