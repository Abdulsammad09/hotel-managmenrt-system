import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Fetch data from SharedPreferences
  _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Unknown';
      email = prefs.getString('email') ?? 'Unknown';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : "U",
                style: TextStyle(fontSize: 40),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Username: $username",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              "Email: $email",
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
