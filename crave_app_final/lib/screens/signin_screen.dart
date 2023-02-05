import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container(decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:  [
            Colors.red,
            Colors.orange,
            Colors.yellow,
      ],begin: Alignment.topLeft, end: Alignment.bottomRight,))
      ,)
      ,);
  }
}
