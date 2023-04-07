import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../apiKeys.dart';
import '../../screens/RestaurantListPage.dart';
import '../../screens/home_screen.dart';

final places = GoogleMapsPlaces(apiKey: googleMapsAPIKey);
//static var results_checkkkk;

class MapScreen extends StatefulWidget {
  final Position currentPosition;
  const MapScreen({Key? key, required this.currentPosition}) : super(key: key);
  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  late Completer<GoogleMapController> _controllerInitial;
  late Completer<GoogleMapController> _controllerDraw;
  GoogleMapController? _currentController;
  PlacesSearchResponse? rest_result;
  final List<Marker> _markers = [];
  bool _isMapMoving = false;
  late LatLng _center;
  Position? currentPosition;
  bool _shouldDrawMap = false;

  final Set<Polygon> _polygons = HashSet<Polygon>();
  Set<Polyline> _polyLines = HashSet<Polyline>();
  bool _isPolygonNull = true;
  bool _drawPolygonEnabled = false;
  late final Set<Marker> _markersFromDrawArea = {};
  final List<LatLng> _userPolyLinesLatLngList = [];
  bool _clearDrawing = false;
  final List<LatLng> _polygonPoints = [];
  int? _lastXCoordinate, _lastYCoordinate;


  Future<void> _searchNearbyPlaces() async {
    final location = Location(lat: _center.latitude, lng: _center.longitude);
    final result = await places.searchNearbyWithRankBy(location, "distance",
        type: 'restaurant');
    rest_result = result;

    PlacesSearchResponse _response = await places.searchNearbyWithRankBy(
        Location(
            lat: widget.currentPosition.latitude,
            lng: widget.currentPosition.longitude),
        "distance",
        type: "restaurant");

    // final List<PlacesSearchResult> _filteredResults =
    // _response.results.where((result) {
    //   return _userPolyLinesLatLngList.contains(LatLng(
    //     result.geometry!.location.lat,
    //     result.geometry!.location.lng,
    //   ));
    // }).toList();

    setState(() {
      _markers.addAll(result.results.map((restaurant) =>
          Marker(
            markerId: MarkerId(restaurant.placeId),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure),
            position: LatLng(restaurant.geometry!.location.lat,
                restaurant.geometry!.location.lng),
            infoWindow: InfoWindow(
                title: restaurant.name,
                snippet:
                "Ratings: ${restaurant.rating?.toString() ??
                    "Not Rated"}\nPrice: ${restaurant.priceLevel?.toString()}"),
          )));
    });
  }

  Future<void> _retrieveRestaurantsInDrawnArea() async {
    // PlacesSearchResponse _response = await _places.searchNearbyWithRadius(
    //     Location(lat: widget.currentPosition.latitude, lng: widget.currentPosition.longitude),
    //     15000,
    //     type: "restaurant");

    PlacesSearchResponse _response = await places.searchNearbyWithRadius(
        Location(
            lat: widget.currentPosition.latitude,
            lng: widget.currentPosition.longitude),
        15000,
        type: "restaurant");

    final List<PlacesSearchResult> _filteredResults =
    _response.results.where((result) {
      return _userPolyLinesLatLngList.contains(LatLng(
        result.geometry!.location.lat,
        result.geometry!.location.lng,
      ));
    }).toList();

    Set<Marker> _restaurantMarkers = _filteredResults
        .map((result) =>
        Marker(
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

  void _clearMarkers() {
    setState(() {
      _markers.clear();

    });
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _center = position.target;
      const Duration(milliseconds: 1500);
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
    if (_controllerDraw == null) {
      _controllerDraw = Completer();
    }
    _controllerDraw.future.then((controller) {
      setState(() {
        _currentController = controller;
        _shouldDrawMap = true;
      });
    });
  }

  _switchToInitialMode() {
    if (_controllerInitial == null) {
      _controllerInitial = Completer();
    }
    _controllerInitial.future.then((controller) {
      setState(() {
        _currentController = controller;
        _shouldDrawMap = false;
      });
    });
  }

  _toggleDrawing() {
    _clearMarkers();
    //setState(() => _shouldDrawMap = true);
    setState(() {
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
      _polyLines.clear();
      _polygons.clear();
      _userPolyLinesLatLngList.clear();
    });
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
        _searchNearbyPlaces();
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
          polygonId: const PolygonId('user_polygon'),
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
        const Duration(seconds: 3);
        //Navigator.pop(context);
        _clearDrawing = true;
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

  // Widget _searchBar() {
  //   return const Padding(
  //       padding: EdgeInsets.fromLTRB(50, 50, 15, 0), child: LocationSearch());
  // }

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
      duration: const Duration(milliseconds: 1000),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 120, 20, 0),
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
                  primary: Colors.orange,
                  onPrimary: Colors.white,
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
          color: const Color.fromARGB(30, 11, 11, 11),
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
                // color: Colors.black12,
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
                      color: Colors.white,
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
                                  Text("Yelp: "),
                                  Icon(Icons.star, color: Colors.yellow),
                                  Text(
                                    '${restaurant.rating ?? '-'}',
                                    style: TextStyle(fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Text(" |  Crave: "),
                                  Icon(Icons.star, color: Colors.yellow),
                                  Text('Not Rated'),
                              ],
                            ),
                          ],
                        ),
                      onTap: () {
                        // Navigate to the restaurant details page
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),),
        child: SlidingUpPanel(

          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
          ),
          minHeight: 20,
          panelBuilder: (scrollController) => _buildPanel(scrollController),
          body: _shouldDrawMap
              ? Stack(
            children: [
              //_mapToggle(_shouldDrawMap),
              _drawMap(),
              _stopDrawing(),
              //_openDrawerButton(),
              _leaveDrawingModeButton(),
            ],
          )
              : Stack(
            children: [
              _initialMap(),
              //_openDrawerButton(),
              //_searchBar(),
              _drawButton(),
              _redoSearchAreaButton(),
            ],
          ),
        ),
      ),
    );
  }
}

