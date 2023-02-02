import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:crave_app_final/apiKeys.dart';
import 'package:geolocator/geolocator.dart';

final places = GoogleMapsPlaces(apiKey: googleMapsAPIKey);

class FoodieMap extends StatefulWidget {
  const FoodieMap({super.key});

  @override
  State<StatefulWidget> createState() {
    return _FoodieMapState();
  }
}

class _FoodieMapState extends State<FoodieMap> {
  late Future<Position> _currentLocation;
  late final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _currentLocation = Geolocator.getCurrentPosition();
  }

  Future<void> _retrieveNearbyRestaurants(LatLng _userLocation) async {
    PlacesSearchResponse _response = await places.searchNearbyWithRadius(
        Location(lat: _userLocation.latitude, lng: _userLocation.longitude),
        15000,
        type: "restaurant");

    Set<Marker> _restaurantMarkers = _response.results
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
        // position: LatLng(
        //      result.geometry!.location.lat, result.geometry!.location.lng)))
           position: LatLng(
                result.geometry!.location.lat, result.geometry!.location.lng)))
        .toSet();

    setState(() {
      _markers.addAll(_restaurantMarkers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _currentLocation,
        key: const ValueKey(googleMapsAPIKey),
    // return StreamBuilder(
    //     stream: Geolocator.getPositionStream(
    //             locationSettings: const LocationSettings()
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
                markers: _markers
                  ..add(Marker(
                      markerId: const MarkerId("User Location"),
                      infoWindow: const InfoWindow(title: "User Location"),
                      position: _userLocation)),
              );
            } else {
              return const Center(child: Text("Failed to get user location."));
            }
          }
          // While the connection is not in the done state yet
          return const Center(child: CircularProgressIndicator());
        });
  }
}
