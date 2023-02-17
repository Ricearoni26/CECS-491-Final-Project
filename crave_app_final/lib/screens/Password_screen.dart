import 'package:flutter/material.dart';

class PasswordScreen extends StatelessWidget {
  const PasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: const Text('Password Screen'),

        backgroundColor: Colors.orange,
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 150.0, vertical: 10),
        child: Center(
          child: Text(
            'Temp screen',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}