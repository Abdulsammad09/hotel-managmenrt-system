import 'dart:convert';
import 'package:citieguide/Dashboard/booking/SingleUserBookedScreen.dart';
import 'package:citieguide/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookedUsersScreen extends StatefulWidget {
  const BookedUsersScreen({Key? key}) : super(key: key);

  @override
  _BookedUsersScreenState createState() => _BookedUsersScreenState();
}

class _BookedUsersScreenState extends State<BookedUsersScreen> {
  List<dynamic> bookedUsers = [];

  // Fetch booked users from PHP backend
  Future<void> fetchBookedUsers() async {
    final response = await http.get(Uri.parse('${Url}booking/fetch_user_hotel_booking.php'));

    if (response.statusCode == 200) {
      setState(() {
        bookedUsers = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load booked users');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBookedUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booked Users'),
      ),
      body: bookedUsers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: bookedUsers.length,
        itemBuilder: (context, index) {
          final user = bookedUsers[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(user['username']), // Display user name
              subtitle: Text(user['email']), // Display user email
              trailing: IconButton(
                icon: const Icon(Icons.info, color: Colors.blue),
                onPressed: () {
                  // Navigate to user details screen or any other action
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserHotelScreen(userId: user['id']),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
