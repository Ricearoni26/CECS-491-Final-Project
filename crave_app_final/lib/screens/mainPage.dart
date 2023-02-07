import 'package:crave_app_final/screens/home_screen.dart';
import 'package:crave_app_final/screens/signin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshop){
            if(snapshop.hasData){
              //Is Logged In
              return HomeScreen();
            }
            else{
              //Not Logged in
              return SignInScreen();
            }
          }
      ),
    );
  }
}
