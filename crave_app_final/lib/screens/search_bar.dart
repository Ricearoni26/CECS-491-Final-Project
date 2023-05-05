import 'package:crave_app_final/apiKeys.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

class SearchBar extends StatefulWidget {
  final Position currentPosition;
  final GoogleMapController? gmController;
  final bool isSearchBarSelected;
  const SearchBar({Key? key,
    required this.currentPosition,
    required this.gmController,
    required this.isSearchBarSelected}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final GoogleMapsPlaces _placesApi = GoogleMapsPlaces(apiKey: googleMapsAPIKey);
  List<Prediction> _predictions = [];
  PlaceDetails? _selectedPlace;
  late Position currentCameraPosition;
  late String _currentQuery;
  late bool _isSearchBarSelected;


  @override
  void initState() {
    super.initState();
    _predictions = [];
    currentCameraPosition = widget.currentPosition;
    _isSearchBarSelected = widget.isSearchBarSelected;
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
      location: Location(lat: widget.currentPosition.latitude, lng: widget.currentPosition.longitude),
      radius: 50000,
      types: ['restaurant'],
    );

    if (response.isOkay) {
      final List<Prediction> predictions = response.predictions;

      final Iterable<PlaceDetails?> placeDetails = await Future.wait(predictions.map((prediction) async {
        final PlacesDetailsResponse detailsResponse = await _placesApi.getDetailsByPlaceId(prediction.placeId!);
        if (detailsResponse.isOkay) {
          return detailsResponse.result;
        } else {
          print("Get place details error: ${detailsResponse.errorMessage}");
          return null;
        }
      }).toList());

      final List<PlaceDetails> nonNullPlaceDetails = placeDetails.whereType<PlaceDetails>().toList();

      nonNullPlaceDetails.sort((b, a) {
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
        _predictions = placeDetails.map((place) => Prediction(description: place?.name, placeId: place?.placeId)).toList();

        //_predictions = predictions;
      });
    } else {
      print("Autocomplete error: ${response.errorMessage}");
    }
  }

  Future<void> _onSearch3() async {
    final String query = _searchController.text;

    if (query.isEmpty) {
      setState(() {
        _predictions = [];
      });
      return;
    }

    final PlacesAutocompleteResponse response = await _placesApi.autocomplete(
      query,
      location: Location(lat: widget.currentPosition.latitude, lng: widget.currentPosition.longitude),
      radius: 50000,
    );

    if (response.isOkay) {
      final List<Prediction> predictions = response.predictions;

      // Get details for each prediction and calculate distance from current location
      final Iterable<PlaceDetails?> placeDetails = await Future.wait(predictions.map((prediction) async {
        final PlacesDetailsResponse detailsResponse = await _placesApi.getDetailsByPlaceId(prediction.placeId!);
        if (detailsResponse.isOkay) {
          return detailsResponse.result;
        } else {
          print("Get place details error: ${detailsResponse.errorMessage}");
          return null;
        }
      }).toList());

      final List<PlaceDetails> nonNullPlaceDetails = placeDetails.whereType<PlaceDetails>().toList();


      nonNullPlaceDetails.sort((b, a) {
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
        _predictions = placeDetails.map((place) => Prediction(description: place?.name, placeId: place?.placeId)).toList();
      });
    } else {
      print("Autocomplete error: ${response.errorMessage}");
    }
  }

  Future<void> _onPredictionTap(Prediction prediction) async {
    final PlacesDetailsResponse response = await _placesApi.getDetailsByPlaceId(prediction.placeId!);

    if (response.isOkay) {
      setState(() {
        _selectedPlace = response.result;
        _currentQuery = prediction.description!;
        _predictions = [];
      });

      final CameraUpdate cameraUpdate = CameraUpdate.newLatLng(LatLng(
        _selectedPlace!.geometry!.location.lat,
        _selectedPlace!.geometry!.location.lng,
      ));
      widget.gmController!.animateCamera(cameraUpdate);
    } else {
      print("Get place details error: ${response.errorMessage}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector (
      onTap: () {
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(23, 58, 23, 0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Enter a Restaurant',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.only(left: 20, bottom: 0, right: 5),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
            ),
            Container(
                color: Colors.black,
                child: SizedBox(height: 10.0)),
            if (_predictions.isNotEmpty)
              ..._predictions.map((prediction) => Align(
                alignment: Alignment(0,0.5),
                child: Card(
                  color: Colors.white,
                  child: ListTile(
                    title: Text(prediction.description ?? ''),
                    onTap: () => {
                      _onPredictionTap(prediction)
                    },
                  ),
                ),
              )),

          ],
        ),
      ),
    );
  }
}
