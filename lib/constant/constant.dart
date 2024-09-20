import 'package:flutter/material.dart';
import '../auth/profile.dart';

const String stripePublishableKey = "pk_test_51PxPNgP0fjL2h56DOpssekuASDcsHDOTTEsFtaU16Dq7QFiUxr6uai2bxtk7JlYYJXeWE4SQlKL2Lf9mAGvjiP16005fSil9yQ";
const String stripeSecretKey = "sk_test_51PxPNgP0fjL2h56DU6LbRBaWPa4hOkjUEqhY9UEgKQpz9nTyn21fkad5MqAnj0chxk4MF5DjiminXl7ZEKgu3nKO00NKPUNxU7";


class Appbar extends StatelessWidget implements PreferredSizeWidget {
  const Appbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(50),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hi Sammad",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Good Morning",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfilePage()),
                      );
                    },
                    child: const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/images/person.jpg'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(160);
}



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




