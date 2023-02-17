import 'package:crave_app_final/screens/preferences_screen.dart';
import 'package:crave_app_final/screens/login_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'account_screen.dart';
import 'delete_Screen.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:google_maps_webservice/places.dart';
import 'package:crave_app_final/apiKeys.dart';
import 'package:geolocator/geolocator.dart';
import '../controllers/map_controller.dart';
import '../controllers/location_controller.dart';
import '../controllers/draw_map_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  //_HomeScreenState createState() => _HomeScreenState();
  State<StatefulWidget> createState() => _HomeScreenState();
}

// //Test function below
// Future<String> getUsername() async {
//   final ref = FirebaseDatabase.instance.reference();
//   User cuser = await firebaseAuth.currentUser;
//
//   return ref.child('User_data').child(cuser.uid).once().then((DataSnapshot snap)
//   {
//     final String userName = snap.value['name'].toString();
//     print(userName);
//     return userName;
//   });
// }

class _HomeScreenState extends State<HomeScreen> {
  bool _toggled = false;
  int _selectedIndex = 0;
  final _position = Geolocator.getCurrentPosition();
  final user = FirebaseAuth.instance.currentUser!;

  void _onItemTapped(int index) {
    _selectedIndex = index;
    if(index == 0){
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => const DrawMapController(),),
      );
    } else if (index == 1) {
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => const PreferencesScreen(),),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.orange,
        title: const Text(
          'Crave',
          style: TextStyle(
            fontSize: 45,
            fontWeight: FontWeight.bold,
            fontFamily: 'Didot',
            color: Colors.white,
          ),
        ),
      ),
      body: RestaurantMap(),
      // body: Stack(
      //   children: [
      //     SizedBox(
      //       width: MediaQuery.of(context).size.width,
      //       height: MediaQuery.of(context).size.height,
      //       child: const GoogleMap(
      //         myLocationEnabled: true,
      //         mapToolbarEnabled: true,
      //         mapType: MapType.normal,
      //         initialCameraPosition: CameraPosition(
      //           target: LatLng(33.77, -118.19),
      //           zoom: 15,
      //         ),
      //       ),
      //     ),
      //     const LocationSearch(),
      //   ],
      // ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 250,
              child: UserAccountsDrawerHeader(
                currentAccountPictureSize: Size(150, 150),
                margin: EdgeInsets.all(0.0),
                accountEmail: Text('${user.email}'),
                accountName: Text('${user.displayName}'),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.red,
                      Colors.orange,
                      Colors.yellow,
                    ],
                  ),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white70,
                  foregroundColor: Colors.black26,
                  child: Text(
                    'JS',
                    style: TextStyle(
                      fontSize: 100,
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              title: const Text('Account'),
              leading: const Icon(Icons.account_box),
              shape: const RoundedRectangleBorder(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Food Profile'),
              leading: const Icon(Icons.fastfood),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountScreen(),
                  ),
                );
              },
            ),
            SwitchListTile(
              title: const Text('Notifications'),
              value: _toggled,
              onChanged: (bool value) {
                setState(() => _toggled = value);
              },
              secondary: const Icon(Icons.notifications),
            ),
            ListTile(
              title: const Text('Appearance'),
              leading: const Icon(Icons.display_settings),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountScreen(),
                  ),
                );
              },
            ),

            ListTile(
              title: const Text('Help & Support'),
              leading: const Icon(Icons.help_center),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('About Us'),
              leading: const Icon(Icons.question_mark_outlined),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Delete Account'),
              leading: const Icon(Icons.delete_forever_outlined),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const deleteScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Log Out'),
              leading: const Icon(Icons.logout),
              onTap: () {
                FirebaseAuth.instance.signOut();

              },
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          BottomNavigationBar(
            selectedItemColor: Colors.black54,
            selectedFontSize: 12,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.draw),
                  label: 'Draw',
                  ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.restaurant),
                  label: 'Random Restaurant'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.drive_eta),
                  label: 'On the Road'),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
    );
  }
}

class LocationSearch extends StatelessWidget {
  const LocationSearch({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // const kGoogleApiKey = "API_KEY";
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: ('Enter a Restaurant'),
          prefixIcon: const Icon(Icons.search),
          contentPadding: const EdgeInsets.only(left: 20, bottom: 5, right: 5),
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
    );
  }
}
