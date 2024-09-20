import 'package:flutter/material.dart';

Widget buildRatingRow(String category, double rating) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5.0),
    child: LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                category,
                style: TextStyle(color: Colors.black54, fontSize: 16),
                overflow: TextOverflow.ellipsis, // Handle long category names
              ),
            ),
            SizedBox(width: 10),
            Row(
              children: [
                Text(
                  rating.toString(),
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
                SizedBox(width: 10),
                Container(
                  width: constraints.maxWidth * 0.5, // Adjust width based on available space
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: rating / 5, // Calculate the width based on rating
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}
