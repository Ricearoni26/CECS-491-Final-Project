import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class YelpBusiness2 extends StatefulWidget {
  final String alias;

  YelpBusiness2({required this.alias});

  @override
  _YelpBusinessScreenState createState() => _YelpBusinessScreenState();
}

class _YelpBusinessScreenState extends State<YelpBusiness2> {
  List<String> _availableItems = [];
  List<String> _notAvailableItems = [];

  @override
  void initState() {
    super.initState();
    _fetchBusinessInfo(widget.alias.toString());
  }

  Future<void> _fetchBusinessInfo(String alias12) async {
    try {
      final String url = 'http://127.0.0.1:5000/amen/$alias12';
      final response = await http.get(Uri.parse(url));
      final List<dynamic> items = json.decode(response.body)
      as List<dynamic>; // parse response as a list of lists
      setState(() {
        _availableItems = List<String>.from(items[0]);
        _notAvailableItems = List<String>.from(items[1]);
      });
    } catch (e) {
      setState(() {
        _availableItems = ['Error retrieving business information'];
        _notAvailableItems = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Yelp Business Info',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available Amenities:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              if (_availableItems.isEmpty)
                Text(
                  'No available items found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                )
              else
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  childAspectRatio: 3,
                  children: _availableItems
                      .map(
                        (item) => Row(
                      children: [
                        Icon(Icons.check, color: Colors.green),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            item,
                            style: TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )
                      .toList(),
                ),
              SizedBox(height: 24),
              Text(
                'Not Available Amenities:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              if (_notAvailableItems.isEmpty)
                Text(
                  'No unavailable items found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                )
              else
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  childAspectRatio: 3,
                  children: _notAvailableItems
                      .map(
                        (item) => Row(
                      children: [
                        Icon(Icons.clear, color: Colors.red),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            item,
                            style: TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
