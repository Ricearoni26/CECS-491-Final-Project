import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

class RestaurantMenuPage extends StatefulWidget {
  final String restUrl;

  const RestaurantMenuPage({Key? key, required this.restUrl}) : super(key: key);

  @override
  _RestaurantMenuPageState createState() => _RestaurantMenuPageState();
}

class _RestaurantMenuPageState extends State<RestaurantMenuPage> {
  late Future<List<dynamic>> _menuItemsFuture;

  @override
  void initState() {
    super.initState();
    _menuItemsFuture = getMenuItems(widget.restUrl);
  }

  Future<List<dynamic>> getMenuItems(String rest_url) async {
    final apiUrl = 'http://127.0.0.1:5000/menuitems/$rest_url';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data;
    } else {
      throw Exception('Failed to load menu items');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant Menu'),
      ),
      body: Center(
        child: FutureBuilder<List<dynamic>>(
          future: _menuItemsFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final menuItems = snapshot.data!;
              String? currentSectionHeader;
              return ListView.builder(
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final menuItem = menuItems[index];
                  if (menuItem['section_header'] != currentSectionHeader) {
                    currentSectionHeader = menuItem['section_header'];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            currentSectionHeader!,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                        ),
                        Divider(),
                        ListTile(
                          title: Text(menuItem['name'] ?? 'No name available'),
                          subtitle: Text(menuItem['description'] ?? 'No description available'),
                          leading: Image.network(menuItem['img_url'] ?? 'https://via.placeholder.com/150'), // Provide a default placeholder image URL
                        ),
                      ],
                    );
                  } else {
                    return ListTile(
                      title: Text(menuItem['name'] ?? 'No name available'),
                      subtitle: Text(menuItem['description'] ?? 'No description available'),
                      leading: Image.network(menuItem['img_url'] ?? 'https://via.placeholder.com/150'), // Provide a default placeholder image URL
                    );
                  }
                },
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}