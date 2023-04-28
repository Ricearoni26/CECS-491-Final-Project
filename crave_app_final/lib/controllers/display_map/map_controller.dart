import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math' as math;
import 'package:crave_app_final/screens/GoogleToYelpPage.dart';
import 'package:crave_app_final/screens/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../apiKeys.dart';
import '../../screens/RestaurantListPage.dart';
import '../../screens/home_screen.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';


final places = GoogleMapsPlaces(apiKey: googleMapsAPIKey);

class MapScreenOld extends StatefulWidget {
  final Position currentPosition;
  const MapScreenOld({Key? key, required this.currentPosition}) : super(key: key);
  @override
  MapScreenOldState createState() => MapScreenOldState();
}

class MapScreenOldState extends State<MapScreenOld> {
  late Completer<GoogleMapController> _controllerInitial;
  late Completer<GoogleMapController> _controllerDraw;
  GoogleMapController? _currentController;
  PlacesSearchResponse? rest_result;
  List<Marker> _markers = [];
  bool _isMapMoving = false;
  late LatLng _center;
  Position? currentPosition;
  bool _shouldDrawMap = false;

  Set<Polygon> _polygons = HashSet<Polygon>();
  Set<Polyline> _polyLines = HashSet<Polyline>();
  bool _isPolygonNull = true;
  bool _drawPolygonEnabled = false;
  Set<Marker> _markersFromDrawArea = {};
  List<LatLng> _userPolyLinesLatLngList = [];
  bool _clearDrawing = false;
  List<LatLng> _polygonPoints = [];
  int? _lastXCoordinate, _lastYCoordinate;
  bool isSearchBarSelected = false;
  //List<Photo> restautantPhotos = [];
  List<Widget> restaurantCards = [];


  bool isSelected = false;
  Marker? _selectedMarker;
  int _currentItem = 0;


  void _onMarkerTap(List<Widget> cards) {
    setState(() {
      _restaurantBottomCardBuilder(cards);
      isSelected = !isSelected;
      print("the marker was pressed");
    });
  }

  Future<void> _searchNearbyPlaces() async {
    final location = Location(lat: _center.latitude, lng: _center.longitude);
    final result = await places.searchNearbyWithRankBy(location, "distance",
        type: 'restaurant');
    rest_result = result;
    //List<Widget> _restaurantCards = restaurantCards;

    // PlacesSearchResponse _response = await places.searchNearbyWithRankBy(
    //     Location(
    //         lat: widget.currentPosition.latitude,
    //         lng: widget.currentPosition.longitude),
    //     "distance",
    //     type: "restaurant");

    BitmapDescriptor selectedIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    BitmapDescriptor unselectedIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);

    isSelected = false;

    setState(() {

      restaurantCards = [];
      restaurantCards.addAll(result.results.map((restaurant) => _cards(
          restaurant.photos, //.isEmpty ? Text("No Photos") : restaurant.photos,
          restaurant.geometry!.location.lat,
          restaurant.geometry!.location.lng,
          restaurantNameParameters(restaurant.name)
      )));
      _markers.addAll(result.results.map((restaurant) =>
          Marker(
            markerId: MarkerId(restaurant.placeId),
            onTap: () => _onMarkerTap(restaurantCards),
            icon: isSelected ? selectedIcon : unselectedIcon,
            position: LatLng(restaurant.geometry!.location.lat,
                restaurant.geometry!.location.lng),
            infoWindow: InfoWindow(
                title: restaurant.name,
                snippet:
                    "Ratings: ${restaurant.rating?.toString() ?? "Not Rated"}\nPrice: ${restaurant.priceLevel?.toString()}"),
          )));
      print("search places was completed");
    });
  }

  String restaurantNameParameters(String restaurantName) {
    int index = restaurantName.indexOf("(");
    if (index != -1) { // Check if the string contains "("
      restaurantName = restaurantName.substring(0, index); // Remove all characters after the first occurrence of "("
    }
    return restaurantName;
  }

  String getImage(List<Photo> photos) {
    const baseUrl = 'https://maps.googleapis.com/maps/api/place/photo';
    const maxWidth = '400';
    const maxHeight = '200';
    String url = photos.isNotEmpty ? '$baseUrl?maxwidth=$maxWidth&maxheight=$maxHeight&photoreference=${photos![0].photoReference}&key=$googleMapsAPIKey' : Text("no photos").toString();
    //String url = '$baseUrl?maxwidth=$maxWidth&maxheight=$maxHeight&photoreference=$photoReference&key=$googleMapsAPIKey';

    return url;
  }


  Future<void> _retrieveRestaurantsInDrawnArea() async {
    final location = Location(lat: _center.latitude, lng: _center.longitude);
    final response = await places.searchNearbyWithRadius(
        location,
        50000,
        type: "restaurant");

    final List<PlacesSearchResult> filteredResults = filterResultsInDrawnArea(response.results, _userPolyLinesLatLngList);
    //final List<PlacesSearchResult> filteredResults = filterResultsInDrawnArea(response.results, _polygonPoints);



    final Set<Marker> _restaurantMarkers = filteredResults.map((result) =>
        Marker(

    final List<PlacesSearchResult> _filteredResults =
        _response.results.where((result) {
      return _userPolyLinesLatLngList.contains(LatLng(
        result.geometry!.location.lat,
        result.geometry!.location.lng,
      ));
    }).toList();

    Set<Marker> _restaurantMarkers = _filteredResults
        .map((result) => Marker(

            markerId: MarkerId(result.name),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            infoWindow: InfoWindow(
                title: result.name,
        .toSet();

    setState(() {
      _markersFromDrawArea = _restaurantMarkers;
    });
  }

  List<PlacesSearchResult> filterResultsInDrawnArea(List<PlacesSearchResult> results, List<LatLng> polygonVertices) {
    bool isPointInPolygon(double latitude, double longitude, List<LatLng> polygonVertices) {
      int i, j = polygonVertices.length - 1;
      bool isPointValid = false;
      for (i = 0; i < polygonVertices.length; i++) {
        if (((polygonVertices[i].longitude <= longitude && longitude < polygonVertices[j].longitude) ||
            (polygonVertices[j].longitude <= longitude && longitude < polygonVertices[i].longitude)) &&
            (latitude < (polygonVertices[j].latitude - polygonVertices[i].latitude) *
                (longitude - polygonVertices[i].longitude) /
                (polygonVertices[j].longitude - polygonVertices[i].longitude) +
                polygonVertices[i].latitude)) {
          isPointValid = !isPointValid;
        }
        j = i;
      }
      return isPointValid;
    }

    return results.where((result) {
      return isPointInPolygon(result.geometry!.location.lat, result.geometry!.location.lng, polygonVertices);
    }).toList();
  }



  // Future<void> _retrieveRestaurantsInDrawnArea() async {
  //   final location = Location(lat: _center.latitude, lng: _center.longitude);
  //   final response = await places.searchNearbyWithRadius(
  //       location,
  //       15000,
  //       type: "restaurant");
  //
  //   List<PlacesSearchResult> _filteredResults =
  //   response.results.where((result) {
  //     return _userPolyLinesLatLngList.contains(LatLng(
  //       result.geometry!.location.lat,
  //       result.geometry!.location.lng,
  //     ));
  //   }).toList();
  //
  //   Set<Marker> _restaurantMarkers = _filteredResults.map((result) =>
  //       Marker(
  //           markerId: MarkerId(result.name),
  //           icon: BitmapDescriptor.defaultMarkerWithHue(
  //               BitmapDescriptor.hueAzure),
  //           infoWindow: InfoWindow(
  //               title: result.name,
  //               snippet:
  //               "Ratings: ${result.rating?.toString() ?? "Not Rated"}"),
  //           position: LatLng(
  //               result.geometry!.location.lat, result.geometry!.location.lng)))
  //       .toSet();
  //
  //   setState(() {
  //     _markersFromDrawArea.addAll(_restaurantMarkers);
  //     print("_markersFromDrawArea size is: ${_markersFromDrawArea.length}");
  //     _restaurantMarkers.clear();
  //     _filteredResults.clear();
  //   });
  // }


  // Future<void> _retrieveRestaurantsInDrawnArea() async {
  //   // PlacesSearchResponse _response = await _places.searchNearbyWithRadius(
  //   //     Location(lat: widget.currentPosition.latitude, lng: widget.currentPosition.longitude),
  //   //     15000,
  //   //     type: "restaurant");
  //   final location = Location(lat: _center.latitude, lng: _center.longitude);
  //   final result = await places.searchNearbyWithRadius(
  //       location,
  //       15000,
  //       type: "restaurant");
  //
  //   // PlacesSearchResponse result = await places.searchNearbyWithRadius(
  //   //     Location(
  //   //         lat: widget.currentPosition.latitude,
  //   //         lng: widget.currentPosition.longitude),
  //   //     15000,
  //   //     type: "restaurant");
  //
  //   final List<PlacesSearchResult> _filteredResults =
  //   result.results.where((result) {
  //     return _userPolyLinesLatLngList.contains(LatLng(
  //       result.geometry!.location.lat,
  //       result.geometry!.location.lng,
  //     ));
  //   }).toList();
  //
  //   // Set<Marker> _restaurantMarkers = _filteredResults
  //
  //   setState(() {
  //     _markersFromDrawArea.addAll(_filteredResults.addAll(result.results.map((result) =>
  //       Marker(
  //           markerId: MarkerId(result.name),
  //           icon: BitmapDescriptor.defaultMarkerWithHue(
  //               BitmapDescriptor.hueAzure),
  //           infoWindow: InfoWindow(
  //               title: result.name,
  //               snippet:
  //               "Ratings: ${result.rating?.toString() ?? "Not Rated"}"),
  //           position: LatLng(
  //               result.geometry!.location.lat, result.geometry!.location.lng)))));
  //
  //
  //     //_markers.addAll(_restaurantMarkers);
  //   });
  // }

  void _clearMarkers() {
    setState(() {
      _markers.clear();
    });
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _center = position.target;
      const Duration(milliseconds: 2000);
      _isMapMoving = true;
    });
  }

  _onDrawMapCreated(GoogleMapController controller) {
    setState(() {
      if (!_controllerDraw.isCompleted) {
        _controllerDraw.complete(controller);
        _currentController = controller;
      }
    });
  }

  _onInitialMapCreated(GoogleMapController controller) {
    setState(() {
      if (!_controllerInitial.isCompleted) {
        _controllerInitial.complete(controller);
        _currentController = controller;
      }
    });
  }

  _switchToDrawMode() {
    //_controllerDraw ??= Completer();
    _controllerDraw.future.then((controller) {
      setState(() {
        _currentController = controller;
        _shouldDrawMap = true;
        print("Should draw map is now true");
      });
    });
  }


  _switchToInitialMode() {
    //_controllerInitial ??= Completer();
    _controllerInitial.future.then((controller) {
      setState(() {
        _currentController = controller;
        _shouldDrawMap = false;
        print("Should draw map is now false");
      });
    });
  }

  _toggleDrawing() {
    _clearMarkers();
    //setState(() => _shouldDrawMap = true);
    setState(() {
      print("Should draw map is ${_shouldDrawMap}");
      _drawPolygonEnabled = !_drawPolygonEnabled;
    });
  }

  _drawingModeOn() {
    _clearMarkers();
    setState(() {
      _shouldDrawMap = true;
      _drawPolygonEnabled = true;
    });
  }

  _drawingModeOff() {
    _clearPolygons();
    _clearMarkers();
    setState(() {
      _shouldDrawMap = false;
      _drawPolygonEnabled = false;
    });
  }

  _clearPolygons() {
    setState(() {
      // _polyLines.clear();
      // _polygons.clear();
      // _userPolyLinesLatLngList.clear();
      _polyLines = {};
      _polygons = {};
      _userPolyLinesLatLngList = [];
    });
  }

  _onPanUpdate(DragUpdateDetails details) async {
    // To start draw new polygon every time.
    print("clear drawing value: ${_clearDrawing}");
    if (_clearDrawing) {
      _clearPolygons();
      _clearDrawing = false;
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
        var distance = math.sqrt(math.pow(xCoordinate - _lastXCoordinate!, 2) +
            math.pow(yCoordinate - _lastYCoordinate!, 2));
        // Check if the distance of point and point is too large.
        if (distance > 80.0) return;
      }

      // Cached the coordinate.
      _lastXCoordinate = xCoordinate;
      _lastYCoordinate = yCoordinate;

      ScreenCoordinate screenCoordinate =
          ScreenCoordinate(x: xCoordinate, y: yCoordinate);

      // controllerForDrawnArea = await _controllerDraw.future;
      // LatLng latLng = await controllerForDrawnArea!.getLatLng(screenCoordinate);

      GoogleMapController? controllerForDrawnArea =
          await _controllerDraw.future;
      LatLng latLng = await controllerForDrawnArea.getLatLng(screenCoordinate);

      try {
        // Add new point to list.
        _polygonPoints.add(latLng);
        _userPolyLinesLatLngList.add(latLng);
        _polyLines.removeWhere(
            (polyline) => polyline.polylineId.value == 'user_polyline');
        _polyLines.add(
          Polyline(
            polylineId: const PolylineId('user_polyline'),
            points: _userPolyLinesLatLngList,
            width: 2,
            color: Colors.orange,
          ),
        );
        //_isPolygonNull = false;
      } catch (e) {}
      controllerForDrawnArea.dispose();
      controllerForDrawnArea = null;
      setState(() {
        print("_onPanUpdate completed");
      });
    }
  }

  _onPanEnd(DragEndDetails details) async {
    _lastXCoordinate = null;
    _lastYCoordinate = null;

    if (_drawPolygonEnabled) {
      _polygons
          .removeWhere((polygon) => polygon.polygonId.value == 'user_polygon');
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
      //_polygonPoints.add(_userPolyLinesLatLngList);
      setState(() {
        //_retrieveRestaurantsInDrawnArea();
        //const Duration(seconds: 3);
        //Navigator.pop(context);
        //_clearDrawing = true;
        //_searchNearbyPlaces();
        //_retrieveRestaurantsInDrawnArea();
        print("_onPanEnd completed");
      });
    }
  }

  // Widget _openDrawerButton() {
  //   return Align(
  //     alignment: Alignment.center,
  //     child: Padding(
  //       padding: const EdgeInsets.fromLTRB(10, 59, 0, 0),
  //       child: Align(
  //         alignment: Alignment.topLeft,
  //         child: IconButton(
  //           icon: const Icon(
  //             Icons.list,
  //             size: 32,
  //           ),
  //           onPressed: () {
  //             Scaffold.of(context).openDrawer();
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _searchBar() {
    return GestureDetector(
      onTap: () {
        isSearchBarSelected = true;
      },
      child: SearchBar(
        currentPosition: widget.currentPosition,
        gmController: _currentController,
        isSearchBarSelected: isSearchBarSelected,
      ),
    );
    // return GestureDetector(
    //   onTap: () {},
    //   child: Padding(
    //     padding: const EdgeInsets.fromLTRB(15, 50, 15, 0),
    //     child: Padding(
    //       padding: const EdgeInsets.all(8.0),
    //       child: TextField(
    //         controller: _searchController,
    //         onChanged: _onSearch,
    //         decoration: InputDecoration(
    //           filled: true,
    //           fillColor: Colors.white,
    //           hintText: 'Enter a Restaurant',
    //           prefixIcon: const Icon(Icons.search),
    //           contentPadding: const EdgeInsets.only(left: 20, bottom: 5, right: 5),
    //           focusedBorder: OutlineInputBorder(
    //             borderRadius: BorderRadius.circular(30),
    //             borderSide: const BorderSide(color: Colors.white),
    //           ),
    //           enabledBorder: OutlineInputBorder(
    //             borderRadius: BorderRadius.circular(30),
    //             borderSide: const BorderSide(color: Colors.white),
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
// return GestureDetector(
    //   onTap: () {
    //
    //   },
    //   child: Padding(
    //     padding: const EdgeInsets.fromLTRB(15, 50, 15, 0),
    //     child: Padding(
    //       padding: const EdgeInsets.all(8.0),
    //       child: TextField(
    //         decoration: InputDecoration(
    //           filled: true,
    //           fillColor: Colors.white,
    //           hintText: ('Enter a Restaurant'),
    //           prefixIcon: const Icon(Icons.search),
    //           contentPadding: const EdgeInsets.only(left: 20, bottom: 5, right: 5),
    //           focusedBorder: OutlineInputBorder(
    //             borderRadius: BorderRadius.circular(30),
    //             borderSide: const BorderSide(color: Colors.white),
    //           ),
    //           enabledBorder: OutlineInputBorder(
    //             borderRadius: BorderRadius.circular(30),
    //             borderSide: const BorderSide(color: Colors.white),
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }

  Widget _drawButton() {
    return AnimatedOpacity(
      opacity: _isMapMoving ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 1000),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 120, 20, 0),
        child: Align(
          alignment: Alignment.topRight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 30,
              child: ElevatedButton(
                child: const Text(
                  "Draw",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Arial",
                    fontSize: 12,
                  ),
                ),
                onPressed: () {
                  _switchToDrawMode();
                  _drawingModeOn();
                  print("Draw button was pressed");
                },

                // _controllerDraw.future.then((controller) {
                //   setState(() {
                //     _currentController = controller;
                //   });
                // });
                // _controllerDraw.future.then((controller) {
                //   setState(() {
                //     _currentController = controller;
                //   });
                // // _drawingModeOn();
                // // _switchToDrawMode();
                //   ),
                //},
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _drawButton() {
  //   return AnimatedOpacity(
  //     opacity: _isMapMoving ? 1.0 : 0.0,
  //     duration: const Duration(milliseconds: 1000),
  //     child: Padding(
  //       padding: const EdgeInsets.fromLTRB(0, 120, 20, 0),
  //       child: Align(
  //         alignment: Alignment.topRight,
  //         child: SizedBox(
  //           height: 30,
  //           child: ElevatedButton.icon(
  //             onPressed: () {
  //               _switchToDrawMode();
  //               _drawingModeOn();
  //             },
  //             icon: Icon(
  //               Icons.edit,
  //               color: Colors.white,
  //               size: 16,
  //             ),
  //             label: const Text(
  //               "Draw",
  //               style: TextStyle(
  //                 color: Colors.white,
  //                 fontFamily: "Arial",
  //                 fontSize: 12,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //             style: ElevatedButton.styleFrom(
  //               primary: Colors.orange,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(20.0),
  //               ),
  //               padding: const EdgeInsets.symmetric(
  //                 vertical: 8.0,
  //                 horizontal: 16.0,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _redoSearchAreaButton() {
    return AnimatedOpacity(
      opacity: _isMapMoving ? 1.0 : 0.0,
      duration: Duration(milliseconds: 1000),
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 120, 20, 0),
        child: Align(
          alignment: Alignment.topCenter,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 25,
              child: ElevatedButton(
                onPressed: () async {
                  _clearMarkers();
                  _searchNearbyPlaces();
                  _isMapMoving = false;
                  _restaurantBottomCardBuilder(restaurantCards);
                  //dispose();
                },
                child: Text(
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
      ),
    );
  }

  Future<void> _gotoLocation (double lat, double long) async {
    GoogleMapController? controller = await _currentController;
    controller?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, long),
          zoom: 15,
          tilt: 50.0,
          )));
  }

  Widget _cards(List<Photo> image, double lat, double long, String restaurantName) {
    return GestureDetector(
      onTap: () {
        _gotoLocation(lat, long);
        print("card was tapped");
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 3,
            child: Material(
              child: Placeholder(),
            ),
            // child: Material(
            //   color: Colors.white,
            //     elevation: 14,
            //     borderRadius: BorderRadius.circular (24.0),
            //     shadowColor: Color (0x802196F3),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Container(
            //           width: 180,
            //           height: 200,
            //           child: Padding(
            //             padding: const EdgeInsets.all(8.0),
            //             child: ClipRRect (
            //               borderRadius: BorderRadius.circular (24.0),
            //               //child: const Placeholder(),
            //               child: Image.network(getImage(image), fit: BoxFit.fill,),
            //               // child: Image(
            //               //   fit: BoxFit.fill,
            //               //   image: Image(_image) ?
            //               //   Placeholder() :
            //               //   NetworkImage(_image![0].photoReference),
            //               //   //image: Image.network(getImage(_image[0].photoReference)),
            //               // ),
            //             ),
            //           ),
            //         ),
            //         FittedBox(
            //             child: Padding(
            //               padding: const EdgeInsets.all(8),
            //               child: restaurantDetailsContainer(restaurantName),
            //             )
            //         ),
            //       ],
            //     ),
            // ),
        ),
      ),
    );
  }

  // Widget _cards(List<Photo> image, double lat, double long, String restaurantName) {
  //   return GestureDetector(
  //     onTap: () {
  //       _gotoLocation(lat, long);
  //       print("card was tapped");
  //     },
  //     child: Padding(
  //       padding: const EdgeInsets.only(left: 10, right: 10),
  //       child: SizedBox(
  //         width: 600, //MediaQuery.of(context).size.width,
  //         height: 300, //MediaQuery.of(context).size.height / 3,
  //         child: FittedBox(
  //           child: Material(
  //             color: Colors.white,
  //             elevation: 14,
  //             borderRadius: BorderRadius.circular (24.0),
  //             shadowColor: Color (0x802196F3),
  //             child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Container(
  //                     width: 180,
  //                     height: 200,
  //                     child: Padding(
  //                       padding: const EdgeInsets.all(8.0),
  //                       child: ClipRRect (
  //                         borderRadius: BorderRadius.circular (24.0),
  //                         //child: const Placeholder(),
  //                         child: Image.network(getImage(image), fit: BoxFit.fill,),
  //                         // child: Image(
  //                         //   fit: BoxFit.fill,
  //                         //   image: Image(_image) ?
  //                         //   Placeholder() :
  //                         //   NetworkImage(_image![0].photoReference),
  //                         //   //image: Image.network(getImage(_image[0].photoReference)),
  //                         // ),
  //                       ),
  //                     ),
  //                   ),
  //                   Container(
  //                     child: Padding(
  //                       padding: const EdgeInsets.all(8),
  //                       child: restaurantDetailsContainer(restaurantName),
  //                     )
  //                   ),
  //                 ],
  //             )
  //         ),
  //       ),
  //   ),
  //     ),);
  // }

  Widget restaurantDetailsContainer(String restaurantName){
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Padding(
          padding:  EdgeInsets.only(left: 8.0, right: 8.0),
          child: Container(
            child: Text(restaurantName,
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold
              ),
            ),
          )
        ),
        //SizedBox(height: 5.0),
        FittedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                child: Text(
                  "4.0",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                  )
                )
              )
            ],
          ),
        )
      ],
    );
  }


  Widget _restaurantBottomCardBuilder(List<Widget> restaurantCards){
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 150.0),
        height: 150,
        //width: MediaQuery.of(context).size.width,
        child: PageView(
          scrollDirection: Axis.horizontal,
          children: restaurantCards,
        ),

        // child: Expanded(
        //   child: rest_result == null
        //       ? const Center(
        //     child: Text("Nothing to see here"),
        //   )
        //       : ListView.builder(
        //     itemCount: restaurantCards.length,
        //     itemBuilder: (context, index) {
        //       final restaurant = restaurantCards[index];
        //       //final photoUrl = getImage(restaurantCards[index])
        //       return Container(
        //         margin: EdgeInsets.fromLTRB(8, 0, 8, 12),
        //         padding: EdgeInsets.all(8),
        //         decoration: BoxDecoration(
        //           color: Colors.white,
        //           borderRadius: BorderRadius.circular(8),
        //         ),
        //         // child: ListTile(
        //         //   leading: photoUrl.isNotEmpty
        //         //       ? SizedBox(
        //         //     width: 60,
        //         //     height: 60,
        //         //     child: ClipRRect(
        //         //       borderRadius: BorderRadius.circular(8),
        //         //       child: Image.network(
        //         //         photoUrl,
        //         //         fit: BoxFit.cover,
        //         //       ),
        //         //     ),
        //         //   )
        //         //       : const Icon(Icons.image),
        //         //   title: Text(
        //         //     restaurant.name ?? '',
        //         //     style: TextStyle(
        //         //       fontWeight: FontWeight.bold,
        //         //     ),
        //         //   ),
        //         //   subtitle: Column(
        //         //     crossAxisAlignment: CrossAxisAlignment.start,
        //         //     children: [
        //         //       Text(
        //         //         restaurant.vicinity ?? '',
        //         //         style: TextStyle(
        //         //           color: Colors.black87,
        //         //         ),
        //         //       ),
        //         //       Row(
        //         //         children: [
        //         //           Text("Yelp: "),
        //         //           Icon(Icons.star, color: Colors.yellow),
        //         //           Text(
        //         //             '${restaurant.rating ?? '-'}',
        //         //             style: TextStyle(fontWeight: FontWeight.bold),
        //         //           ),
        //         //           Text(" | Crave: "),
        //         //           Icon(Icons.star, color: Colors.yellow),
        //         //           Text('Not Rated'),
        //         //         ],
        //         //       ),
        //         //     ],
        //         //   ),
        //         //   onTap: () {
        //         //     // Navigate to the restaurant details page
        //         //   },
        //         // ),
        //       );
        //     },
        //   ),
        // ),
      ),
    );
  }

  // Widget _redoSearchAreaButton() {
  //   return AnimatedOpacity(
  //     opacity: _isMapMoving ? 1.0 : 0.0,
  //     duration: const Duration(milliseconds: 1000),
  //     child: Padding(
  //       padding: const EdgeInsets.fromLTRB(0, 120, 20, 0),
  //       child: Align(
  //         alignment: Alignment.topCenter,
  //         child: SizedBox(
  //           height: 30,
  //           child: ElevatedButton.icon(
  //             onPressed: () async {
  //               _clearMarkers();
  //               _searchNearbyPlaces();
  //               _isMapMoving = false;
  //             },
  //             icon: Icon(
  //               Icons.refresh,
  //               color: Colors.white,
  //               size: 16,
  //             ),
  //             label: const Text(
  //               "Redo Search in this Area",
  //               style: TextStyle(
  //                 color: Colors.white,
  //                 fontFamily: "Arial",
  //                 fontSize: 12,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //             style: ElevatedButton.styleFrom(
  //               primary: Colors.orange,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(20.0),
  //               ),
  //               padding: const EdgeInsets.symmetric(
  //                 vertical: 8.0,
  //                 horizontal: 16.0,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _initialMap() {
    print("_initialMap value: _drawPolygonEnabled is ${_drawPolygonEnabled}");
    return GoogleMap(
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      initialCameraPosition: CameraPosition(
        target: LatLng(
            widget.currentPosition.latitude, widget.currentPosition.longitude),
        zoom: 14.4,
      ),
      markers: Set.from(_markers),
      onMapCreated: _onInitialMapCreated,
      onCameraMove: _onCameraMove,
      //onCameraIdle: _onCameraIdle,
    );
  }

  Widget _drawMap() {
    print("_drawMap value: _drawPolygonEnabled is ${_drawPolygonEnabled}");
    return GestureDetector(
      onPanUpdate: _drawPolygonEnabled ? _onPanUpdate : null,
      onPanEnd: _drawPolygonEnabled ? _onPanEnd : null,
      child: GoogleMap(
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.currentPosition.latitude,
              widget.currentPosition.longitude),
          zoom: 14.4,
        ),
        polygons: _polygons,
        polylines: _polyLines,
        onMapCreated: _onDrawMapCreated,
        markers: _markersFromDrawArea,
      ),
    );
  }

  Widget _stopDrawing() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 160, 20, 0),
      child: Align(
        alignment: Alignment.topRight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(116),
          child: SizedBox(
            child: ElevatedButton(
              onPressed: _toggleDrawing,
              child: Icon(
                _drawPolygonEnabled ? Icons.cancel : Icons.edit,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _stopDrawing() {
  //   return Padding(
  //     padding: const EdgeInsets.fromLTRB(0, 160, 20, 0),
  //     child: Align(
  //       alignment: Alignment.topRight,
  //       child: ClipRRect(
  //         borderRadius: BorderRadius.circular(15),
  //         child: ElevatedButton(
  //           style: ElevatedButton.styleFrom(
  //             primary: Colors.orange,
  //             onPrimary: Colors.white,
  //           ),
  //           onPressed: _toggleDrawing,
  //           child: Icon(
  //             _drawPolygonEnabled ? Icons.cancel : Icons.edit,
  //             color: Colors.white,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _leaveDrawingModeButton() {
  //   return AnimatedOpacity(
  //     opacity: _isMapMoving ? 1.0 : 0.0,
  //     duration: const Duration(milliseconds: 1000),
  //     child: Padding(
  //       padding: const EdgeInsets.fromLTRB(0, 120, 20, 0),
  //       child: Align(
  //         alignment: Alignment.topRight,
  //         child: SizedBox(
  //           height: 30,
  //           child: ElevatedButton(
  //             child: const Text(
  //               "back",
  //               style: TextStyle(
  //                 color: Colors.white,
  //                 fontFamily: "Arial",
  //                 fontSize: 14,
  //               ),
  //             ),
  //             onPressed: () {
  //               _switchToInitialMode();
  //               _drawingModeOff();
  //             },
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _leaveDrawingModeButton() {
    return AnimatedOpacity(
      opacity: _isMapMoving ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 1000),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 120, 20, 0),
        child: Align(
          alignment: Alignment.topRight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 30,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.orange,
                ),
                child: const Text(
                  "back",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Arial",
                    fontSize: 14,
                  ),
                ),
                onPressed: () {
                  _switchToInitialMode();
                  _drawingModeOff();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _restaurantListView() {
  //   return AnimatedOpacity(
  //     opacity: _isMapMoving ? 1.0 : 0.0,
  //     duration: const Duration(milliseconds: 1000),
  //     child: Padding(
  //       padding: const EdgeInsets.fromLTRB(0, 150, 20, 0),
  //       child: Align(
  //         alignment: Alignment.topRight,
  //         child: SizedBox(
  //           height: 30,
  //           child: ElevatedButton(
  //             child: const Text(
  //               "back",
  //               style: TextStyle(
  //                 color: Colors.white,
  //                 fontFamily: "Arial",
  //                 fontSize: 14,
  //               ),
  //             ),
  //             onPressed: () {
  //               rest_result == null ? CircularProgressIndicator() :
  //               Navigator.push(context, MaterialPageRoute(
  //                 builder: (context) =>
  //                     RestaurantListPage(rest_result: rest_result),
  //               ),);
  //             },
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  void initState() {
    super.initState();
    _controllerInitial = Completer();
    _controllerDraw = Completer();
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

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: _shouldDrawMap ? Stack(
  //         children: [
  //           //_mapToggle(_shouldDrawMap),
  //           _drawMap(),
  //           _stopDrawing(),
  //           _openDrawerButton(),
  //           _leaveDrawingModeButton(),
  //         ] )
  //         : Stack(
  //         children: [
  //         _initialMap(),
  //         _openDrawerButton(),
  //         _searchBar(),
  //         _drawButton(),
  //         _redoSearchAreaButton(),
  //         _restaurantListView(),
  //       ]
  //     ),
  //   );

  Widget _buildPanel(ScrollController scrollController) {
    List<PlacesSearchResult> _restaurants = [];
    if (rest_result != null) {
      _restaurants = rest_result!.results;
    }
    return RefreshIndicator(
      onRefresh: () async {
        // load new data
      },
      child: Container(
        decoration: const BoxDecoration(
          color: const Color.fromARGB(48, 145, 140, 140),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: 100,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                'A list of the searched restaurants',
                style: TextStyle(
                  //fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
            Expanded(
              child: rest_result == null
                  ? const Center(
                child: Text("Nothing to see here"),
              )
                  : ListView.builder(
                controller: scrollController,
                itemCount: _restaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = _restaurants[index];
                  final photoUrl =
                  restaurant.photos != null && restaurant.photos!.isNotEmpty
                      ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=100&photoreference=${restaurant.photos![0].photoReference}&key=${googleMapsAPIKey}'
                      : '';
                  return Container(
                    margin: EdgeInsets.fromLTRB(8, 0, 8, 12),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: photoUrl.isNotEmpty
                          ? SizedBox(
                        width: 60,
                        height: 60,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                          : const Icon(Icons.image),
                      title: Text(
                        restaurant.name ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurant.vicinity ?? '',
                            style: TextStyle(
                              color: Colors.black87,
                            ),
                          ),
                          Row(
                            children: [
                              Text("Google: "),
                              Icon(Icons.star, color: Colors.yellow),
                              Text(
                                '${restaurant.rating ?? '-'}',
                                style:
                                TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(" | Crave: "),
                              Icon(Icons.star, color: Colors.yellow),
                              Text('Not Rated'),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        // Navigate to the restaurant details page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RestaurantPage(placesId: restaurant.placeId,),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _drawScreen(){
    return Stack(
        children: [
        //_mapToggle(_shouldDrawMap),
        _drawMap(),
        _stopDrawing(),
        //_openDrawerButton(),
      _leaveDrawingModeButton(),
      ],
    );
  }

  Widget _initialScreen(){
    return Stack(
      children: [
        _initialMap(),
        _redoSearchAreaButton(),
        _restaurantBottomCardBuilder(restaurantCards),
        //_openDrawerButton(),
        _searchBar(),
        _drawButton(),
        _redoSearchAreaButton(),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: SlidingUpPanel(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),

          ),
          minHeight: 20,
          panelBuilder: (scrollController) => _buildPanel(scrollController),
          body: _shouldDrawMap
              ? _drawScreen()
              : _initialScreen()
          ),

        ),
      );
  }
}
