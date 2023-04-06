import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'RecommendationScreen.dart';


class RestaurantCategoriesScreen extends StatefulWidget {
  final String location;

  const RestaurantCategoriesScreen({Key? key, required this.location}) : super(key: key);

  @override
  _RestaurantCategoriesScreenState createState() => _RestaurantCategoriesScreenState();
}

class _RestaurantCategoriesScreenState extends State<RestaurantCategoriesScreen> {
  List<String> _categories = [];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<List<String>> getRestaurantCategories(String location) async {
    final String apiKey = 'pRRhdsH_m4YmAjaNiGRbTBNoPa8WuTG9kf1JJIB3bHPB1Etc_A3uIa-Ahv5Ekls9eTDTXAJrmkwEcu7XPGuJ0Uv33m_H8K0Xppp7FuuqbcyaDBhSJf8lz8Zt-3ElZHYx';
    final String url =
        'https://api.yelp.com/v3/businesses/search?location=$location';

    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $apiKey',
    });

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> businesses = jsonResponse['businesses'];
      final List<String> categories = [];

      businesses.forEach((business) {
        final List<dynamic> businessCategories = business['categories'];
        businessCategories.forEach((category) {
          categories.add(category['title']);
        });
      });

      return categories.toSet()
          .toList(); // Remove duplicates and return as List
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<void> _loadCategories() async {
    final categories = await getRestaurantCategories(widget.location);
    setState(() {
      _categories = categories;
    });
  }

  void _toggleCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _handleNext() {
    if (_selectedCategory != null) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => RecommendationScreen(category: _selectedCategory.toString(),)));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 80.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Categories',
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: _categories.isEmpty
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              child: Wrap(
                children: _categories
                    .map((category) => GestureDetector(
                  onTap: () => _toggleCategory(category),
                  child: Container(
                    margin: EdgeInsets.all(8.0),
                    padding: EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 24.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.0),
                      color: _selectedCategory == category
                          ? Colors.orange
                          : Colors.white,
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ))
                    .toList(),
              ),
            ),
          ),
          BottomAppBar(
            color: Colors.white,
            child: Container(
              height: 80.0,
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      // Handle cancel
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _handleNext,
                    child: Text(
                      'Next',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        side: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1.0,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 32.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}