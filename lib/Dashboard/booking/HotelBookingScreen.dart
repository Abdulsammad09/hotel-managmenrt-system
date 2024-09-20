import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../main.dart';

class HotelDetailbookingscreen extends StatefulWidget {
  final int hotelId;
  final int userId;

  const HotelDetailbookingscreen({Key? key, required this.hotelId, required this.userId}) : super(key: key);

  @override
  _HotelDetailbookingscreenState createState() => _HotelDetailbookingscreenState();
}

class _HotelDetailbookingscreenState extends State<HotelDetailbookingscreen> {
  Map<String, dynamic>? bookingDetails;

  @override
  void initState() {
    super.initState();
    fetchBookingDetails();
  }

  Future<void> fetchBookingDetails() async {
    try {
      final url = '${Url}booking/fetch_booking_details.php?hotel_id=${widget.hotelId}&user_id=${widget.userId}';
      print('Request URL: $url'); // Debugging line
      final response = await http.get(Uri.parse(url));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}'); // Debugging line

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('Fetched data: $jsonResponse'); // Debugging line

        if (jsonResponse is Map<String, dynamic>) {
          if (jsonResponse.containsKey('error') || jsonResponse.containsKey('message')) {
            // Handle errors or messages from the API
            setState(() {
              bookingDetails = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(jsonResponse['message'] ?? 'Error fetching booking details')),
            );
          } else {
            // Handle valid booking details
            setState(() {
              bookingDetails = jsonResponse;
            });
          }
        } else {
          print('Unexpected data format: $jsonResponse');
        }
      } else {
        throw Exception('Failed to load booking details, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching booking details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching booking details: $e')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hotel Booking Details'),
      ),
      body: bookingDetails == null
          ? const Center(child: CircularProgressIndicator())
          : bookingDetails!.containsKey('message')
          ? Center(child: Text(bookingDetails!['message'] ?? 'No booking details found'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hotel ID: ${widget.hotelId}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('User ID: ${widget.userId}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Table(
              border: TableBorder.all(color: Colors.grey),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Rooms:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(bookingDetails?['rooms']?.toString() ?? 'N/A'),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Adults:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(bookingDetails?['adults']?.toString() ?? 'N/A'),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Room Type:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(bookingDetails?['room_type'] ?? 'N/A'),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Total Price:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('\$${(num.tryParse(bookingDetails?['total_price']?.toString() ?? '0') ?? 0).toStringAsFixed(2)}'),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Start Date:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(bookingDetails?['start_date'] ?? 'N/A'),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('End Date:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(bookingDetails?['end_date'] ?? 'N/A'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
