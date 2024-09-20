import 'package:flutter/material.dart';

Widget buildAmenityCard(String text, IconData icon) {
  return Container(
    margin: EdgeInsets.only(right: 15),
    padding: EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.transparent, // Transparent background
      borderRadius: BorderRadius.circular(20), // Rounded corners
      border: Border.all(
        color: Colors.blueGrey, // Border color
        width: 2, // Border thickness
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2), // Lighter shadow for modern look
          spreadRadius: 3,
          blurRadius: 10,
          offset: Offset(0, 3), // Slight offset for subtle depth effect
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 28,
          color: Color(0xFF232323), // Icon color
        ),
        SizedBox(width: 10), // Spacing between icon and text
        Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600, // Bolder text
            fontSize: 16,
            color: Color(0xFF232323), // Text color
          ),
        ),
      ],
    ),
  );
}
