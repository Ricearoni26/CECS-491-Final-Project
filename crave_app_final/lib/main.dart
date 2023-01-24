import 'package:crave_app_final/screens/login_screen.dart';
import 'package:flutter/material.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_storage/firebase_storage.dart';
//import 'firebase_options.dart';

void main() => runApp(MyApp());

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
          primaryColor: Colors.orange,
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
              color: Colors.green,
            ),
            titleMedium: TextStyle(fontFamily: 'NotoSans'),
            bodyMedium: TextStyle(fontFamily: 'NotoSans'),
          ),
        ),
        home: const LoginScreen());
  }
}
