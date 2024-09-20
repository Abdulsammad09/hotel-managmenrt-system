import 'package:flutter/material.dart';

class AmenitiesScreen extends StatefulWidget {
  @override
  _AmenitiesScreenState createState() => _AmenitiesScreenState();
}

class _AmenitiesScreenState extends State<AmenitiesScreen> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    )..forward();
    _animation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Amenities'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        color: Colors.grey[200],
        child: FadeTransition(
          opacity: _animation!,
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              _buildSectionCard(
                context,
                'Services',
                Icons.card_giftcard,
                [
                  'ATM',
                  'Concierge',
                  'Currency exchange',
                  '24-hour Front Desk Service',
                  'Luggage storage',
                  'Multilingual staff',
                  'Room service',
                  'Safe deposit box',
                ],
              ),
              SizedBox(height: 16),
              _buildSectionCard(
                context,
                'Accessibility',
                Icons.accessibility,
                [
                  'Accessible parking',
                  'Elevator',
                  'Toilet with grab bar',
                  'Wheelchair accessible',
                ],
              ),
              SizedBox(height: 16),
              _buildSectionCard(
                context,
                'In the rooms',
                Icons.bed,
                [
                  'Air conditioning',
                  'Desk',
                  'Hairdryer',
                  'Shower',
                ],
              ),
              SizedBox(height: 16),
              _buildSectionCard(
                context,
                'Transport and parking',
                Icons.directions_car,
                [
                  'Airport Shuttle',
                  'Car rental',
                  'Parking',
                  'Shuttle service',
                  'Valet parking',
                ],
              ),
              SizedBox(height: 16),
              _buildSectionCard(
                context,
                'Food and drink',
                Icons.local_dining,
                [
                  'Banquet service',
                  'Complimentary bottled water',
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('From Rs36,422',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ElevatedButton(
                onPressed: () {},
                child: Text('View deals'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, String title, IconData icon, List<String> items) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 24, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              _buildAmenitiesList(items),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmenitiesList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) => _buildBulletItem(item)).toList(),
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 8, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: Colors.black))),
        ],
      ),
    );
  }
}
