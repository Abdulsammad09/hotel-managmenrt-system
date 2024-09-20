import 'dart:convert';
import 'package:citieguide/Dashboard/booking/HotelBookingScreen.dart';
import 'package:citieguide/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserHotelScreen extends StatefulWidget {
  final int userId;

  UserHotelScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _UserHotelScreenState createState() => _UserHotelScreenState();
}

class _UserHotelScreenState extends State<UserHotelScreen> {
  List<dynamic> hotels = [];

  @override
  void initState() {
    super.initState();
    fetchUserHotels();
  }

  Future<void> fetchUserHotels() async {
    try {
      final response = await http.get(Uri.parse('${Url}booking/single_user_hotel_booked.php?user_id=${widget.userId}'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        print('Fetched hotels: $jsonResponse'); // Debugging line

        if (jsonResponse is List) {
          setState(() {
            hotels = jsonResponse;
          });
        } else {
          print('Unexpected data format: $jsonResponse');
        }
      } else {
        throw Exception('Failed to load hotels');
      }
    } catch (e) {
      print('Error fetching user hotels: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Booked Hotels'),
      ),
      body: hotels.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: hotels.length,
        itemBuilder: (context, index) {
          final hotel = hotels[index];
          return ListTile(
            leading: Icon(Icons.hotel, color: Colors.blue),
            title: Text(hotel['hotel_name'] ?? 'Unknown Hotel'),
            subtitle: Text(hotel['city_name'] ?? 'Unknown City'),
            trailing: IconButton(
              icon: Icon(Icons.info, color: Colors.green),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HotelDetailbookingscreen(
                      hotelId: hotel['hotel_id'] ?? 0, // Use 'hotel_id' here
                      userId: widget.userId,
                    ),
                  ),
                );
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HotelDetailbookingscreen(
                    hotelId: hotel['hotel_id'] ?? 0, // Use 'hotel_id' here
                    userId: widget.userId,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
