import 'dart:convert';
import 'package:citieguide/App/Home.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'OTPscreen.dart'; // Ensure you have this import

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();



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





  Future registerUser() async {
    try {
      var url = Uri.parse("$Url/auth/register.php");
      var response = await http.post(url, body: {
        "username": usernameController.text,
        "password": passwordController.text,
        "email": emailController.text,
        "role": "user",
      });

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      var data = json.decode(response.body);
      if (data == "User registered successfully. Please check your email for the OTP.") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OTPVerificationPage(email: emailController.text)),
        );
      } else {
        Fluttertoast.showToast(
          msg: "Registration Failed: ${data["message"]}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          fontSize: 16.0,
        );
      }
    } catch (e) {
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
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Create your account',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    hintText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email),
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, // This will stretch the buttons to full width
                  children: [

                    SizedBox(height: 15), // Space between "Forgot Password?" and "Sign In"
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          registerUser();
                        }
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
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, // Stretches the button to full width
                  children: [
                    SizedBox(height: 20),
                    Divider(
                      color: Colors.grey, // Color of the divider
                      thickness: 1,       // Thickness of the divider
                    ),
                    SizedBox(height: 20), // Space between the divider and the Google button
                    ElevatedButton.icon(
                      onPressed: () {
                        googleSignin(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // Background color of the button
                        foregroundColor: Colors.black, // Text color of the button
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                        side: BorderSide(color: Colors.grey, width: 1), // Border color and width
                      ),
                      icon: Image.asset('assets/google_icon.png', width: 24, height: 24), // Path to Google icon image

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
                      "Already have an account?",
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Sign In',
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
      ),
    );
  }
}
