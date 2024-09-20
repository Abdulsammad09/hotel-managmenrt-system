import 'dart:convert';
import 'package:citieguide/App/Home.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Dashboard/DashboardScreen.dart';
import '../main.dart';
import 'forgot_password.dart';
import 'register.dart';


class LoginScreen extends StatelessWidget {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  GoogleSignIn signIn = GoogleSignIn();  // GoogleSignIn instance

  void googleSignin(BuildContext context) async {
    try {
      await signIn.signOut();  // Ensure user is signed out before signing in

      var user = await signIn.signIn();
      if (user != null) {
        // Get Google user information
        print(user);
        print("Google ID: ${user.id}");
        print("Email: ${user.email}");
        print("Display Name: ${user.displayName}");

        // Send user data to your backend
        var url = Uri.parse("$Url/auth/google_register.php");
        var response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            "google_id": user.id,
            "email": user.email,
            "username": user.displayName ?? 'Unknown User',
          }),
        );

        // Process response from backend
        var data = json.decode(response.body);
        if (response.statusCode == 200) {
          if (data['status'] == 'User registered successfully') {
            // Handle successful registration
            Fluttertoast.showToast(
              msg: "User registered successfully via Google.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              fontSize: 16.0,
            );
            // Store user data locally using SharedPreferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('email', user.email);
            await prefs.setString('username', user.displayName ?? 'Unknown User');

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          } else if (data['status'] == 'User already exists') {
            // Handle existing user
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('email', user.email);
            await prefs.setString('username', user.displayName ?? 'Unknown User');
            await prefs.setString('user_id', data['user_id'].toString()); // Save user_id

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          } else if (data['status'] == 'Google ID updated successfully') {
            // Handle Google ID update
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('email', user.email);
            await prefs.setString('username', user.displayName ?? 'Unknown User');
            await prefs.setString('user_id', data['user_id'].toString()); // Save updated user_id

            Fluttertoast.showToast(
              msg: "Google ID updated successfully.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              fontSize: 16.0,
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          } else {
            // Handle other cases
            Fluttertoast.showToast(
              msg: "Google Sign-In failed: ${data['message']}",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              fontSize: 16.0,
            );
          }
        } else {
          // Handle server error
          Fluttertoast.showToast(
            msg: "Server error: ${response.statusCode}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            fontSize: 16.0,
          );
        }
      } else {
        print('Google Sign-In failed: No user information');
      }
    } catch (e) {
      // Handle exception
      print('Google Sign-In failed with error: $e');
      Fluttertoast.showToast(
        msg: "Google Sign-In failed with error: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
    }
  }





  // Function to handle traditional login
  Future<void> login(BuildContext context) async {
    try {
      final url = Uri.parse("${Url}auth/login.php");
      print("Login URL: $url");
      final response = await http.post(url, body: {
        "email": email.text,
        "password": password.text,
      });
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      final data = json.decode(response.body);
      print("Decoded JSON: $data");

      if (data["status"] == "Success") {
        final prefs = await SharedPreferences.getInstance();

        // Ensure that email is correctly stored
        await prefs.setString('user_id', data['user_id'].toString());
        await prefs.setString('email', data['email'].toString()); // Save email
        await prefs.setString('username', data['username']?.toString() ?? 'Unknown User'); // Handle missing username
        print("Saved email: ${prefs.getString('user_id')}");
        print("Saved email: ${prefs.getString('email')}");
        print("Saved username: ${prefs.getString('username')}");

        Fluttertoast.showToast(
          msg: "Login Successful",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          fontSize: 16.0,
        );

        // Navigate to the appropriate screen based on role
        if (data["role"] == "admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen()),
          );
        } else if (data["role"] == "user") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        }
      }
      else {
        Fluttertoast.showToast(
          msg: data["message"],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      print("Error: $e");
      Fluttertoast.showToast(
        msg: "An error occurred: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 30),
              Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Sign in to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 40),
              TextField(
                controller: email,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email, color: Colors.blueAccent),
                  hintText: 'Email',
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),
              TextField(
                controller: password,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, color: Colors.blueAccent),
                  hintText: 'Password',
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                obscureText: true,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      login(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20),
                  Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      googleSignin(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                      side: BorderSide(color: Colors.grey, width: 1),
                    ),
                    icon: Image.asset('assets/google_icon.png', width: 24, height: 24),
                    label: Text(
                      'Continue with Google',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
