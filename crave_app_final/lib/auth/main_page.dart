import 'package:crave_app_final/screens/home_screen.dart';
import 'package:crave_app_final/screens/signin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  //Class to handle sign-in logic
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot){
            if(snapshot.hasData){
              //Is Logged In
              print('entered home');
              return HomeScreen();
            }
            else{
              //Not Logged in
              print('entered sign in');
              return AuthPage();
            }
          }
      ),
    );
  }
}
