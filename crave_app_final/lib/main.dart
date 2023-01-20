import 'package:flutter/material.dart';
import 'package:crave_app_final/AndroidStudioProjects/CECS-491-Final-Project/crave_app_final/lib/screens/login_screen.dart';

void main() => runApp(MyApp());

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
