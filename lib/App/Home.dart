import 'package:citieguide/App/CityScreen.dart';
import 'package:citieguide/App/CityScreenRestuarent.dart';
import 'package:flutter/material.dart';

import '../CustomWidget/home_bottom_bar.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Skyscanner', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true, // Centered title
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildCategoryIcon(context, Icons.hotel, 'Hotels', AppCityScreen()), // Navigates to HotelPage
                  buildCategoryIcon(context, Icons.restaurant, 'Restaurants', AppCityScreenResturant()), // Navigates to RestaurantPage
                ],
              ),
              SizedBox(height: 30), // Increased spacing
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildActionButton('Explore everywhere', Icons.explore),
                  buildActionButton('12 ways we help you', Icons.help),
                ],
              ),
              SizedBox(height: 30), // Increased spacing
              buildImageBanner(context, 'Pick the best rental car deal for you'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: HomeBottomBar(),
    );
  }

  Widget buildCategoryIcon(BuildContext context, IconData icon, String label, Widget destinationPage) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationPage),
        );
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.blue.shade100, // Light blue background
            child: Icon(icon, size: 35, color: Colors.blueAccent), // Icon size adjusted
          ),
          SizedBox(height: 10),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget buildActionButton(String label, IconData icon) {
    return Container(
      padding: EdgeInsets.all(15),
      width: 150,
      decoration: BoxDecoration(
        color: Colors.blue.shade100, // Light blue background
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blueAccent),
          SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget buildImageBanner(BuildContext context, String text) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 400, // Adjusted height
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            image: DecorationImage(
              image: AssetImage('assets/images/bg.jpg'), // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 30, // Adjusted position for better visibility
          left: 20,
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// Page for Hotels
