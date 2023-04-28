import 'package:crave_app_final/main.dart';
import 'package:crave_app_final/screens/ProfilePage.dart';
import 'package:crave_app_final/screens/RecommendationScreen.dart';
import 'package:crave_app_final/screens/RestaurantCategoriesScreen.dart';
import 'package:crave_app_final/screens/preferences_screen.dart';
import 'package:crave_app_final/screens/review_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../controllers/display_map/restaurant_finder_screen.dart';
import 'account_screen.dart';
import 'delete_Screen.dart';
import 'package:geolocator/geolocator.dart';
import '../controllers/display_map/map_controller.dart';
import 'package:flutter/services.dart';
import 'history_screen.dart';
import 'navigate_screen.dart';



class HomeScreen extends StatefulWidget {
  final Position currentPosition;
  const HomeScreen({Key? key, required this.currentPosition}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
  //State<StatefulWidget> createState() => _HomeScreenState();
}


class HomeScreenState extends State<HomeScreen> {
  bool _toggled = false;
  int _selectedIndex = 0;
  final user = FirebaseAuth.instance.currentUser!;
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  late Position currentPos;
  int currentIndex = 0;



  //Retrieve name for user from Database
  String displayUserDetails() {

    //Retrieve unique ID for current user
    String UID = user.uid;
    DatabaseReference refUser = FirebaseDatabase.instance.ref('users/$UID');

    String fullName = '';

    //Retrieve data for user
    refUser.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      //print(data);

      //fullName = data['firstName'] + ' ' + data['lastName'];
      //print('fullname ' + fullName);

    });

    //print('Return this' + fullName);
    return (fullName);
  }


  // void _onItemTapped(int index) {
  //   _selectedIndex = index;
  //   if(index == 0){
  //     Navigator.pushReplacement(context, MaterialPageRoute(
  //         builder: (context) => HomeScreen(currentPosition: widget.currentPosition),
  //     ));
  //   } else if (index == 1) {
  //       Navigator.push(context, MaterialPageRoute(
  //           builder: (context) => RestaurantCategoriesScreen(location: "${widget.currentPosition.latitude},${widget.currentPosition.longitude}" ),),
  //       );
  //   } else if (index == 2) {
  //     Navigator.push(context, MaterialPageRoute(
  //       builder: (context) => SearchPlacesScreen(currentPosition: widget.currentPosition),//NavigationPage(currentPosition: widget.currentPosition)
  //     ),
  //     );
  //   }
  // }

  @override
  void initState() {
    currentPos = widget.currentPosition;
    super.initState();
  }

  Widget _bottomNavBar(){
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      onTap: (index) => setState(() => currentIndex = index),
      unselectedItemColor: Colors.black38,
      selectedItemColor: Colors.black87,
      currentIndex: currentIndex,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
          backgroundColor: Colors.white70,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant),
          label: 'Cravings',
          backgroundColor: Colors.white70,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
          backgroundColor: Colors.white70,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.drive_eta_sharp),
          label: 'On the Road',
          backgroundColor: Colors.white70,
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {

    final screens = [
      MapScreen(currentPosition: widget.currentPosition),
      RestaurantCategoriesScreen(location: "${widget.currentPosition.latitude},${widget.currentPosition.longitude}"),
      ProfilePage(),
      RestaurantFinder(),
      //RestaurantSearch(currentPosition: widget.currentPosition),
      //SearchPlacesScreen(currentPosition: widget.currentPosition),
    ];

    String name = displayUserDetails();
    //print('name' + name);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // drawer: Drawer(
      //   //key: key,
      //   child: ListView(
      //     children: <Widget>[
      //       SizedBox(
      //         height: 250,
      //         child: UserAccountsDrawerHeader(
      //           currentAccountPictureSize: Size(150, 150),
      //           margin: EdgeInsets.all(0.0),
      //           accountEmail: Text('${user.email}'),
      //           accountName: Text(name),
      //           decoration: const BoxDecoration(
      //             gradient: LinearGradient(
      //               begin: Alignment.topLeft,
      //               end: Alignment.bottomRight,
      //               colors: [
      //                 Colors.red,
      //                 Colors.orange,
      //                 Colors.yellow,
      //               ],
      //             ),
      //           ),
      //           currentAccountPicture: const CircleAvatar(
      //             backgroundColor: Colors.white70,
      //             foregroundColor: Colors.black26,
      //             child: Text(
      //               'JS',
      //               style: TextStyle(
      //                 fontSize: 100,
      //               ),
      //             ),
      //           ),
      //         ),
      //       ),
      //       ListTile(
      //         title: const Text('Account'),
      //         leading: const Icon(Icons.account_box),
      //         shape: const RoundedRectangleBorder(),
      //         onTap: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) => const AccountScreen(),
      //             ),
      //           );
      //         },
      //       ),
      //       ListTile(
      //         title: const Text('Food Profile'),
      //         leading: const Icon(Icons.fastfood),
      //         onTap: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) => PreferencesScreen(),
      //             ),
      //           );
      //         },
      //       ),
      //       ListTile(
      //         title: const Text('Food History'),
      //         leading: const Icon(Icons.history_sharp),
      //         onTap: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) => HistoryScreen(),
      //             ),
      //           );
      //         },
      //       ),
      //       SwitchListTile(
      //         title: const Text('Notifications'),
      //         value: _toggled,
      //         onChanged: (bool value) {
      //           setState(() => _toggled = value);
      //         },
      //         secondary: const Icon(Icons.notifications),
      //       ),
      //       ListTile(
      //         title: const Text('Appearance'),
      //         leading: const Icon(Icons.display_settings),
      //         onTap: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) => const AccountScreen(),
      //             ),
      //           );
      //         },
      //       ),
      //       ListTile(
      //         title: const Text('Review'),
      //         leading: const Icon(Icons.reviews),
      //         onTap: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) => const ReviewScreen(),
      //             ),
      //           );
      //         },
      //       ),
      //       ListTile(
      //         title: const Text('Help & Support'),
      //         leading: const Icon(Icons.help_center),
      //         onTap: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) => const AccountScreen(),
      //             ),
      //           );
      //         },
      //       ),
      //       ListTile(
      //         title: const Text('About Us'),
      //         leading: const Icon(Icons.question_mark_outlined),
      //         onTap: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) => const AccountScreen(),
      //             ),
      //           );
      //         },
      //       ),
      //       ListTile(
      //         title: const Text('Delete Account'),
      //         leading: const Icon(Icons.delete_forever_outlined),
      //         onTap: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) => const deleteScreen(),
      //             ),
      //           );
      //         },
      //       ),
      //       ListTile(
      //         title: const Text('Log Out'),
      //         leading: const Icon(Icons.logout),
      //         onTap: () {
      //           FirebaseAuth.instance.signOut();
      //           Navigator.push(context, MaterialPageRoute(
      //             builder: (context) => const MyApp(),
      //           ),);
      //         },
      //       ),
      //     ],
      //   ),
      // ),
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      //body: MapScreen(currentPosition: widget.currentPosition),
      bottomNavigationBar: _bottomNavBar(),
      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor: Colors.white, // Set background color to white
      //   selectedItemColor: Colors.black54,
      //   selectedFontSize: 12,
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.restaurant),
      //       label: 'Random Restaurant',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.drive_eta),
      //       label: 'On the Road',
      //     ),
      //   ],
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      // ),
    );
  }
}

// class LocationSearch extends StatelessWidget {
//   const LocationSearch({
//     Key? key,
//   }) : super(key: key);
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
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
//     );
//   }
// }
