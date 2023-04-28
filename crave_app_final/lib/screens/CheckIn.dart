import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crave_app_final/apiKeys.dart';
import 'package:crave_app_final/screens/CheckIn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'YelpBusinessScreen.dart';

class CheckIn extends StatefulWidget {
  const CheckIn({Key? key}) : super(key: key);

  @override
  State<CheckIn> createState() => _CheckInState();
}

class _CheckInState extends State<CheckIn> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}


class MenuItemsPage extends StatefulWidget {
  final String restUrl;

  MenuItemsPage({required this.restUrl});

  @override
  _MenuItemsPageState createState() => _MenuItemsPageState();
}

class _MenuItemsPageState extends State<MenuItemsPage> {
  Future<List<dynamic>>? _menuItems;

  @override
  void initState() {
    super.initState();
    _menuItems = fetchMenuItems();
  }

  Future<List<dynamic>> fetchMenuItems() async {
    final response =
    await http.get(
        Uri.parse('http://localhost:5000/menuitems/${widget.restUrl}'));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      return jsonDecode(response.body);
    } else {
      // If the server returns an error, throw an exception
      throw Exception('Failed to load menu items');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _menuItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final menuItems = snapshot.data ?? [];
          if (menuItems.isEmpty) {
            return Center(child: Text('Does not have a menu available.'));
          } else {
            return ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final section = menuItems[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        section['section'] ?? '',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight
                            .bold),
                      ),
                    ),
                    ...section['items'].map<Widget>((item) {
                      return ListTile(
                        title: Text(item['name'] ?? ''),
                        subtitle: Text(
                            item['description'] ?? 'No description available'),
                        trailing: Text(item['price_level'] ?? 'hello'),
                        leading: item['image_url'] != null ? Image.network(
                            item['image_url']) : null,
                      );
                    }).toList(),
                    Divider(),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}


