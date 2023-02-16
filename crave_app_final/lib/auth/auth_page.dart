import 'package:crave_app_final/screens/login_screen.dart';
import 'package:flutter/material.dart';

import '../screens/register_screen.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {

  //Show login page initial
  bool showLoginPage = true;


  @override
  Widget build(BuildContext context) {
    if(showLoginPage)
      {

        return LoginScreen(showRegisterPage: showRegisterPage)

      }
    else
      {

        return RegisterPage()

      }
    return Container();
  }
}
