import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:crave_app_final/apiKeys.dart';
import 'location_controller.dart';

final _places = GoogleMapsPlaces(apiKey: googleMapsAPIKey);


class DrawMapController extends StatefulWidget {
  const DrawMapController({Key? key}) : super(key: key);

  @override
  DrawMapControllerState createState() => DrawMapControllerState();
}

class DrawMapControllerState extends State<DrawMapController> {
  static final Completer<GoogleMapController> _controller = Completer();
  late final Future<Position> _currentLocation;

  final Set<Polygon> _polygons = HashSet<Polygon>();
  final Set<Polyline> _polyLines = HashSet<Polyline>();

  bool _drawPolygonEnabled = false;
  late final Set<Marker> _markers = {};
  final List<LatLng> _userPolyLinesLatLngList = [];
  bool _clearDrawing = false;
  int? _lastXCoordinate, _lastYCoordinate;

  static const CameraPosition _csulb = CameraPosition(
    target: LatLng(33.7838, -118.1141),
    zoom: 14,
  );


  Future <void> _retrieveNearbyRestaurants(LatLng _userLocation) async {
    PlacesSearchResponse _response = await _places.searchNearbyWithRadius(
        Location(lat: _userLocation.latitude, lng: _userLocation.longitude),
        15000,
        type: "restaurant");

    Set<Marker> _restaurantMarkers = _response.results.map((result) => Marker(
        markerId: MarkerId(result.name),
        icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(
            title: result.name,
            snippet:
            "Ratings: ${result.rating?.toString() ?? "Not Rated"}"),
        position: LatLng(
            result.geometry!.location.lat, result.geometry!.location.lng)))
        .toSet();

    setState(() {
      _markers.addAll(_restaurantMarkers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (_drawPolygonEnabled) ? _onPanUpdate : null,
        onPanEnd: (_drawPolygonEnabled) ? _onPanEnd : null,
        child: GoogleMap(
          myLocationEnabled: true,
          mapType: MapType.normal,
          initialCameraPosition: _csulb,
          polygons: _polygons,
          polylines: _polyLines,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          //markers: _retrieveNearbyRestaurants(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleDrawing,
        tooltip: 'Drawing',
        child: Icon((_drawPolygonEnabled) ? Icons.cancel : Icons.edit),
      ),
      bottomSheet: showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only( // <-- SEE HERE
                topLeft: Radius.circular(25.0),
              ),
          ),
          builder: (context) {
            return SizedBox(
              height: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const <Widget>[
                  ...
                ],
              ),
            );
          , builder: (context) {
        return SizedBox(height: 200)
      }),
    );
  }

  _toggleDrawing() {
    _clearPolygons();
    setState(() => _drawPolygonEnabled = !_drawPolygonEnabled);
  }

  _onPanUpdate(DragUpdateDetails details) async {
    // To start draw new polygon every time.
    if (_clearDrawing) {
      _clearDrawing = false;
      _clearPolygons();
    }

    if (_drawPolygonEnabled) {
      double? x;
      double? y;
      if (Platform.isAndroid) {
        x = details.globalPosition.dx * 3;
        y = details.globalPosition.dy * 3;
      } else if (Platform.isIOS) {
        x = details.globalPosition.dx;
        y = details.globalPosition.dy;
      }

      // Round the x and y.
      int? xCoordinate = x!.round();
      int? yCoordinate = y!.round();

      // Check if the distance between last point is not too far.
      // to prevent two fingers drawing.
      if (_lastXCoordinate != null && _lastYCoordinate != null) {
        var distance = Math.sqrt(Math.pow(xCoordinate! - _lastXCoordinate!, 2)
            + Math.pow(yCoordinate! - _lastYCoordinate!, 2));
        // Check if the distance of point and point is too large.
        if (distance > 80.0) return;
      }

      // Cached the coordinate.
      _lastXCoordinate = xCoordinate;
      _lastYCoordinate = yCoordinate;

      ScreenCoordinate screenCoordinate = ScreenCoordinate(x: xCoordinate, y: yCoordinate);

      final GoogleMapController controller = await _controller.future;
      LatLng latLng = await controller.getLatLng(screenCoordinate);

      try {
        // Add new point to list.
        _userPolyLinesLatLngList.add(latLng);

        _polyLines.removeWhere((polyline) => polyline.polylineId.value == 'user_polyline');
        _polyLines.add(
          Polyline(
            polylineId: const PolylineId('user_polyline'),
            points: _userPolyLinesLatLngList,
            width: 2,
            color: Colors.orange,
          ),
        );
      } catch (e) {
        print(" error painting $e");
      }
      setState(() {});
    }
  }

  _onPanEnd(DragEndDetails details) async {
    _lastXCoordinate = null;
    _lastYCoordinate = null;

    if (_drawPolygonEnabled) {
      _polygons.removeWhere((polygon) => polygon.polygonId.value == 'user_polygon');
      _polygons.add(
        Polygon(
          polygonId: PolygonId('user_polygon'),
          points: _userPolyLinesLatLngList,
          strokeWidth: 2,
          strokeColor: Colors.orange,
          fillColor: Colors.orange.withOpacity(0.4),
          zIndex: 4,
        ),
      );
      setState(() {
        _clearDrawing = true;
      });
    }
  }

  _clearPolygons() {
    setState(() {
      _polyLines.clear();
      _polygons.clear();
      _userPolyLinesLatLngList.clear();
    });
  }
}
// import 'package:async/async.dart';
// import 'package:collection/collection.dart';
// import 'dart:collection';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
//
// class MapLandmark {
//
//   MapLandmark(this.pos){
//     screenPoint = ScreenPoint();
//   }
//
//   late Position pos;
//   late ScreenPoint screenPoint;
// }
//
// class ScreenPoint {
//
//   ScreenPoint({x = 0, y = 0});
//
//   late int x;
//   late int y;
// }
//
// class MapPainter extends CustomPainter {
//
//   final GoogleMapController _mapController;
//   late final Map<String, MapLandmark> _landmarksMap;
//   Paint? p;
//   bool _debugPaint = false;
//
//   MapPainter(this._landmarksMap, this._mapController) {
//     p = Paint()
//       ..strokeWidth = 5.0
//       ..color = Colors.orange
//       ..style = PaintingStyle.stroke;
//   }
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     if (_landmarksMap != null && _landmarksMap.length > 0) {
//       _landmarksMap.forEach((id, value) {
//         canvas.drawCircle(Offset(
//             value.screenPoint.x.toDouble(), value.screenPoint.y.toDouble()), 8,
//             p!);
//       });
//     } else {
//       canvas.drawCircle(Offset(70, 70), 25, p!);
//     }
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }


// import 'dart:async';
// import 'dart:collection';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// class DrawMap extends StatefulWidget {
//   const DrawMap({Key? key}) : super(key: key);
//
//   @override
//   State<DrawMap> createState() => _DrawMapState();
// }
//
// class _DrawMapState extends State<DrawMap> {
//   //final Position? currentPosition = Geolocator.getCurrentPosition() as Position?;
//
//   Completer<GoogleMapController> _controller = Completer();
//
//   static const CameraPosition _kGoogle = CameraPosition(
//     target: LatLng(19.0759837, 72.8776559),
//     zoom: 14,
//   );
//
//   final Set<Polygon> _polygon = HashSet<Polygon>();
//
//   // created list of locations to display polygon
//   List<LatLng> points = [
//     LatLng(19.0759837, 72.8776559),
//     LatLng(28.679079, 77.069710),
//     LatLng(26.850000, 80.949997),
//     LatLng(19.0759837, 72.8776559),
//   ];
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     //initialize polygon
//     _polygon.add(
//         Polygon(
//           // given polygonId
//           polygonId: const PolygonId('1'),
//           // initialize the list of points to display polygon
//           points: points,
//           // given color to polygon
//           fillColor: Colors.green.withOpacity(0.3),
//           // given border color to polygon
//           strokeColor: Colors.green,
//           geodesic: true,
//           // given width of border
//           strokeWidth: 4,
//         )
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color(0xFF0F9D58),
//         // title of app
//         title: Text("GFG"),
//       ),
//       body: Container(
//         child: SafeArea(
//           child: GoogleMap(
//             //given camera position
//             initialCameraPosition: _kGoogle,
//             // on below line we have given map type
//             mapType: MapType.normal,
//             // on below line we have enabled location
//             myLocationEnabled: true,
//             myLocationButtonEnabled: true,
//             // on below line we have enabled compass location
//             compassEnabled: true,
//             // on below line we have added polygon
//             polygons: _polygon,
//             // displayed google map
//             onMapCreated: (GoogleMapController controller){
//               _controller.complete(controller);
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
