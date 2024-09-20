import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../main.dart';
import 'RestaurantDetailScreen.dart'; // Ensure this file exists and is correctly named
import 'home_app_bar.dart';
import '../CustomWidget/home_bottom_bar.dart';

class AppRestaurantScreen extends StatefulWidget {
  final String imagePath;
  final String countryName;
  final int cityId;

  AppRestaurantScreen({
    required this.imagePath,
    required this.countryName,
    required this.cityId,
  });

  @override
  _AppRestaurantScreenState createState() => _AppRestaurantScreenState();
}

class _AppRestaurantScreenState extends State<AppRestaurantScreen> {
  List<dynamic> restaurants = [];
  List<dynamic> filteredRestaurants = [];
  TextEditingController searchController = TextEditingController();
  bool isSearchVisible = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRestaurants();
  }

  Future<void> fetchRestaurants() async {
    final url = '${Url}/app/fetch_restaurant.php?city_id=${widget.cityId}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          restaurants = json.decode(response.body);
          filteredRestaurants = restaurants;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load restaurants');
      }
    } catch (e) {
      print('Error fetching restaurants: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterRestaurants(String query) {
    setState(() {
      filteredRestaurants = restaurants
          .where((restaurant) =>
          restaurant['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void toggleSearchVisibility() {
    setState(() {
      isSearchVisible = !isSearchVisible;
      if (!isSearchVisible) {
        filteredRestaurants = restaurants;
        searchController.clear();
      }
    });
  }

  void showNoRestaurantsToast() {
    Fluttertoast.showToast(
      msg: "No restaurants found",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isSearchVisible ? 140.0 : 90.0),
        child: Column(
          children: [
            HomeAppBar(onSearchTap: toggleSearchVisibility),
            if (isSearchVisible)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  onChanged: filterRestaurants,
                  decoration: InputDecoration(
                    hintText: 'Search restaurants...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.imagePath),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${widget.countryName} Restaurants',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : filteredRestaurants.isEmpty
                    ? Center(
                  child: ElevatedButton(
                    onPressed: () {
                      fetchRestaurants();
                    },
                    child: Text('No restaurants found. Tap to retry'),
                  ),
                )
                    : ListView.builder(
                  itemCount: filteredRestaurants.length,
                  itemBuilder: (BuildContext context, int index) {
                    // Determine if 'image_path' contains multiple images
                    String imagePathString = filteredRestaurants[index]['image_path'];
                    List<String> imagePaths = imagePathString.split(',');

                    // Display the first image or create a list of images
                    String displayImage = "${Url}/upload/${imagePaths[0]}"; // First image

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RestaurantDetailScreen(
                                  restaurantId: filteredRestaurants[index]['id'],
                                restaurantName: filteredRestaurants[index]['name'],
                                restaurantImagePaths: imagePaths.map((path) => "${Url}/upload/${path}").toList(), // Pass list of image URLs
                                restaurantDescription: filteredRestaurants[index]['description'],
                                  restaurantRating: filteredRestaurants[index]['rating']
                                // restaurantRating: filteredRestaurants[index]['rating'],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: NetworkImage(displayImage),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.1),
                                BlendMode.srcOver,
                              ),
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      filteredRestaurants[index]['name'],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 18,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          filteredRestaurants[index]['rating'].toString(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.bookmark_border_outlined,
                                color: Colors.white,
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: HomeBottomBar(),
    );
  }
}
