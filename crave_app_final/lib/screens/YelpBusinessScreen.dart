import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class YelpBusinessScreen extends StatefulWidget {
  final String alias;
  final List<String> availableItems;
  final List<String> notAvailableItems;

  YelpBusinessScreen({required this.alias, required this.availableItems, required this.notAvailableItems});

  @override
  _YelpBusinessScreenState createState() => _YelpBusinessScreenState();
}

class _YelpBusinessScreenState extends State<YelpBusinessScreen> {

  @override
  void initState() {
    super.initState();
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
              if (widget.availableItems.isEmpty)
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
                  children: widget.availableItems
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
              if (widget.notAvailableItems.isEmpty)
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
                  children: widget.notAvailableItems
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
