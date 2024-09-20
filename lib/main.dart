
import 'package:citieguide/auth/login.dart';
import 'package:citieguide/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'App/Home.dart';
import 'App/WelcomeScreen.dart';


var Url = "http://192.168.10.156/flutterimage/";

void main() async {
  await _setup();
  runApp(MyApp());
}
Future<void> _setup() async {
  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = stripePublishableKey;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Demo",
      theme: ThemeData(
        primarySwatch: Colors.indigo

      ),
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}

