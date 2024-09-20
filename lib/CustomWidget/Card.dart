import 'package:flutter/material.dart';

Widget _buildAmenityCard(String text, IconData icon) {
  return Container(
    margin: EdgeInsets.only(right: 15),
    padding: EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.blueGrey[300],
      borderRadius: BorderRadius.circular(20), // More rounded corners
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2), // Lighter shadow for a modern look
          spreadRadius: 3,
          blurRadius: 10,
          offset: Offset(0, 3), // Slight offset for a subtle depth effect
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 28,
          color: Color(0xFF232323), // Keeping the blue color consistent with the theme
        ),
        SizedBox(width: 10), // Adjusted spacing for better alignment
        Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600, // Slightly bolder text
            fontSize: 16,
            color: Color(0xFF232323), // Darker text for better readability
          ),
        ),
      ],
    ),
  );
}