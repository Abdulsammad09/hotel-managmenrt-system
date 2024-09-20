import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:citieguide/main.dart';

class Appbookingscreen extends StatefulWidget {
  const Appbookingscreen({super.key});

  @override
  _AppbookingscreenState createState() => _AppbookingscreenState();
}

class _AppbookingscreenState extends State<Appbookingscreen> {
  List<Map<String, dynamic>> _hotels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookedHotels();
  }

  Future<void> _fetchBookedHotels() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null || userId.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final response = await http.get(Uri.parse('${Url}/app/appbooking/get_user_booked_hotels.php?user_id=$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _hotels = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel Bookings'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hotels.isEmpty
          ? const Center(child: Text("No hotels booked", style: TextStyle(fontSize: 18, color: Colors.black54)))
          : ListView.builder(
        itemCount: _hotels.length,
        itemBuilder: (context, index) {
          final hotel = _hotels[index];

          // Ensure image_path is a List and pick the first image if available
          final imagePaths = hotel['image_path'] as List<dynamic>? ?? [];
          final imageUrl = imagePaths.isNotEmpty ? imagePaths[0] : '';

          // Construct the full image URL and ensure it does not have extra slashes
          final baseUrl = '${Url}/upload';
          final fullImageUrl = imageUrl.startsWith('http')
              ? imageUrl
              : '$baseUrl/${imageUrl.trim()}'; // Use the base URL if needed

          // Encode spaces in URL
          final encodedImageUrl = Uri.encodeFull(fullImageUrl);

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: encodedImageUrl.isNotEmpty
                  ? NetworkImage(encodedImageUrl)
                  : null,
              child: encodedImageUrl.isEmpty
                  ? const Icon(Icons.hotel, color: Colors.white)
                  : null,
            ),
            title: Text(
              hotel['hotel_name'] ?? 'Unknown Hotel',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              hotel['city_name'] ?? 'Unknown City',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}
