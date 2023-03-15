import 'package:crave_app_final/auth/main_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {}
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase
      .initializeApp(); //options: DefaultFirebaseOptions.currentPlatform,
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
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
        home: const MainPage()); //const LoginScreen());
  }
}
