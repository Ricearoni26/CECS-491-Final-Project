// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_webservice/places.dart';
// import 'package:crave_app_final/apiKeys.dart';
//
//
// final _places = GoogleMapsPlaces(apiKey: googleMapsAPIKey);
//
//
// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});
//
//   @override
//   _MapScreenState createState() => _MapScreenState();
// }
//
// class _MapScreenState extends State<MapScreen> {
//   late GoogleMapController _mapController;
//   late LatLngBounds _bounds;
//   late Position _currentLocation;
//   late CameraPosition _cameraPosition;
//   List<PlacesSearchResult> _places = [];
//
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }
//
//
//
//
//
//
//   Future<void> _getCurrentLocation() async {
//     // Request permission to access the user's location
//     LocationPermission permission = await Geolocator.requestPermission();
//     if (permission != LocationPermission.whileInUse
//         && permission != LocationPermission.always) {
//           AlertDialog(
//           title: const Text('Error'),
//           content: const Text('Location permission was denied'),
//           actions: [
//             TextButton(
//               child: const Text('OK'),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//           ],
//         );
//
//
//
//     // Get the current location of the user
//     Position position = await Geolocator.getCurrentPosition();
//
//     // Set the initial camera position of the map
//     final initialCameraPosition = CameraPosition(
//       target: LatLng(position.latitude, position.longitude),
//       zoom: 14.0,
//     );
//
//     // Update the state with the current location and camera position
//     setState(() {
//       _currentLocation = position;
//       _cameraPosition = initialCameraPosition;
//     });
//   }
//
//
//
//     // Create the GoogleMap widget
//     final googleMap = GoogleMap(
//       initialCameraPosition: _cameraPosition,
//       onMapCreated: (controller) => _mapController = controller,
//       onCameraIdle: () => _searchNearbyPlaces(),
//       markers: _places.map((place) => _createMarker(place)).toSet(),
//     );
//
//     // Display the map
//     setState(() => googleMap);
//
//     // Set the initial visible region of the map
//     _setBounds(_mapController.getVisibleRegion() as LatLng);
//   }
//
//   void _setBounds(LatLng center) {
//     final southwest = LatLng(
//       center.latitude - 0.5 * _mapController.zoom,
//       center.longitude - 0.5 * _mapController.zoom,
//     );
//     final northeast = LatLng(
//       center.latitude + 0.5 * _mapController,
//       center.longitude + 0.5 * _mapController.zoom,
//     );
//     setState(() => _bounds = LatLngBounds(southwest: southwest, northeast: northeast));
//   }
//
//   Future<void> _searchNearbyPlaces() async {
//     final places = GoogleMapsPlaces(apiKey: googleMapsAPIKey);
//     final response = await places.searchNearbyWithRadius(
//         Location(lat: _mapController.getVisibleRegion(), lng: _mapController.cameraPosition.target.longitude), 1000);
//       //location: Location(lat: _mapController.cameraPosition.target.latitude, lng: _mapController.cameraPosition.target.longitude),
//       // 1000,
//       // type: 'restaurant',
//
//
//     if (response.status == 'OK') {
//       setState(() => _places = response.results);
//     } else {
//       print('Error: ${response.errorMessage}');
//     }
//   }
//
//   Marker _createMarker(PlacesSearchResult place) {
//     final markerId = MarkerId(place.placeId);
//     final position = LatLng(place.geometry!.location.lat, place.geometry!.location.lng);
//     final infoWindow = InfoWindow(
//       title: place.name,
//       snippet: place.vicinity,
//       onTap: () => _showDetails(place),
//     );
//     return Marker(markerId: markerId, position: position, infoWindow: infoWindow);
//   }
//
//   Future<void> _showDetails(PlacesSearchResult place) async {
//     final places = GoogleMapsPlaces(apiKey: googleMapsAPIKey);
//     final response = await places.getDetailsByPlaceId(place.placeId);
//
//     if (response.status == 'OK') {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text(response.result.name),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(response.result.formattedAddress.toString()),
//               if (response.result.formattedPhoneNumber != null) Text(response.result.formattedPhoneNumber.toString()),
//               if (response.result.website != null) Text(response.result.website.toString()),
//             ],
//           ),
//         ),
//       );
//     } else {
//       print('Error: ${response.errorMessage}');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Map')),
//       body: _googleMap != null
//           ? Stack(
//         children: [
//           _googleMap,
//           if (_bounds != null) Container(
//             alignment: Alignment.topCenter,
//             padding: EdgeInsets.only(top: 8.0),
//             child: Text('Showing results for the visible area'),
//           ),
//         ],
//       )
//           : Center(child: CircularProgressIndicator()),
//     );
//   }
// }
