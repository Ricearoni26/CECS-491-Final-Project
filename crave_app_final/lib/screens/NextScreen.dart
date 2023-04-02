import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class NextScreen extends StatefulWidget {
  final String selectedCategory;




  const NextScreen({Key? key, required this.selectedCategory}) : super(key: key);

  @override
  State<NextScreen> createState() => _NextScreenState();
}

class _NextScreenState extends State<NextScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Next Screen'),
      ),
      body: Container(), // Empty container for now
    );
  }
}

