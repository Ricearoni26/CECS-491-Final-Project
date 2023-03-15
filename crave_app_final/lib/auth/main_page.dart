import 'package:crave_app_final/screens/home_screen.dart';
import 'package:crave_app_final/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_controller/google_maps_controller.dart';
import '../screens/login_loading_screen.dart';
import 'auth_page.dart';


class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // Is Logged In
              // print('entered home');
              return const LoginLoadingScreen();// : HomeScreen(currentPosition: _currentPosition);
            } else{
              //Not Logged in
              //print('entered sign in');
              return const AuthPage();
            }
          }),
    );
  }
}




// late Position currentPosition;
//
// class MainPage extends StatelessWidget {
//   const MainPage({Key? key}) : super(key: key);
//
//
//   Future<Position> _getCurrentPosition() async {
//     currentPosition = await Geolocator.getCurrentPosition();
//     return currentPosition;
//   }
//
//
//
//   //Class to handle sign-in logic
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder<User?>(
//           stream: FirebaseAuth.instance.authStateChanges(),
//           builder: (context, snapshot){
//             if(snapshot.hasData){
//               //Is Logged In
//               print('entered home');
//               return HomeScreen();
//             }
//             else{
//               //Not Logged in
//               print('entered sign in');
//               return AuthPage();
//             }
//           }
//       ),
//     );
//   }
// }
