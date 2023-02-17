import 'package:flutter/material.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("PREFERENCES"),
        backgroundColor: Colors.blueGrey[200],
      ),
      body:  const SafeArea(
        child: CustomPaint(
        ),
      ),
      backgroundColor: Colors.blueGrey[400],
    );
  }
}

