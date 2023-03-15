import 'package:geolocator/geolocator.dart';

class LocationService {
  final Geolocator _geolocator = Geolocator();

  Future<Position> getCurrentLocation() async {
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isLocationServiceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    return await Geolocator.getCurrentPosition();
  }
}
// import 'dart:async';
// import 'package:geolocator/geolocator.dart';
//
// typedef CameraPositionCallback = Function(Position position);
//
// class GPSLocation  {
//   late Future<Position> userCurrentLocation;
//
//
//   // late StreamSubscription<Position> _positionStream;
//   //
//   // bool isAccessGranted(LocationPermission permission) {
//   //   return permission == LocationPermission.whileInUse ||
//   //       permission == LocationPermission.always;
//   // }
//   //
//   // Future<bool> requestPermission() async {
//   //   LocationPermission permission = await Geolocator.checkPermission();
//   //   if (isAccessGranted(permission)){
//   //     return true;
//   //   }
//   //   permission = await Geolocator.requestPermission();
//   //   return isAccessGranted(permission);
//   // }
//   //
//   // Future<void> startPositionStream(Function(Position position) callback) async{
//   //   bool permissionGranted = await requestPermission();
//   //   if(!permissionGranted){
//   //     throw Exception("User did not grant location permissions");
//   //   }
//   //   _positionStream = Geolocator.getPositionStream(
//   //     locationSettings: const LocationSettings(
//   //         accuracy: LocationAccuracy.bestForNavigation,
//   //     )).listen(callback);
//   // }
//   //
//   // Future<void> stopPositionStream() async {
//   //   _positionStream.cancel();
//   // }
// }