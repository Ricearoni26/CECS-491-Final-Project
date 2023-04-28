import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math' as math;
import 'dart:convert';
import 'package:crave_app_final/screens/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../apiKeys.dart';
import '../../screens/RestaurantListPage.dart';
import '../../screens/home_screen.dart';
//import 'package:visibility_detector/visibility_detector.dart';
//import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
//import 'package:google_maps_webservice/places.dart' show PlacesDetailsResponse, PlacesDetailsResult, GoogleMapsPlaces;
// import 'package:google_maps_webservice/directions.dart' show DirectionsResult, GoogleMapsDirections, TravelMode;
import 'package:google_maps_webservice/directions.dart' as directions;
import 'SearchScreen.dart';
import 'package:url_launcher/url_launcher.dart';


final places = GoogleMapsPlaces(apiKey: googleMapsAPIKey);

class MapScreen extends StatefulWidget {
  final Position currentPosition;
  const MapScreen({Key? key, required this.currentPosition}) : super(key: key);
  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  // working variables with proper initialization
  //final GoogleMapsDirections directions = GoogleMapsDirections(apiKey: googleMapsAPIKey);
  final gmDirections = directions.GoogleMapsDirections(apiKey: googleMapsAPIKey);

  final Completer<GoogleMapController> _controllerCompleter = Completer();
  GoogleMapController? _currentController;
  PlacesSearchResponse? restaurantResultsList;
  List<Marker> _markers = [];
  bool _isMapMoving = false;
  late LatLng _center;
  Position? currentPosition;
  Set<Polygon> _polygons = HashSet<Polygon>();
  Set<Polyline> _polyLines = HashSet<Polyline>();
  bool _drawPolygonEnabled = false;
  Set<Marker> _markersFromDrawArea = {};
  List<LatLng> _userPolyLinesLatLngList = [];
  bool _clearDrawing = false;
  final List<LatLng> _polygonPoints = [];
  int? _lastXCoordinate, _lastYCoordinate;
  bool isSearchBarSelected = false;
  List<Widget> restaurantCards = [];
  bool showButton = false;
  final double latitudeOffset = 0.0065;
  bool _bottomCardsVisible = false;
  PageController? _pageController;
  late List<PlacesSearchResult> _restaurants;
  bool isAnimatingPageView = false;
  int _currentMarkerIndex = -1;
  bool isSelected = false;

  // variables still being tested
  //bool _showCurrentLocationButton = false;
  List<List<Photo>> restaurantPhotos = [];
  //Map<String, String> restaurantPhotos = {};

  void _onMarkerTap(PlacesSearchResult restaurant) {
    int index = _restaurants.indexWhere((element) => element.placeId == restaurant.placeId);
    if (index != -1) {
      setState(() {
        _bottomCardsVisible = true;
        _currentMarkerIndex = index;
        _updateMarkers();
      });

      if (_pageController!.hasClients) {
        isAnimatingPageView = true;
        _pageController?.animateToPage(
          index,
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease,
        ).then((_) {
          isAnimatingPageView = false;
        });
      }
    }
  }

  Future<void> _getRestaurantPhotos(int index, String placeId) async {
    final PlacesDetailsResponse response = await places.getDetailsByPlaceId(placeId);

    if (response.isOkay) {
      restaurantPhotos[index] = response.result.photos.toList();
    }
  }

  Future<void> _searchNearbyPlaces() async {
    final location = Location(lat: _center.latitude, lng: _center.longitude);
    final result = await places.searchNearbyWithRankBy(
        location, "distance",
        type: 'restaurant',
        keyword: 'restaurant',
        // keyword: 'restaurant,fast food',
    );
    restaurantResultsList = result;
    int numOfResults = result.results.length;
    int? restaurantIndex = 1;

    print(result.results[0].toJson());

    if (result.isOkay) {
      restaurantPhotos = List.generate(numOfResults, (_) => []);
      final photoFutures = <Future>[];
      for (var i = 0; i < numOfResults; ++i) {
        photoFutures.add(_getRestaurantPhotos(i, result.results[i].placeId));
      }
      await Future.wait(photoFutures);
      _restaurants = result.results;
      setState(() {
        restaurantCards = [];
        for (var i = 0; i < 20; i++) {
          PlacesSearchResult restaurant = result.results[i];
          bool isOpen = restaurant.openingHours?.openNow ?? false;
          restaurantCards.add(_bottomCards(
            restaurantPhotos[i],
            restaurant.geometry!.location.lat,
            restaurant.geometry!.location.lng,
            restaurantNameParameters(restaurant.name),
            restaurant,
            isOpen,
            restaurantIndex! + i,
          ));
        }
      });
    }
    _updateMarkers();
  }

  void _updateMarkers() {
    setState(() {
      _markers = _restaurants.asMap().entries.map((entry) {
        int index = entry.key;
        PlacesSearchResult restaurant = entry.value;
        return Marker(
          markerId: MarkerId(restaurant.placeId),
          onTap: () => _onMarkerTap(restaurant),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            index == _currentMarkerIndex ? BitmapDescriptor.hueRed : BitmapDescriptor.hueAzure,
          ),
          zIndex: index == _currentMarkerIndex ? 1 : 0,
          position: LatLng(
            restaurant.geometry!.location.lat,
            restaurant.geometry!.location.lng,
          ),
        );
      }).toList();
    });
  }

  String restaurantNameParameters(String restaurantName) {
    int index = restaurantName.indexOf("(");
    if (index != -1) {
      restaurantName = restaurantName.substring(0, index);
    }
    return restaurantName;
  }

  List<String> getImage(List<Photo> photos) {
    List<String> urls = [];
    const baseUrl = 'https://maps.googleapis.com/maps/api/place/photo';
    const maxWidth = '400';
    const maxHeight = '200';
    for (var i = 0; i < 3; i++) {
      if (i < photos.length) {
        urls.add('$baseUrl?maxwidth=$maxWidth&maxheight=$maxHeight&photoreference=${photos[i].photoReference}&key=$googleMapsAPIKey');
      } else {
        urls.add('https://via.placeholder.com/130x130.png?text=No+Image');
      }
    }
    return urls;
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
            markerId: MarkerId(result.name),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            infoWindow: InfoWindow(
                title: result.name,
                snippet: "Ratings: ${result.rating?.toString() ?? "Not Rated"}"),
            position: LatLng(result.geometry!.location.lat, result.geometry!.location.lng)))
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

  void _clearMarkers() {
    setState(() {
      _markers.clear();
      restaurantCards = [];
    });
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _center = position.target;
      const Duration(milliseconds: 2000);
      _isMapMoving = true;
    });
  }

  _clearPolygons() {
    setState(() {
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
      await _controllerCompleter.future;
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
        _clearMarkers;
        //_retrieveRestaurantsInDrawnArea();
        //const Duration(seconds: 3);
        //Navigator.pop(context);
        _clearDrawing = true;
        //_searchNearbyPlaces();
        //_retrieveRestaurantsInDrawnArea();
        print("_onPanEnd completed");
      });
    }
  }

  void _updateCameraPosition(CameraPosition cameraPosition){
    final CameraUpdate cameraUpdate = CameraUpdate.newCameraPosition(cameraPosition);
    _currentController!.animateCamera(cameraUpdate);
  }

  Widget _searchBar() {
    return GestureDetector(
      onTap: () {
        isSearchBarSelected = true;
        Navigator.of(context).push(_createPageRoute());
      },

      child: Padding(
        padding: const EdgeInsets.fromLTRB(23, 58, 23, 0),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: const [
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Icon(Icons.search),
              ),
              SizedBox(width: 10),
              Text(
                'Enter a Restaurant',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addSearchedMarker(PlaceDetails selectedPlaceInfo) {
    restaurantCards = [];
    restaurantCards.add(_singleCard(selectedPlaceInfo));
    final marker = Marker(
      markerId: MarkerId(selectedPlaceInfo.placeId!),
      position: LatLng(selectedPlaceInfo.geometry!.location.lat, selectedPlaceInfo.geometry!.location.lng),
      infoWindow: InfoWindow(title: selectedPlaceInfo.name),
      onTap: () => setState(() {
        _bottomCardsVisible = true;
      }),
    );

    setState(() {
      _markers.add(marker);
      _restaurantBottomCardBuilder(restaurantCards);
    });
  }

  Route _createPageRoute() {
    _markers.clear();
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SearchScreen(
        currentPosition: widget.currentPosition,
        updateCameraPosition: _updateCameraPosition,
        selectedPlaceInfo: _addSearchedMarker,
        isSearchBarSelected: isSearchBarSelected,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, -1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Widget _drawButton() {
    return AnimatedOpacity(
      opacity: _isMapMoving ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 1000),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 120, 23, 0),
        child: Align(
          alignment: Alignment.topRight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 25,
              child: ElevatedButton(
                child: _drawPolygonEnabled ? const Text(
                  "Back",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Arial",
                    fontSize: 12,
                  ),
                ) : const Text(
                  "Draw",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Arial",
                    fontSize: 12,
                  ),
                ),
                onPressed: () {
                  _drawPolygonEnabled = !_drawPolygonEnabled;
                  _clearMarkers();
                  //_clearPolygons();
                  print("Draw button was pressed");
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _redoSearchAreaButton() {
    showButton = doesBoundaryExist();
    return AnimatedOpacity(
      opacity: _isMapMoving ? 1.0 : 0.0,
      duration: Duration(milliseconds: 1000),
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 120, 0, 0),
        child: Align(
          alignment: Alignment.topCenter,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 25,
              child: ElevatedButton(
                child: _drawPolygonEnabled && showButton ? const Text(
                  "Search This Boundary",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Arial",
                    fontSize: 12,
                  ),
                ) : !_drawPolygonEnabled && !showButton ? const Text(
                  "Redo Search Area",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Arial",
                    fontSize: 12,
                  ),
                ) : const Text(
                    "Search This Boundary",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Arial",
                      fontSize: 12,
                    ),
                ),
                onPressed: () async {
                  _clearMarkers();
                  if ((_drawPolygonEnabled && showButton) || (!_drawPolygonEnabled && showButton)) {
                    _searchNearbyPlaces();
                  } else{
                    _clearPolygons();
                    _searchNearbyPlaces();
                  }
                  _bottomCardsVisible = false;
                  _drawPolygonEnabled = false;
                  _currentMarkerIndex = -1;
                  _isMapMoving = false;
                  _restaurantBottomCardBuilder(restaurantCards);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _gotoLocation (double lat, double long, PlacesSearchResult restaurant) async {
    GoogleMapController? controller = _currentController;
    //controller?.hideMarkerInfoWindow(_markers.last.markerId);
    //MarkerId lastMarker = _markers.last.markerId;
    //controller?.showMarkerInfoWindow(lastMarker);
    controller?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat - latitudeOffset, long),
          zoom: 15,
          tilt: 50.0,
        )));
    //_onMarkerTap(restaurant);
  }

  Future<void> _gotoSingleCardLocation (double lat, double long, PlaceDetails restaurant) async {
    GoogleMapController? controller = _currentController;
    //controller?.hideMarkerInfoWindow(_markers.last.markerId);
    //controller?.showMarkerInfoWindow(_markers.last.markerId);
    controller?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat - latitudeOffset, long),
          zoom: 15,
          tilt: 50.0,
        )));
    //_onMarkerTap(restaurant);
  }

  // Future<void> _gotoLocation (double lat, double long) async {
  //   GoogleMapController? controller = await _currentController;
  //   controller?.animateCamera(CameraUpdate.newCameraPosition(
  //       CameraPosition(
  //         target: LatLng(lat, long),
  //         zoom: 15,
  //         tilt: 50.0,
  //       )));
  // }

  // Widget _bottomCardStyle3(List<Photo> photos, String restaurantName, String rating, String vicinity) {
  //   return SizedBox(
  //     width: MediaQuery.of(context).size.width,
  //     child: Material(
  //       color: Colors.white,
  //       elevation: 14,
  //       borderRadius: BorderRadius.circular(24.0),
  //       shadowColor: const Color(0x802196F3),
  //       child: Stack(
  //         children: [
  //           SizedBox(
  //             width: double.infinity,
  //             height: double.infinity,
  //             child: ClipRRect(
  //               borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
  //               child: Image.network(
  //                 getImage(photos),
  //                 fit: BoxFit.cover,
  //               ),
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.all(16.0),
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.end,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   restaurantName,
  //                   style: const TextStyle(
  //                     fontSize: 24,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                   maxLines: 1,
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //                 const SizedBox(height: 5),
  //                 Row(
  //                   children: [
  //                     const Icon(
  //                       Icons.star,
  //                       color: Colors.orange,
  //                       size: 20,
  //                     ),
  //                     const SizedBox(width: 5),
  //                     Text(
  //                       rating,
  //                       style: const TextStyle(
  //                         fontSize: 16,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 5),
  //                 Text(
  //                   vicinity,
  //                   style: TextStyle(
  //                     fontSize: 16,
  //                     color: Colors.grey[600],
  //                   ),
  //                   maxLines: 2,
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  String getPriceLevel(PriceLevel? price) {
    String result = "";
    if (price == PriceLevel.inexpensive) {
      result = "\$";
    } else if (price == PriceLevel.moderate) {
      result = "\$\$";
    } else if (price == PriceLevel.expensive) {
      result = "\$\$\$";
    } else if (price == PriceLevel.veryExpensive) {
      result = "\$\$\$\$";
    } else {
      result = "\$\$";
    }
    return result;
  }

  Widget _bottomCardStyle(List<Photo> photos, String restaurantName,
      String rating, String vicinity, bool isOpen, int? restaurantIndex,
      String price, LatLng latLng){
    List<String> photoURL = getImage(photos);
    int numberOfPhotos = photoURL.length;
    String city = vicinity.split(',').skip(1).take(1).first;
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Material(
          color: Colors.white,
          elevation: 14,
          borderRadius: BorderRadius.circular(8.0),
          shadowColor: Colors.white70,
          child: Column(
            children: [
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: Container(
                      width: 130,
                      height: 120,
                      padding: const EdgeInsets.all(4),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        child: Image.network(
                          photoURL[0],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      width: 130,
                      height: 120,
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        child: Image.network(
                          photoURL[1],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      width: 130,
                      height: 120,
                      padding: const EdgeInsets.all(4),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        child: Image.network(
                          photoURL[2],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurantIndex == null ? restaurantName : "$restaurantIndex. $restaurantName",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Text(
                                "Google: ",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const Icon(
                                Icons.star,
                                color: Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                rating,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const Text(
                                " | Yelp: ",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const Icon(
                                Icons.star,
                                color: Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                rating,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const Text(
                                " | Crave: ",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const Icon(
                                Icons.star,
                                color: Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                rating,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_pin,
                                //color: Colors.g,
                                size: 20,
                              ),
                              Text(
                                "$city",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Text('•'),
                              Text(
                                isOpen ? 'Open' : 'Closed',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isOpen ? Colors.green : Colors.red,
                                ),
                              ),
                              const Text('•'),
                              Text(
                                price == "" ? "" : "$price",
                              ),
                            ],
                          ),
                          const SizedBox(height: 10,),
                          OutlinedButton(
                            onPressed: () {
                              // Handle the 'Get Directions' button press here
                              navigateToRestaurant(context, latLng);
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.black54), // Set the border color
                            ),
                            child: const Center(
                              child: Text(
                                'Get Directions',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontFamily: "Arial",
                                  fontSize: 23,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _bottomCards(List<Photo> image, double lat, double long, String restaurantName, PlacesSearchResult? restaurant) {
  //   return GestureDetector(
  //     onTap: () {
  //       _gotoLocation(lat, long, restaurant!);
  //       print("card was tapped");
  //     },
  //     child: _bottomCardStyle(image,
  //         restaurantName,
  //         restaurant!.rating.toString(),
  //         restaurant.vicinity!),
  //   );
  // }

  Widget _bottomCards(List<Photo> image, double lat, double long,
      String restaurantName, PlacesSearchResult? restaurant, bool isOpen,
      int? restaurantIndex) {
    String price = getPriceLevel(restaurant?.priceLevel);
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.down,
      onDismissed: (direction) {
        setState(() {
          _bottomCardsVisible = false;
        });
      },
      child: GestureDetector(
        onTap: () {
          // add the Hadi's Details Page
          _gotoLocation(lat, long, restaurant!);
          print("card was tapped");
        },
        child: _bottomCardStyle(
            image,
            restaurantName,
            restaurant!.rating.toString(),
            restaurant.vicinity!,
            isOpen,
            restaurantIndex,
            price,
            LatLng(
                restaurant.geometry!.location.lat,
                restaurant.geometry!.location.lng
            ),
        ),
      ),
    );
  }

  Widget _singleCard(PlaceDetails selectedPlaceInfo) {
    bool isOpen = selectedPlaceInfo.openingHours?.openNow ?? false;
    String price = getPriceLevel(selectedPlaceInfo.priceLevel);
    _bottomCardsVisible = true;
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.down,
      onDismissed: (direction) {
        setState(() {
          _bottomCardsVisible = false;
        });
      },
      child: GestureDetector(
        onTap: () {
          _gotoSingleCardLocation(
              selectedPlaceInfo.geometry!.location.lat,
              selectedPlaceInfo.geometry!.location.lng,
              selectedPlaceInfo);
          print("card was tapped");
        },
        child: _bottomCardStyle(
            selectedPlaceInfo.photos,
            selectedPlaceInfo.name,
            selectedPlaceInfo.rating.toString(),
            selectedPlaceInfo.vicinity!,
            isOpen,
            null,
            price,
            LatLng(
                selectedPlaceInfo.geometry!.location.lat,
                selectedPlaceInfo.geometry!.location.lng
            ),
        ),
        // child: Padding(
        //   padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        //   child: SizedBox(
        //     width: MediaQuery.of(context).size.width,
        //     child: Material(
        //       color: Colors.white,
        //       elevation: 14,
        //       borderRadius: BorderRadius.circular(24.0),
        //       shadowColor: Color(0x802196F3),
        //       child: Row(
        //         children: [
        //           ClipRRect(
        //             borderRadius: BorderRadius.only(
        //               topLeft: Radius.circular(24.0),
        //               bottomLeft: Radius.circular(24.0),
        //             ),
        //             child: SizedBox(
        //               width: 130,
        //               height: 130,
        //               child: Image.network(
        //                 getImage(selectedPlaceInfo.photos),
        //                 fit: BoxFit.cover,
        //               ),
        //             ),
        //           ),
        //           Expanded(
        //             child: Padding(
        //               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        //               child: Column(
        //                 crossAxisAlignment: CrossAxisAlignment.start,
        //                 children: [
        //                   Text(
        //                     restaurantName,
        //                     style: TextStyle(
        //                       fontSize: 20,
        //                       fontWeight: FontWeight.bold,
        //                     ),
        //                     maxLines: 1,
        //                     overflow: TextOverflow.ellipsis,
        //                   ),
        //                   SizedBox(height: 5),
        //                   Row(
        //                     children: [
        //                       Icon(
        //                         Icons.star,
        //                         color: Colors.orange,
        //                         size: 20,
        //                       ),
        //                       SizedBox(width: 5),
        //                       Text(
        //                         restaurant.rating.toString(),
        //                         style: TextStyle(
        //                           fontSize: 16,
        //                         ),
        //                       ),
        //                     ],
        //                   ),
        //                   SizedBox(height: 5),
        //                   Text(
        //                     restaurant.vicinity!,
        //                     style: TextStyle(
        //                       fontSize: 16,
        //                       color: Colors.grey[600],
        //                     ),
        //                     maxLines: 2,
        //                     overflow: TextOverflow.ellipsis,
        //                   ),
        //                 ],
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
      ),
    );
  }

  void _onPageChanged() {
    if (!isAnimatingPageView) {
      _currentMarkerIndex = _pageController!.page?.round() ?? 0;
      final restaurant = _restaurants[_currentMarkerIndex];
      _gotoLocation(restaurant.geometry!.location.lat, restaurant.geometry!.location.lng, restaurant);
    }
    _updateMarkers();
  }

  // Widget _cards(PlacesSearchResult restaurant) {
  //   return GestureDetector(
  //     onTap: () {
  //       _gotoLocation(restaurant.geometry!.location.lat, restaurant.geometry!.location.lng, restaurant);
  //       print("card was tapped");
  //     },
  //     child: Padding(
  //       padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
  //       child: SizedBox(
  //         width: MediaQuery.of(context).size.width,
  //         child: Material(
  //           color: Colors.white,
  //           elevation: 14,
  //           borderRadius: BorderRadius.circular(24.0),
  //           shadowColor: const Color(0x802196F3),
  //           child: Row(
  //             children: [
  //               ClipRRect(
  //                 borderRadius: const BorderRadius.only(
  //                   topLeft: Radius.circular(24.0),
  //                   bottomLeft: Radius.circular(24.0),
  //                 ),
  //                 child: SizedBox(
  //                   width: 130,
  //                   height: 130,
  //                   child: Image.network(
  //                     getImage(restaurant.photos),
  //                     fit: BoxFit.cover,
  //                   ),
  //                 ),
  //               ),
  //               Expanded(
  //                 child: Padding(
  //                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         restaurantNameParameters(restaurant.name),
  //                         style: const TextStyle(
  //                           fontSize: 20,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                         maxLines: 1,
  //                         overflow: TextOverflow.ellipsis,
  //                       ),
  //                       SizedBox(height: 5),
  //                       Row(
  //                         children: [
  //                           const Icon(
  //                             Icons.star,
  //                             color: Colors.orange,
  //                             size: 20,
  //                           ),
  //                           const SizedBox(width: 5),
  //                           Text(
  //                             restaurant.rating.toString(),
  //                             style: const TextStyle(
  //                               fontSize: 16,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       const SizedBox(height: 5),
  //                       Text(
  //                         restaurant.vicinity!,
  //                         style: TextStyle(
  //                           fontSize: 16,
  //                           color: Colors.grey[600],
  //                         ),
  //                         maxLines: 2,
  //                         overflow: TextOverflow.ellipsis,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _cards(List<Photo> image, double lat,
  //     double long, String restaurantName, PlacesSearchResult restaurant) {
  //   return GestureDetector(
  //     onTap: () {
  //       _gotoLocation(lat, long, restaurant);
  //       print("card was tapped");
  //     },
  //     child: Container(
  //       width: MediaQuery.of(context).size.width * 0.9, // Set the width to 90% of the screen width
  //       child: GestureDetector(
  //         onTap: () {
  //           _gotoLocation(lat, long, restaurant);
  //           print("card was tapped");
  //         },
  //         child: Padding(
  //           padding: const EdgeInsets.only(left: 10, right: 10),
  //           child: SizedBox(
  //             width: double.infinity,
  //             height: MediaQuery.of(context).size.height / 3,
  //             child: Material(
  //               color: Colors.white,
  //               elevation: 14,
  //               borderRadius: BorderRadius.circular(24.0),
  //               shadowColor: Color(0x802196F3),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Container(
  //                     width: 180,
  //                     height: 200,
  //                     child: Padding(
  //                       padding: const EdgeInsets.all(8.0),
  //                       child: ClipRRect(
  //                         borderRadius: BorderRadius.circular(24.0),
  //                         child: Image.network(
  //                           getImage(image),
  //                           fit: BoxFit.fill,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                   FittedBox(
  //                     child: Padding(
  //                       padding: const EdgeInsets.all(8),
  //                       child: restaurantDetailsContainer(restaurantName),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //     // child: Padding(
  //     //   padding: const EdgeInsets.only(left: 10, right: 10),
  //     //   child: SizedBox(
  //     //     width: MediaQuery.of(context).size.width,
  //     //     height: MediaQuery.of(context).size.height / 3,
  //     //     // child: Material(
  //     //     //   child: Placeholder(),
  //     //     // ),
  //     //     child: Material(
  //     //       color: Colors.white,
  //     //         elevation: 14,
  //     //         borderRadius: BorderRadius.circular (24.0),
  //     //         shadowColor: Color (0x802196F3),
  //     //         child: Row(
  //     //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     //           children: [
  //     //             Container(
  //     //               width: 180,
  //     //               height: 200,
  //     //               child: Padding(
  //     //                 padding: const EdgeInsets.all(8.0),
  //     //                 child: ClipRRect (
  //     //                   borderRadius: BorderRadius.circular (24.0),
  //     //                   //child: const Placeholder(),
  //     //                   child: Image.network(getImage(image), fit: BoxFit.fill,),
  //     //                   // child: Image(
  //     //                   //   fit: BoxFit.fill,
  //     //                   //   image: Image(_image) ?
  //     //                   //   Placeholder() :
  //     //                   //   NetworkImage(_image![0].photoReference),
  //     //                   //   //image: Image.network(getImage(_image[0].photoReference)),
  //     //                   // ),
  //     //                 ),
  //     //               ),
  //     //             ),
  //     //             FittedBox(
  //     //                 child: Padding(
  //     //                   padding: const EdgeInsets.all(8),
  //     //                   child: restaurantDetailsContainer(restaurantName),
  //     //                 )
  //     //             ),
  //     //           ],
  //     //         ),
  //     //     ),
  //     //   ),
  //     // ),
  //   );
  // }

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


  // Widget restaurantDetailsContainer(String restaurantName){
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     children: [
  //       Padding(
  //           padding:  EdgeInsets.only(left: 8.0, right: 8.0),
  //           child: Container(
  //             child: Text(restaurantName,
  //               style: TextStyle(
  //                   color: Colors.black,
  //                   fontSize: 24,
  //                   fontWeight: FontWeight.bold
  //               ),
  //             ),
  //           )
  //       ),
  //       //SizedBox(height: 5.0),
  //       FittedBox(
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //           children: [
  //             Container(
  //                 child: Text(
  //                     "4.0",
  //                     style: TextStyle(
  //                       color: Colors.black,
  //                       fontSize: 18.0,
  //                     )
  //                 )
  //             )
  //           ],
  //         ),
  //       )
  //     ],
  //   );
  // }

  // Widget _restaurantBottomCardBuilder(List<Widget> restaurantCards){
  //   return Align(
  //     alignment: Alignment.bottomLeft,
  //     child: Container(
  //       margin: const EdgeInsets.symmetric(vertical: 110.0),
  //       height: MediaQuery.of(context).size.height / 2.5,
  //       //width: MediaQuery.of(context).size.width,
  //       child: PageView(
  //         scrollDirection: Axis.horizontal,
  //         children: restaurantCards,
  //       ),
  //     ),
  //   );
  // }
  Widget _restaurantBottomCardBuilder(List<Widget> restaurantCards) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 110.0),
        height: MediaQuery.of(context).size.height / 2.7,
        child: Visibility(
          visible: _bottomCardsVisible,
          child: PageView(
            controller: _pageController,
            scrollDirection: Axis.horizontal,
            children: restaurantCards,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController?.addListener(_onPageChanged);
    _restaurants = [];
  }


  // Future<void> navigateToRestaurant(BuildContext context, LatLng restaurantLocation) async {
  //   // Get the user's current location
  //   Position currentPosition = await Geolocator.getCurrentPosition();
  //   LatLng currentLocation = LatLng(currentPosition.latitude, currentPosition.longitude);
  //
  //   // Get the directions from the user's current location to the restaurant
  //   directions.DirectionsResponse response = await directions.GoogleMapsDirections(apiKey: googleMapsAPIKey)
  //       .directionsWithLocation(
  //     directions.Location(lat: currentLocation.latitude, lng: currentLocation.longitude),
  //     directions.Location(lat: restaurantLocation.latitude, lng: restaurantLocation.longitude),
  //     travelMode: directions.TravelMode.driving,
  //   );
  //
  //   // Get the distance and duration of the trip
  //   directions.Route route = response.routes.first;
  //   String distance = route.legs.first.distance.text;
  //   String duration = route.legs.first.duration.text;
  //
  //   // Create a list of map markers for the user's location and the restaurant location
  //   List<Marker> markers = [
  //     Marker(
  //       markerId: const MarkerId('Your Location'),
  //       position: LatLng(
  //         currentPosition.latitude,
  //         currentPosition.longitude,
  //       ),
  //       //GeoCoord(currentLocation.latitude, currentLocation.longitude),
  //       //label: 'Your location',
  //     ),
  //     Marker(
  //       markerId: const MarkerId('restaurant'),
  //       position: LatLng(
  //         restaurantLocation.latitude,
  //         restaurantLocation.longitude,
  //       ),
  //     ),
  //   ];
  //
  //   // Create a list of map polylines for the directions
  //   // List<LatLng> decodedPolyline = polyline.decodePolyline(response.routes.first.overviewPolyline.points);
  //   // Polyline polyline = Polyline(
  //   //   polylineId: PolylineId('polyline'),
  //   //   points: decodedPolyline,
  //   //   color: Colors.blue,
  //   // );
  //
  //   // Display the distance and duration to the user
  //   await showDialog<void>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Trip Summary'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: <Widget>[
  //             Text('Distance: $distance'),
  //             Text('Duration: $duration'),
  //           ],
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('OK'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  //
  //   // Show the map with markers and polylines
  //   await showDialog<void>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         contentPadding: EdgeInsets.zero,
  //         content: SizedBox(
  //           width: MediaQuery.of(context).size.width,
  //           height: MediaQuery.of(context).size.height,
  //           child: GoogleMap(
  //             markers: markers.toSet(),
  //             polylines: _polyLines,
  //             initialCameraPosition: CameraPosition(
  //               target: LatLng(
  //                 currentPosition.latitude,
  //                 currentPosition.longitude,
  //               ),
  //               zoom: 14,
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  //
  //   // Get realtime updates while the user is driving to the location
  //   StreamSubscription<Position> subscription = Geolocator.getPositionStream().listen((position) {
  //     // Handle the update event here
  //   });
  // }
  //
  // List<LatLng> decodePolyline(String encodedPolyline) {
  //   List<LatLng> points = [];
  //
  //   int index = 0;
  //   int len = encodedPolyline.length;
  //   int lat = 0;
  //   int lng = 0;
  //
  //   while (index < len) {
  //     int b, shift = 0, result = 0;
  //     do {
  //       b = encodedPolyline.codeUnitAt(index++) - 63;
  //       result |= (b & 0x1f) << shift;
  //       shift += 5;
  //     } while (b >= 0x20);
  //     int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
  //     lat += dlat;
  //
  //     shift = 0;
  //     result = 0;
  //     do {
  //       b = encodedPolyline.codeUnitAt(index++) - 63;
  //       result |= (b & 0x1f) << shift;
  //       shift += 5;
  //     } while (b >= 0x20);
  //     int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
  //     lng += dlng;
  //
  //     LatLng point = LatLng(lat / 1E5, lng / 1E5);
  //     points.add(point);
  //   }
  //
  //   return points;
  // }


  // Future<void> navigateToRestaurant(BuildContext context, String restaurantAddress) async {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Choose a Maps App'),
  //         content: SingleChildScrollView(
  //           child: ListBody(
  //             children: <Widget>[
  //               GestureDetector(
  //                 child: const Text('Google Maps'),
  //                 onTap: () {
  //                   Navigator.of(context).pop('googleMaps');
  //                 },
  //               ),
  //               const Padding(padding: EdgeInsets.all(8.0)),
  //               GestureDetector(
  //                 child: const Text('Apple Maps'),
  //                 onTap: () {
  //                   Navigator.of(context).pop('appleMaps');
  //                 },
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   ).then((value) async {
  //     if (value != null) {
  //       String encodedAddress = Uri.encodeComponent(restaurantAddress);
  //       String urlScheme;
  //       if (value == 'googleMaps') {
  //         urlScheme = 'https://www.google.com/maps/dir/?api=1&destination=$encodedAddress';
  //       } else {
  //         urlScheme = 'http://maps.apple.com/?daddr=$encodedAddress';
  //       }
  //       if (await canLaunch(urlScheme)) {
  //         await launch(urlScheme);
  //       } else {
  //         throw 'Could not launch $urlScheme';
  //       }
  //     }
  //   });
  // }
  //
  // Future<bool> canLaunchUrl(String url) async {
  //   return await canLaunch(url);
  // }
  //
  // Future<bool> launchUrl(String url) async {
  //   return await launch(url);
  // }


  // THIS FUNCTION BELOW WORKS
  Future<void> navigateToRestaurant(BuildContext context, LatLng restaurantLocation) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose a Maps App'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Text('Google Maps'),
                  onTap: () {
                    Navigator.of(context).pop('googleMaps');
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Text('Apple Maps'),
                  onTap: () {
                    Navigator.of(context).pop('appleMaps');
                  },
                ),
              ],
            ),
          ),
        );
      },
    ).then((value) async {
      if (value != null) {
        LatLng destination = restaurantLocation;
        String urlScheme;
        if (value == 'googleMaps') {
          urlScheme = 'https://www.google.com/maps/dir/?api=1&destination=${destination.latitude},${destination.longitude}';
        } else {
          urlScheme = 'http://maps.apple.com/?daddr=${destination.latitude},${destination.longitude}';
        }
        if (await canLaunch(urlScheme)) {
          await launch(urlScheme);
        } else {
          throw 'Could not launch $urlScheme';
        }
      }
    });
  }

  Future<bool> canLaunchUrl(Uri uri) async {
    return await canLaunch(uri.toString());
  }

  Future<bool> launchUrl(Uri uri) async {
    return await launch(uri.toString());
  }


  Widget _initialMap() {
    return GestureDetector(
      onPanUpdate: _drawPolygonEnabled ? _onPanUpdate : null,
      onPanEnd: _drawPolygonEnabled ? _onPanEnd : null,
      child: GoogleMap(
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(
              widget.currentPosition.latitude, widget.currentPosition.longitude),
          zoom: 14.4,
        ),
        markers: _drawPolygonEnabled ? _markersFromDrawArea : Set.from(_markers),
        polygons: _polygons,
        polylines: _polyLines,
        onMapCreated: (GoogleMapController controller) {
          _controllerCompleter.complete(controller);
          _currentController = controller;
        },
        onCameraMove: _onCameraMove,
        //onCameraIdle: _onCameraIdle,
      ),
    );
  }

  // Widget _stopDrawing() {
  //   return Padding(
  //     padding: const EdgeInsets.fromLTRB(0, 160, 20, 0),
  //     child: Align(
  //       alignment: Alignment.topRight,
  //       child: ClipRRect(
  //         borderRadius: BorderRadius.circular(116),
  //         child: SizedBox(
  //           child: ElevatedButton(
  //             onPressed: _toggleDrawing,
  //             child: Icon(
  //               _drawPolygonEnabled ? Icons.cancel : Icons.edit,
  //               color: Colors.white,
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  bool doesBoundaryExist(){
    bool result = true;
    if (_polyLines.isEmpty && _polygons.isEmpty &&
        _userPolyLinesLatLngList.isEmpty) {
      result = false;
    }
    return result;
  }

  Widget _removeBoundary() {
    showButton = doesBoundaryExist();
    return AnimatedOpacity(
      opacity: showButton && _isMapMoving ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        // margin: const EdgeInsets.fromLTRB(0, 0, 23, 0),
        margin: const EdgeInsets.only(right: 23),
        padding: const EdgeInsets.only(top: 155),
        child: Align(
          alignment: Alignment.topRight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 64,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  " Remove \nBoundary",
                  softWrap: false,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Arial",
                    fontSize: 12,
                  ),
                ),
                onPressed: () {
                  //_drawPolygonEnabled = !_drawPolygonEnabled;
                  _clearMarkers();
                  _clearPolygons();
                  print("Draw button was pressed");
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanel(ScrollController scrollController) {
    List<PlacesSearchResult> _restaurants = [];
    if (restaurantResultsList != null) {
      _restaurants = restaurantResultsList!.results;
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
              decoration: const BoxDecoration(
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
              child: restaurantResultsList == null
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
                              Text("Yelp: "),
                              Icon(Icons.star, color: Colors.yellow),
                              Text(
                                '${restaurant.rating ?? '-'}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(" | Crave: "),
                              Icon(Icons.star, color: Colors.yellow),
                              Text('Not Rated'),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        _gotoLocation(restaurant.geometry!.location.lat, restaurant.geometry!.location.lng, restaurant);
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
        //_stopDrawing(),
        _removeBoundary(),
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
          topRight: Radius.circular(16),),
        child: SlidingUpPanel(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            minHeight: 20,
            panelBuilder: (scrollController) => _buildPanel(scrollController),
            body: _initialScreen(),
        ),
      ),
    );
  }
}

class RestaurantPhoto {
  final String url;
  RestaurantPhoto({required this.url});
}

class RouteSummary {
  final String description;
  final String duration;

  RouteSummary({required this.description, required this.duration});
}

class RouteOption {
  final LatLng origin;
  final LatLng destination;
  final TravelMode mode;

  RouteOption({required this.origin, required this.destination, required this.mode});
}