import 'dart:convert';
import 'package:citieguide/App/AmenitiesScreen.dart';
import 'package:citieguide/auth/login.dart';
import 'package:citieguide/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:citieguide/App/Home.dart';
import 'package:citieguide/CustomWidget/CustomCard.dart';
import 'package:citieguide/CustomWidget/CustomReatingBar.dart';
import 'package:citieguide/services/stripe_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HotelDetailScreen extends StatefulWidget {
  final String hotelId;
  final String hotelName;
  final List<String> hotelImagePaths;
  final String hotelDescription;
  final String hotelRating;

  HotelDetailScreen({
    required this.hotelId,
    required this.hotelName,
    required this.hotelImagePaths,
    required this.hotelDescription,
    required this.hotelRating,
  });

  @override
  _HotelDetailScreenState createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  bool showFullDescription = false;
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    return userId != null && userId.isNotEmpty;
  }
  DateTimeRange? pickedDateRange;
  double roomPrice = 199.0; // Default room price
  int rooms = 1;
  int adults = 1;
  String selectedRoomType = 'Single';
  double totalPrice = 0.0;
  final Map<String, double> roomPrices = {
    'Single': 100.0,
    'Double': 299.0,
    'Suite': 499.0,
  };

  void calculateTotalPrice() {
    if (pickedDateRange != null) {
      int nights = pickedDateRange!.end.difference(pickedDateRange!.start).inDays;
      if (nights == 0) {
        nights = 1; // Ensure at least 1 night is considered for single-day bookings
      }
      setState(() {
        totalPrice = roomPrice * rooms * nights;
      });
    }
  }



  final List<String> reviewImages = [
    'assets/images/bg.jpg',
    'assets/images/city2.jpg',
    'assets/images/bg.jpg',
    'assets/images/bg.jpg',
  ];
  bool isReadMore = false;
  int _currentPage = 0;

  Future<void> bookRoom() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id'); // Get the user ID

    if (userId == null) {
      Fluttertoast.showToast(msg: 'User ID not found. Please log in.');
      return;
    }

    final url = Uri.parse('${Url}/app/book_room.php'); // Replace with your server URL

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'hotel_id': widget.hotelId, // Use widget.hotelId here
        'rooms': rooms.toString(),
        'adults': adults.toString(),
        'room_type': selectedRoomType,
        'total_price': totalPrice.toString(),
        'start_date': pickedDateRange?.start.toIso8601String(),
        'end_date': pickedDateRange?.end.toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        Fluttertoast.showToast(msg: 'Booking successful');
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
                            itemCount: widget.hotelImagePaths.length,
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
                                      child: Image.network(widget.hotelImagePaths[index]),
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
                                      image: NetworkImage(widget.hotelImagePaths[index]),
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
                                widget.hotelImagePaths.length,
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
                        widget.hotelName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
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
                    // Parse hotelRating as a double
                    for (int i = 0;
                    i < double.parse(widget.hotelRating).floor();
                    i++)
                      Icon(Icons.star, color: Colors.amber),

                    // Show half star if rating has a decimal part (e.g., 4.5)
                    if (double.parse(widget.hotelRating) -
                        double.parse(widget.hotelRating).floor() >=
                        0.5)
                      Icon(Icons.star_half, color: Colors.amber),

                    // Show empty stars for the remaining up to 5
                    for (int i = double.parse(widget.hotelRating).ceil();
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
                          pickedDateRange = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                            initialDateRange: DateTimeRange(
                              start: DateTime.now(),
                              end: DateTime.now().add(Duration(days: 1)),
                            ),
                          );
                          if (pickedDateRange != null) {
                            setState(() {
                              calculateTotalPrice(); // Recalculate total price based on selected dates
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
                          "Select Dates",
                          style: TextStyle(color: Color(0xFF232323)),
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
                                      height: double.infinity,
                                      padding: EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Room Preferences",
                                            style: TextStyle(
                                                fontSize: 24, fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 30),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Rooms", style: TextStyle(fontSize: 18)),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: Icon(Icons.remove),
                                                    onPressed: () {
                                                      setState(() {
                                                        if (rooms > 1) rooms--;
                                                        calculateTotalPrice(); // Update total price
                                                      });
                                                    },
                                                  ),
                                                  Text(rooms.toString(), style: TextStyle(fontSize: 18)),
                                                  IconButton(
                                                    icon: Icon(Icons.add),
                                                    onPressed: () {
                                                      setState(() {
                                                        if (rooms < 5) rooms++;
                                                        calculateTotalPrice(); // Update total price
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
                                              Text("Adults", style: TextStyle(fontSize: 18)),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: Icon(Icons.remove),
                                                    onPressed: () {
                                                      setState(() {
                                                        if (adults > 1) adults--;
                                                        // No price calculation needed here
                                                      });
                                                    },
                                                  ),
                                                  Text(adults.toString(), style: TextStyle(fontSize: 18)),
                                                  IconButton(
                                                    icon: Icon(Icons.add),
                                                    onPressed: () {
                                                      setState(() {
                                                        if (adults < 5) adults++;
                                                        // No price calculation needed here
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
                                              Text("Room Type", style: TextStyle(fontSize: 18)),
                                              DropdownButton<String>(
                                                value: selectedRoomType,
                                                items: roomPrices.keys
                                                    .map((String value) {
                                                  return DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList(),
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    selectedRoomType = newValue!;
                                                    roomPrice = roomPrices[selectedRoomType]!;
                                                    calculateTotalPrice(); // Update total price
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
                                              print("Rooms: $rooms, Adults: $adults, Room Type: $selectedRoomType, Total Price: \$${totalPrice.toStringAsFixed(2)}");
                                              Navigator.of(context).pop();
                                            },
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.symmetric(vertical: 20),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              side: BorderSide(color: Colors.grey, width: 1.5), // Grey border
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
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(color: Colors.grey, width: 1.5), // Grey border
                          backgroundColor: Colors.transparent, // Transparent background
                        ),
                        child: Text(
                          "Room Preferences",
                          style: TextStyle(color: Color(0xFF232323)),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10),

                Container(
                  padding: EdgeInsets.all(5),
                  color: Colors.white, // White background color for the section
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Guest reviews title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Guest reviews",
                            style: TextStyle(
                                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "View all",
                              style: TextStyle(color: Colors.blue, fontSize: 16),
                            ),
                          )
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
                                color: Colors.black, fontSize: 40, fontWeight: FontWeight.bold),
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
                          buildRatingRow("Cleanliness", 4.5),
                          buildRatingRow("Service", 4.5),
                          buildRatingRow("Value", 4.5),
                          buildRatingRow("Location", 4.5),
                          buildRatingRow("Rooms", 4.5),
                          buildRatingRow("Sleep quality", 4.5),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Add image at the bottom
                      Container(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.hotelImagePaths.length,
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
                                            image: NetworkImage(widget.hotelImagePaths[index]), // Use NetworkImage for dynamic paths
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
                                    image: NetworkImage(widget.hotelImagePaths[index]), // Use NetworkImage for dynamic paths
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
                      buildAmenityCard("Restaurant", Icons.restaurant),
                      buildAmenityCard("Gym", Icons.fitness_center),
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
                      child:Image.network(
                        widget.hotelImagePaths[0], // URL for remote image
                        fit: BoxFit.cover,
                        height: 200, // Adjust the height as needed
                        width: double.infinity,
                      )
                    ),

                    // Hotel Description Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.hotelName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // Adjust color to your theme
                            ),
                          ),
                          SizedBox(height: 10),

                          // Description text with conditional display
                          Text(
                            widget.hotelDescription,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600], // Adjust color as needed
                            ),
                            maxLines: showFullDescription ? null : 3, // Display full or truncated text
                            overflow: showFullDescription ? TextOverflow.visible : TextOverflow.ellipsis, // Handle overflow
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
                                showFullDescription ? 'View Less' : 'View More', // Change button text dynamically
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold, // Make text bolder
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white, backgroundColor: Colors.blue, // Button text color
                                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 8,
                              ),
                            ),
                          ),
                          SizedBox(height: 20), // Space between text and button
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
                        'Good to Know',
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
                          _buildInfoCard('Check in from', '14:00', Colors.white),
                          _buildInfoCard('Check out before', '12:00', Colors.white),
                        ],
                      ),
                      SizedBox(height: 30),
                      Divider(color: Colors.white.withOpacity(0.5), thickness: 1),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(Icons.family_restroom, color: Colors.white, size: 30),
                          SizedBox(width: 12),
                          Text(
                            'Children',
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
                          'Children are welcome at this hotel.',
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
                              MaterialPageRoute(builder: (context) => AmenitiesScreen()),
                            );
                          },

                          child: Text(
                            'View all',
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
                      bookRoom();
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
