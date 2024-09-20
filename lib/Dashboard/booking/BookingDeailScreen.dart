
import 'package:citieguide/CustomWidget/CustomWidget.dart';
import 'package:citieguide/Dashboard/AddCity.dart';
import 'package:citieguide/Dashboard/ViewCity.dart';
import 'package:citieguide/Dashboard/booking/HotelBookedUser.dart';
import 'package:citieguide/Dashboard/booking/HotelBookingScreen.dart';
import 'package:citieguide/constant/constant.dart';
import 'package:flutter/material.dart';

class dashboardBookingScreen extends StatelessWidget {
  const dashboardBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Appbar(),
          Container(
            color: Theme.of(context).primaryColor,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(100),
                ),
              ),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [

                  itemDashboard(context, "View Booking", Icons.remove_red_eye_outlined, Colors.deepOrange, BookedUsersScreen()),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
