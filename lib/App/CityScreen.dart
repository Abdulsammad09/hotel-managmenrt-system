import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:citieguide/App/HotelScreen.dart';
import 'package:citieguide/App/home_app_bar.dart';
import 'package:citieguide/CustomWidget/home_bottom_bar.dart';
import 'package:citieguide/App/SideBarScreen.dart';
import '../main.dart';

class AppCityScreen extends StatefulWidget {
  @override
  _AppCityScreenState createState() => _AppCityScreenState();
}

class _AppCityScreenState extends State<AppCityScreen> {
  List<dynamic> cities = [];
  List<dynamic> filteredCities = [];
  TextEditingController searchController = TextEditingController();
  bool isSearchVisible = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCities();
  }

  Future<void> fetchCities() async {
    final url = '${Url}/app/fetch_city.php';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          cities = json.decode(response.body);
          // Convert IDs to int if necessary
          filteredCities = cities.map((city) {
            city['id'] = int.parse(city['id']);
            return city;
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load cities');
      }
    } catch (e) {
      print('Error fetching cities: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterCities(String query) {
    setState(() {
      filteredCities = cities
          .where((city) =>
          city['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void toggleSearchVisibility() {
    setState(() {
      isSearchVisible = !isSearchVisible;
      if (!isSearchVisible) {
        filteredCities = cities;
        searchController.clear();
      }
    });
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
                  onChanged: filterCities,
                  decoration: InputDecoration(
                    hintText: 'Search cities...',
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
      drawer: Sidebar(userName: '', userEmail: ''),
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                  image: DecorationImage(
                    image: AssetImage('assets/images/background.jpg'), // Add your image path here
                    fit: BoxFit.cover, // Adjust how the image should fit within the container
                  ),
                ),
                child: Center(
                  child: Text(
                    'Explore Pakistan ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Explore Cities",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                child: filteredCities.isEmpty
                    ? Center(
                  child: Text(
                    'No cities found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                    : ListView.builder(
                  itemCount: filteredCities.length,
                  itemBuilder: (BuildContext context, int index) {
                    final city = filteredCities[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AppHotelScreen(
                                cityId: city['id'] as int, // Cast or convert appropriately
                                imagePath: "${Url}/${city['image_path']}",
                                countryName: city['name'],
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
                              image: NetworkImage(
                                "${Url}/${city['image_path']}",
                              ),
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
                                      city['name'],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                    ),
                                  ],
                                ),
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
