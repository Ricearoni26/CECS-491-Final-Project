import 'dart:async';
import 'package:geolocator/geolocator.dart';

typedef CameraPositionCallback = Function(Position position);

class GPSLocation {

  late StreamSubscription<Position> _positionStream;

  bool isAccessGranted(LocationPermission permission) {
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (isAccessGranted(permission)){
      return true;
    }
    permission = await Geolocator.requestPermission();
    return isAccessGranted(permission);
  }

  Future<void> startPositionStream(Function(Position position) callback) async{
    bool permissionGranted = await requestPermission();
    if(!permissionGranted){
      throw Exception("User did not grant location permissions");
    }
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
      )).listen(callback);
  }

  Future<void> stopPositionStream() async {
    _positionStream.cancel();
  }
}