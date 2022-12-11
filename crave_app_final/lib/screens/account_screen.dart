import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('This is just a temp screen'),
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