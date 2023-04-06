import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';

class RestaurantListPage extends StatefulWidget {
  final PlacesSearchResponse? rest_result;
  const RestaurantListPage({Key? key, required this.rest_result}) : super(key: key);

  @override
  State<RestaurantListPage> createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage> {
  List<String> _restaurantNames = [];

  @override
  void initState() {
    super.initState();
    if (widget.rest_result != null) {
      _restaurantNames = widget.rest_result!.results.map((result) => result.name!).toList();
    } else {

    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant List'),
        backgroundColor: Colors.orange,
      ),
      body: widget.rest_result == null
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: _restaurantNames.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_restaurantNames[index]),
            // ... etc.
          );
        },
      ),
    );
  }
}






//Joey's Help
// class RestaurantListPage extends StatefulWidget {
//   final PlacesSearchResponse? rest_result;
//   const RestaurantListPage({Key?key, required this.rest_result}) : super(key: key);
//
//   @override
//   State<RestaurantListPage> createState() => _RestaurantListPageState();
// }
//
// class _RestaurantListPageState extends State<RestaurantListPage> {
//   late List<String?> message;
//
//   List<String?> _buildMessage() {
//     for (int i = 0; i < 20; i++) {
//       String? temp = widget.rest_result?.results[i].name;
//       message[i] = temp;
//     }
//     return message;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     debugPrint(widget.rest_result.toString()); // print rest_result to console
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('This is just a temp screen'),
//         backgroundColor: Colors.orange,
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 150.0, vertical: 10),
//             child: Center(
//               child: Text(
//                 'Temp screen',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),
//           Text(
//             '${_buildMessage()}',
//             style: TextStyle(fontSize: 16),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
//
//
