import 'dart:convert';

import 'package:citieguide/App/AmenitiesScreen.dart';
import 'package:citieguide/auth/login.dart';
import 'package:citieguide/main.dart';
import 'package:citieguide/services/stripe_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;
  final List<String> restaurantImagePaths;
  final String restaurantDescription;

  RestaurantDetailScreen({
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantImagePaths,
    required this.restaurantDescription,
  });

  @override
  _RestaurantDetailScreenState createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  bool showFullDescription = false;
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    return userId != null && userId.isNotEmpty;
  }

  DateTimeRange? pickedDateRange;
  double totalPrice = 0.0;
  int adults = 1;
  String selectedTableType = 'Normal Table';

  final Map<String, double> tableTypes = {
    'Normal Table': 100.0,
    'VIP Table': 200.0,
    'Large Table': 300.0,
  };

  void calculateTotalPrice() {
    if (pickedDateRange != null) {
      int days = pickedDateRange!.end.difference(pickedDateRange!.start).inDays;
      if (days == 0) {
        days = 1; // Ensure at least 1 day
      }
      setState(() {
        totalPrice = tableTypes[selectedTableType]! * days;
      });
    }
  }

  void _updateTableType() {
    if (adults <= 4) {
      selectedTableType = 'Normal Table';
    } else if (adults <= 8) {
      selectedTableType = 'VIP Table';
    } else {
      selectedTableType = 'Large Table';
    }
    calculateTotalPrice(); // Recalculate price when table type changes
  }

  @override
  void initState() {
    super.initState();
    _updateTableType(); // Set initial table type
  }

  bool isReadMore = false;
  int _currentPage = 0;


  Future<void> bookRestaurant() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id'); // Get the user ID

    if (userId == null) {
      Fluttertoast.showToast(msg: 'User ID not found. Please log in.');
      return;
    }

    final url = Uri.parse('${Url}/app/book_restaurant.php'); // Replace with your server URL

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'restaurant_id': widget.restaurantId,
        'adults': adults.toString(),
        'table_type': selectedTableType, // Send only the selected table type
        'total_price': totalPrice.toString(),
        'start_date': pickedDateRange?.start.toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        Fluttertoast.showToast(msg: 'Restaurant booking successful');
      } else {
        Fluttertoast.showToast(msg: 'Error: ${responseData['message']}');
      }
    } else {
      Fluttertoast.showToast(msg: 'Failed to connect to server');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 2.5,
                      child: PageView.builder(
                        itemCount: widget.restaurantImagePaths.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              // Implement full-screen view
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  child: Image.network(widget.restaurantImagePaths[index]),
                                ),
                              );
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.grey.withOpacity(0.4),
                                    width: 1.5),
                                image: DecorationImage(
                                  image: NetworkImage(widget.restaurantImagePaths[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.restaurantImagePaths.length,
                              (index) => AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            margin: EdgeInsets.symmetric(horizontal: 3),
                            height: 8,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? Color(0xFF176FF2)
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.restaurantName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 28,
                          color: Color(0xFF232323),
                        ),
                      ),
                      Text(
                        "Show Map",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xFF176FF2),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.amber),
                    SizedBox(width: 5),
                    Text(
                      "4.5 (354 Reviews)", // Example text, replace with actual data
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: Color(0xFF606060),
                      ),
                    ),
                  ],
                ),



                SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Show date picker
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              pickedDateRange = DateTimeRange(
                                start: pickedDate,
                                end: pickedDate.add(Duration(days: 1)),
                              );
                              calculateTotalPrice();
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[400],
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Select Date",
                          style: TextStyle(color: Color(0xFF232323)),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return Dialog(
                                    insetPadding: EdgeInsets.zero,
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Table Preferences",
                                            style: TextStyle(
                                                fontSize: 24, fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 30),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Adults", style: TextStyle(fontSize: 18)),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: Icon(Icons.remove),
                                                    onPressed: () {
                                                      setState(() {
                                                        if (adults > 1) adults--;
                                                        _updateTableType();
                                                      });
                                                    },
                                                  ),
                                                  Text(adults.toString(), style: TextStyle(fontSize: 18)),
                                                  IconButton(
                                                    icon: Icon(Icons.add),
                                                    onPressed: () {
                                                      setState(() {
                                                        if (adults < 20) adults++;
                                                        _updateTableType();
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Table Type", style: TextStyle(fontSize: 18)),
                                              DropdownButton<String>(
                                                value: selectedTableType,
                                                items: tableTypes.keys.map((String value) {
                                                  return DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList(),
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    selectedTableType = newValue!;
                                                    calculateTotalPrice(); // Recalculate price
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 50),
                                          Text(
                                            "Total Price: \$${totalPrice.toStringAsFixed(2)}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 24,
                                              color: Color(0xE2FF5252),
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              padding: EdgeInsets.symmetric(vertical: 20),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              backgroundColor: Colors.grey[400],
                                            ),
                                            child: Text(
                                              "Confirm",
                                              style: TextStyle(color: Color(0xFF232323)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[400],
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Table Preferences",
                          style: TextStyle(color: Color(0xFF232323)),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Text(
                  isReadMore
                      ? widget.restaurantDescription
                      : widget.restaurantDescription.length > 100
                      ? widget.restaurantDescription.substring(0, 100) + '...'
                      : widget.restaurantDescription,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: Color(0xFF606060),
                  ),
                ),
                if (widget.restaurantDescription.length > 100)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isReadMore = !isReadMore;
                      });
                    },
                    child: Text(
                      isReadMore ? "Read Less" : "Read More",
                      style: TextStyle(color: Color(0xFF176FF2)),
                    ),
                  ),
                SizedBox(height: 25),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Amenities",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Color(0xFF232323),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        _buildAmenity("Wi-Fi", Icons.wifi),
                        _buildAmenity("Food", Icons.fastfood),
                        _buildAmenity("Pool", Icons.pool),
                        // Add more amenities as needed
                      ],
                    ),

                  ],
                ),

              ],
            ),
          ),
        ),
        bottomNavigationBar:  Container(
          height: 80,
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Price",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF232323),
                        ),
                      ),
                    ),
                    // Use currentPrice dynamically


                    Text(
                      " \$${totalPrice.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        color: Color(0xE2FF5252),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  bool loggedIn = await isLoggedIn();
                  if (loggedIn) {
                    StripeService.instance.makePayment(totalPrice).then((value) {
                      // Once payment is successful, make the booking
                      bookRestaurant();
                    });
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Login Required"),
                          content: Text("You need to log in first."),
                          actions: [
                            TextButton(
                              child: Text("Login"),
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                                // Navigate to login screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => LoginScreen()), // Replace with your login screen widget
                                );
                              },
                            ),
                            TextButton(
                              child: Text("Cancel"),
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Container(
                  height: 60,
                  width: MediaQuery.of(context).size.width / 1.8,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color(0xFF176FF2),
                  ),
                  child: Center(
                    child: Text(
                      "Book Now",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmenity(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey),
        SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Color(0xFF606060),
          ),
        ),
        SizedBox(width: 10),


      ],
    );
  }



  Widget _buildInfoCard(String title, String time, Color textColor) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10),
          Text(
            time,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
