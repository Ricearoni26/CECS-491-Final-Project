import 'package:crave_app_final/screens/signin_screen.dart';
import 'package:flutter/material.dart';

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

        return SignInScreen(showRegisterPage: showRegisterPage);

      }
    else
      {

        return RegisterPage()

      }
    return Container();
  }
}
