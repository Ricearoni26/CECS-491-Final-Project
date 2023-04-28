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
import '../controllers/display_map/MapScreenController.dart';
import 'account_screen.dart';
import 'delete_Screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'history_screen.dart';



class HomeScreen extends StatefulWidget {
  final Position currentPosition;
  const HomeScreen({Key? key, required this.currentPosition}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}


class HomeScreenState extends State<HomeScreen> {
  bool _toggled = false;
  int _selectedIndex = 0;
  final user = FirebaseAuth.instance.currentUser!;
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  late Position currentPos;
  int currentIndex = 0;
  bool shouldDrawMap = false;



  //Retrieve name for user from Database
  String displayUserDetails() {

    //Retrieve unique ID for current user
    String UID = user.uid;
    DatabaseReference refUser = FirebaseDatabase.instance.ref('users/$UID');

    String fullName = '';

    //Retrieve data for user
    refUser.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
    });

    return (fullName);
  }

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
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.drive_eta_sharp),
        //   label: 'On the Road',
        //   backgroundColor: Colors.white70,
        // ),
      ],
    );
  }


  void _enableDrawMode(bool value) {
    setState(() {
      shouldDrawMap = value;
    });
  }

  @override
  Widget build(BuildContext context) {

    final screens = [
      MapScreen(currentPosition: widget.currentPosition),
      //MapScreen(currentPosition: widget.currentPosition),
      RestaurantCategoriesScreen(location: "${widget.currentPosition.latitude},${widget.currentPosition.longitude}"),
      ProfilePage(),
      //RestaurantFinder(),
    ];

    String name = displayUserDetails();


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
      bottomNavigationBar: _bottomNavBar(),
    );
  }
}
