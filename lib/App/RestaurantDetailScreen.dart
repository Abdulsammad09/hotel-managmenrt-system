import 'dart:convert';

import 'package:citieguide/App/AmenitiesScreen.dart';
import 'package:citieguide/App/Menu.dart';
import 'package:citieguide/CustomWidget/CustomCard.dart';
import 'package:citieguide/CustomWidget/CustomReatingBar.dart';
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
  final String restaurantRating;

  RestaurantDetailScreen({
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantImagePaths,
    required this.restaurantDescription,
    required this.restaurantRating,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced Image Slider
                Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 2.5,
                      child: Stack(
                        children: [
                          PageView.builder(
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
                          Positioned(
                            top: 20, // Adjust as needed
                            left: 10, // Adjust as needed
                            child: IconButton(
                              icon: Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () {
                                Navigator.pop(context);
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
                          fontSize: 17,
                          color: Color(0xFF232323),
                        ),
                      ),

                    ],
                  ),
                ),


                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Parse hotelRating as a double
                    for (int i = 0;
                    i < double.parse(widget.restaurantRating).floor();
                    i++)
                      Icon(Icons.star, color: Colors.amber),

                    // Show half star if rating has a decimal part (e.g., 4.5)
                    if (double.parse(widget.restaurantRating) -
                        double.parse(widget.restaurantRating).floor() >=
                        0.5)
                      Icon(Icons.star_half, color: Colors.amber),

                    // Show empty stars for the remaining up to 5
                    for (int i = double.parse(widget.restaurantRating).ceil();
                    i < 5;
                    i++)
                      Icon(Icons.star_border, color: Colors.grey),

                    // SizedBox(width: 5),
                    // Text(
                    //   "${widget.hotelRating}", // Show hotel rating number
                    //   style: TextStyle(
                    //     fontWeight: FontWeight.w500,
                    //     fontSize: 15,
                    //     color: Color(0xFF606060),
                    //   ),
                    // ),
                  ],
                ),

                SizedBox(height: 15),



          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: OutlinedButton(
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
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(color: Colors.black, width: 1.5), // Black border
                    backgroundColor: Colors.transparent, // Transparent background
                  ),
                  child: Text(
                    "Select Date",
                    style: TextStyle(
                      color: Colors.black, // Black text
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
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
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 30),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Guest", style: TextStyle(fontSize: 18)),
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
                                    OutlinedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      style: OutlinedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(vertical: 20),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        side: BorderSide(color: Colors.black, width: 1.5), // Black border
                                        backgroundColor: Colors.transparent, // Transparent background
                                      ),
                                      child: Text(
                                        "Confirm",
                                        style: TextStyle(color: Colors.black), // Black text
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
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Colors.black, width: 1.5), // Black border
                    backgroundColor: Colors.transparent, // Transparent background
                  ),
                  child: Text(
                    "Table Preferences",
                    style: TextStyle(
                      color: Colors.black, // Black text
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10),

                Container(
                  padding: EdgeInsets.all(5),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Guest reviews title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Guest Reviews",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to a screen with all reviews
                            },
                            child: Text(
                              "View All",
                              style: TextStyle(color: Colors.blue, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      // Rating score
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "4.5",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 40,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.star, color: Colors.greenAccent, size: 24),
                                  Icon(Icons.star, color: Colors.greenAccent, size: 24),
                                  Icon(Icons.star, color: Colors.greenAccent, size: 24),
                                  Icon(Icons.star, color: Colors.greenAccent, size: 24),
                                  Icon(Icons.star_half, color: Colors.greenAccent, size: 24),
                                ],
                              ),
                              SizedBox(height: 5),
                              Text(
                                "1561 reviews",
                                style: TextStyle(color: Colors.black54, fontSize: 14),
                              )
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Column(
                        children: [
                          buildRatingRow("Food Quality", 4.5),
                          buildRatingRow("Service", 4.5),
                          buildRatingRow("Ambiance", 4.5),
                          buildRatingRow("Cleanliness", 4.5),
                          buildRatingRow("Value for Money",4.5),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Image gallery at the bottom
                      Container(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.restaurantImagePaths.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                // Show the image in full screen when tapped
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      backgroundColor: Colors.transparent,
                                      child: Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                widget.restaurantImagePaths[index]),
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 8.0),
                                width: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: Offset(0, 2),
                                      blurRadius: 6,
                                    ),
                                  ],
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
                    ],
                  ),
                ),

                SizedBox(height: 20),
                Divider(
                  color: Colors.grey, // Set the color of the line
                  thickness: 0.5,
                  // Set the thickness of the line
                ),


                SizedBox(height: 20),
                // Amenities Card View with Horizontal Scrolling
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Amenities",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AmenitiesScreen()),
                        );
                      },
                      child: Text(
                        "View all",
                        style:
                        TextStyle(color: Colors.blue, fontSize: 16),
                      ),
                    )
                  ],
                ),

                SizedBox(height: 25),
                Container(
                  height: 50, // Adjust the height as needed
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      buildAmenityCard("Wi-Fi", Icons.wifi),
                      buildAmenityCard("Parking", Icons.local_parking),
                      buildAmenityCard("Pool", Icons.pool),

                  buildAmenityCard("Play Area", Icons.child_care),

                  // Add more amenities as needed
                    ],
                  ),
                ),

                SizedBox(height: 20),
                Divider(
                  color: Colors.grey, // Set the color of the line
                  thickness: 0.5,
                  // Set the thickness of the line
                ),


                SizedBox(height: 20),



                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Section
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(
                          widget.restaurantImagePaths.isNotEmpty ? widget.restaurantImagePaths[0] : 'https://via.placeholder.com/300', // Use first image path or placeholder
                          fit: BoxFit.cover,
                          height: 200,
                          width: double.infinity,
                        ),
                      ),
                    ),

                    // Restaurant Description Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.restaurantName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 10),

                          // Description text with conditional display
                          Text(
                            widget.restaurantDescription,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                            maxLines: showFullDescription ? null : 3,
                            overflow: showFullDescription ? TextOverflow.visible : TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 20),

                          // "View More" button toggles description
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  showFullDescription = !showFullDescription; // Toggle the description
                                });
                              },
                              child: Text(
                                showFullDescription ? 'View Less' : 'View More',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white, backgroundColor: Colors.blue,
                                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 8,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),


                SizedBox(height: 20),
                Divider(
                  color: Colors.grey, // Set the color of the line
                  thickness: 0.5,
                  // Set the thickness of the line
                ),


                SizedBox(height: 20),



                SizedBox(height: 25),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent.shade100, Colors.blue.shade900],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(0, 3), // shadow position
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Restaurant Info',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoCard('Opening Time', '10:00 AM', Colors.white),
                          _buildInfoCard('Closing Time', '11:00 PM', Colors.white),
                        ],
                      ),
                      SizedBox(height: 30),
                      Divider(color: Colors.white.withOpacity(0.5), thickness: 1),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(Icons.local_dining, color: Colors.white, size: 30),
                          SizedBox(width: 12),
                          Text(
                            'Family Friendly',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: Text(
                          'This restaurant welcomes families with children.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MenuScreen()),
                            );
                          },
                          child: Text(
                            'View Menu',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blueAccent,
                            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
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




