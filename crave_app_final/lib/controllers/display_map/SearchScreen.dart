import 'package:crave_app_final/apiKeys.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

class SearchScreen extends StatefulWidget {
  final Position currentPosition;
  final Function(CameraPosition) updateCameraPosition;
  final Function(PlaceDetails) selectedPlaceInfo;
  final bool isSearchBarSelected;
  const SearchScreen({Key? key,
    required this.currentPosition,
    required this.updateCameraPosition,
    required this.selectedPlaceInfo,
    required this.isSearchBarSelected,})
      : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}


class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GoogleMapsPlaces _placesApi = GoogleMapsPlaces(apiKey: googleMapsAPIKey);
  List<Prediction> _predictions = [];
  late PlaceDetails _selectedPlace;
  late Position currentCameraPosition;
  late String _currentQuery;
  late bool _isSearchBarSelected;
  GoogleMapController? mapController;
  late FocusNode _searchFocusNode;
  final double metersInMile = 1609.344;
  final double latitudeOffset = 0.0025;

  @override
  void initState() {
    super.initState();
    _predictions = [];
    currentCameraPosition = widget.currentPosition;
    _isSearchBarSelected = widget.isSearchBarSelected;
    _searchFocusNode = FocusNode();
  }

  Future<List<PlaceDetails?>> fetchPlaceDetails(List<Prediction> predictions) async {
    final List<PlaceDetails?> placeDetails = [];

    for (final prediction in predictions) {
      final PlacesDetailsResponse detailsResponse = await _placesApi.getDetailsByPlaceId(prediction.placeId!);

      if (detailsResponse.isOkay) {
        placeDetails.add(detailsResponse.result);
      } else {
        print("Get place details error: ${detailsResponse.errorMessage}");
      }
    }
    return placeDetails;
  }

  Future<void> _onSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _predictions = [];
      });
      return;
    }

    final PlacesAutocompleteResponse response = await _placesApi.autocomplete(
      query,
      radius: 100000,
      origin: Location(
        lat: widget.currentPosition.latitude,
        lng: widget.currentPosition.longitude,
      ),
    );

    if (response.isOkay) {
      final Iterable<PlaceDetails?> placeDetails = await fetchPlaceDetails(response.predictions);
      final List<PlaceDetails> nonNullPlaceDetails = placeDetails.whereType<PlaceDetails>().toList();

      nonNullPlaceDetails.sort((a, b) {
        final double distanceToA = Geolocator.distanceBetween(
          widget.currentPosition.latitude,
          widget.currentPosition.longitude,
          a.geometry!.location.lat,
          a.geometry!.location.lng,
        );
        final double distanceToB = Geolocator.distanceBetween(
          widget.currentPosition.latitude,
          widget.currentPosition.longitude,
          b.geometry!.location.lat,
          b.geometry!.location.lng,
        );
        return distanceToA.compareTo(distanceToB);
      });

      setState(() {
        _predictions = nonNullPlaceDetails.map((place) {
          final double distanceMeters = Geolocator.distanceBetween(
            widget.currentPosition.latitude,
            widget.currentPosition.longitude,
            place.geometry!.location.lat,
            place.geometry!.location.lng,
          );

          return Prediction(
            description: '${place.name}\n '
                '${(distanceMeters / metersInMile).toStringAsFixed(1)} mi • '
                '${place.formattedAddress}',
            placeId: place.placeId,
          );
        }).toList();
      });
    } else {
      print("Autocomplete error: ${response.errorMessage}");
    }
  }

  Future<void> _onPredictionTap(Prediction prediction) async {
    final PlacesDetailsResponse response = await _placesApi.getDetailsByPlaceId(
        prediction.placeId!);
    if (response.isOkay) {
      setState(() {
        _selectedPlace = response.result;
        _currentQuery = prediction.description!;
        _predictions = [];
      });

      final CameraPosition cameraPosition = CameraPosition(
        target: LatLng(
          _selectedPlace!.geometry!.location.lat - latitudeOffset,
          _selectedPlace!.geometry!.location.lng,
        ),
        zoom: 16.0,
      );
      widget.updateCameraPosition(cameraPosition);
      widget.selectedPlaceInfo(response.result);

    } else {
      print("Get place details error: ${response.errorMessage}");
    }
  }


  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 60.0,
            left: 10.0,
            right: 10.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () {
                      setState(() {
                        Navigator.pop(context);
                      });
                    },
                  ),
                  Expanded(
                    child: TextField(
                      focusNode: _searchFocusNode,
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search for a Restaurant...',
                        border: InputBorder.none,
                      ),
                      onChanged: _onSearch,
                      onSubmitted: (value) {
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ),
                  Visibility(
                    visible: _isSearchBarSelected,
                    child: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _predictions.clear();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 115.0,
            left: 10.0,
            right: 10.0,
            child: Visibility(
              maintainSize: false,
              visible: _predictions.isNotEmpty,
              child: Container(
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: _predictions.length,
                    itemBuilder: (BuildContext context, int index) {
                      final prediction = _predictions[index];
                      final textParts = prediction.description!.split('\n');
                      final name = textParts[0];
                      final address = textParts[1];
                      String truncatedAddress = address.split(',').take(2).join(', ');
                      return ListTile(
                        title: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              const TextSpan(text: '\n'),
                              TextSpan(
                                text: truncatedAddress,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          _onPredictionTap(prediction);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}