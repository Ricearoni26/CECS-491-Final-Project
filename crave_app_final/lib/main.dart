import 'package:crave_app_final/controllers/map_controller.dart';
import 'package:crave_app_final/screens/home_screen.dart';
import 'package:crave_app_final/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'firebase_options.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {}
  runApp(MyApp());
}


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform
//   );
//   runApp(MyApp());
// }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.orange,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: const TextTheme(
            displaySmall: TextStyle(
              fontFamily: 'Didot',
              fontWeight: FontWeight.bold,
              fontSize: 50.0,
              color: Colors.white,
            ),
            labelLarge: TextStyle(
              fontFamily: 'Didot',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            titleMedium: TextStyle(fontFamily: 'NotoSans'),
            bodyMedium: TextStyle(fontFamily: 'NotoSans'),
          ),
        ),
        home: const HomeScreen()
    );
  }
}
