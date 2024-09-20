import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../main.dart';
import 'HotelDetailScreen.dart'; // Ensure this file exists and is correctly named
import 'home_app_bar.dart';
import '../CustomWidget/home_bottom_bar.dart';

class AppHotelScreen extends StatefulWidget {
  final String imagePath;
  final String countryName;
  final int cityId;

  AppHotelScreen({
    required this.imagePath,
    required this.countryName,
    required this.cityId,
  });

  @override
  _AppHotelScreenState createState() => _AppHotelScreenState();
}

class _AppHotelScreenState extends State<AppHotelScreen> {
  List<dynamic> hotels = [];
  List<dynamic> filteredHotels = [];
  TextEditingController searchController = TextEditingController();
  bool isSearchVisible = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHotels();
  }

  Future<void> fetchHotels() async {
    final url = '${Url}/app/fetch_hotel.php?city_id=${widget.cityId}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          hotels = json.decode(response.body);
          filteredHotels = hotels;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load hotels');
      }
    } catch (e) {
      print('Error fetching hotels: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterHotels(String query) {
    setState(() {
      filteredHotels = hotels
          .where((hotel) =>
          hotel['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void toggleSearchVisibility() {
    setState(() {
      isSearchVisible = !isSearchVisible;
      if (!isSearchVisible) {
        filteredHotels = hotels;
        searchController.clear();
      }
    });
  }

  void showNoHotelsToast() {
    Fluttertoast.showToast(
      msg: "No hotels found",
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
                  onChanged: filterHotels,
                  decoration: InputDecoration(
                    hintText: 'Search hotels...',
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
                    '${widget.countryName} Hotels',
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
                    : filteredHotels.isEmpty
                    ? Center(
                  child: ElevatedButton(
                    onPressed: () {
                      fetchHotels();
                    },
                    child: Text('No hotels found. Tap to retry'),
                  ),
                )
                    : ListView.builder(
                  itemCount: filteredHotels.length,
                  itemBuilder: (BuildContext context, int index) {
                    // Determine if 'image_path' contains multiple images
                    String imagePathString = filteredHotels[index]['image_path'];
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
                                builder: (context) => HotelDetailScreen(
                                  hotelId: filteredHotels[index]['id'],
                                  hotelName: filteredHotels[index]['name'],
                                  hotelImagePaths: imagePaths.map((path) => "${Url}/upload/${path}").toList(), // Pass list of image URLs
                                  hotelDescription: filteredHotels[index]['description'],
                                  hotelRating: filteredHotels[index]['rating'],
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
                                      filteredHotels[index]['name'],
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
                                          filteredHotels[index]['rating'].toString(),
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
