// Widget _buildPanel(ScrollController scrollController) {
//   List<PlacesSearchResult> _restaurants = [];
//   if (rest_result != null) {
//     _restaurants = rest_result!.results;
//   }
//   return RefreshIndicator(
//     onRefresh: () async {
//       // load new data
//     },
//     child: Container(
//       decoration: const BoxDecoration(
//         color: const Color.fromARGB(48, 145, 140, 140),
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(16),
//           topRight: Radius.circular(16),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           DecoratedBox(
//             decoration: BoxDecoration(
//               // color: Colors.black12,
//               color: Colors.transparent,
//             ),
//
//             child: Stack(
//               children: [
//                 Positioned.fill(
//                   child: Padding(
//                     padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
//                     child: Align(
//                       alignment: Alignment.topCenter,
//                       child: Container(
//                         width: 100,
//                         height: 5,
//                         decoration: BoxDecoration(
//                           color: Colors.grey,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 15),
//               ],
//             ),
//           ),
//           Expanded(
//             child: rest_result == null
//                 ? const Center(
//               child: Text("Nothing to see here"),
//             )
//                 : ListView.builder(
//               controller: scrollController,
//               itemCount: _restaurants.length,
//               itemBuilder: (context, index) {
//                 final restaurant = _restaurants[index];
//                 final photoUrl =
//                 restaurant.photos != null && restaurant.photos!.isNotEmpty
//                     ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=100&photoreference=${restaurant.photos![0].photoReference}&key=${googleMapsAPIKey}'
//                     : '';
//                 return Container(
//                   margin: EdgeInsets.fromLTRB(8, 0, 8, 12),
//                   padding: EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: ListTile(
//                     leading: photoUrl.isNotEmpty
//                         ? SizedBox(
//                       width: 60,
//                       height: 60,
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: Image.network(
//                           photoUrl,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     )
//                         : const Icon(Icons.image),
//                     title: Text(
//                       restaurant.name ?? '',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           restaurant.vicinity ?? '',
//                           style: TextStyle(
//                             color: Colors.black87,
//                           ),
//                         ),
//                         Row(
//                           children: [
//                             Text("Yelp: "),
//                             Icon(Icons.star, color: Colors.yellow),
//                             Text(
//                               '${restaurant.rating ?? '-'}',
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             Text(" | Crave: "),
//                             Icon(Icons.star, color: Colors.yellow),
//                             Text('Not Rated'),
//                           ],
//                         ),
//                       ],
//                     ),
//                     onTap: () {
//                       // Navigate to the restaurant details page
//                     },
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }