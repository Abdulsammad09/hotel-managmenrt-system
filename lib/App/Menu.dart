import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Menu',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.lightBlue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black87),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: MenuOptions(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Placeholder for future functionality (e.g., favorites)
        },
        child: Icon(Icons.favorite, color: Colors.white),
        backgroundColor: Colors.lightBlue.shade400,
        tooltip: 'Favorites',
      ),
      backgroundColor: Colors.white,
    );
  }
}

class MenuOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: EdgeInsets.all(16),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        MenuOptionCard(
          title: 'Breakfast',
          icon: Icons.breakfast_dining,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MenuItemsScreen(category: 'Breakfast'),
            ),
          ),
        ),
        MenuOptionCard(
          title: 'Lunch',
          icon: Icons.lunch_dining,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MenuItemsScreen(category: 'Lunch'),
            ),
          ),
        ),
        MenuOptionCard(
          title: 'Dinner',
          icon: Icons.dinner_dining,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MenuItemsScreen(category: 'Dinner'),
            ),
          ),
        ),
        MenuOptionCard(
          title: 'Drinks',
          icon: Icons.local_drink,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MenuItemsScreen(category: 'Drinks'),
            ),
          ),
        ),
        MenuOptionCard(
          title: 'Desserts',
          icon: Icons.icecream,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MenuItemsScreen(category: 'Desserts'),
            ),
          ),
        ),
      ],
    );
  }
}

class MenuOptionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  MenuOptionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.lightBlue.shade300, width: 2),
      ),
      
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.lightBlue.shade200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.lightBlue.shade500),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.lightBlue.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItemsScreen extends StatelessWidget {
  final String category;

  MenuItemsScreen({required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$category Menu',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.lightBlue.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black87),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: MenuItemsList(category: category),
      backgroundColor: Colors.white,
    );
  }
}

class MenuItemsList extends StatefulWidget {
  final String category;

  MenuItemsList({required this.category});

  @override
  _MenuItemsListState createState() => _MenuItemsListState();
}

class _MenuItemsListState extends State<MenuItemsList> {
  Map<String, List<MenuItem>> _allItems = {};
  Map<String, List<MenuItem>> _filteredItems = {};

  @override
  void initState() {
    super.initState();
    _allItems = _getItemsForCategory(widget.category);
    _filteredItems = _allItems;
  }

  void _filterItems(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredItems = _allItems;
      });
      return;
    }

    Map<String, List<MenuItem>> temp = {};

    _allItems.forEach((subCategory, items) {
      List<MenuItem> filtered = items
          .where((item) =>
          item.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      if (filtered.isNotEmpty) {
        temp[subCategory] = filtered;
      }
    });

    setState(() {
      _filteredItems = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search ${widget.category}...',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            onChanged: _filterItems,
          ),
        ),
        ..._filteredItems.keys.map((subCategory) {
          return ExpansionTile(
            title: Text(
              subCategory,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue.shade700,
              ),
            ),
            children: _filteredItems[subCategory]!
                .map((item) => MenuItemCard(item: item))
                .toList(),
          );
        }).toList(),
      ],
    );
  }

  Map<String, List<MenuItem>> _getItemsForCategory(String category) {
    switch (category) {
      case 'Breakfast':
        return {
          'Morning Specials': [
            MenuItem('Pancakes', 5.99, 'assets/menu/pancakes.jpg'),
            MenuItem('Waffles', 6.99, 'assets/menu/waffles.jpeg'),
            MenuItem('Omelette', 7.49, 'assets/menu/omelette.jpeg'),
          ],
          'Healthy Choices': [
            MenuItem('Smoothie Bowl', 6.79, 'assets/menu/smoothie_bowl.jpeg'),
            MenuItem('French Toast', 5.49, 'assets/menu/french_toast.jpeg'),
            MenuItem('Avocado Toast', 6.19, 'assets/menu/avocado_toast.jpeg'),
          ],
        };
      case 'Lunch':
        return {
          'Main Courses': [
            MenuItem('Burger', 8.99, 'assets/menu/burger.jpeg'),
            MenuItem('Pasta', 9.99, 'assets/menu/pasta.jpeg'),
            MenuItem('Grilled Sandwich', 7.99, 'assets/menu/grilled_sandwich.jpeg'),
          ],
          'Snacks': [
            MenuItem('Sandwich', 6.49, 'assets/menu/sandwich.jpeg'),
            MenuItem('Wrap', 7.99, 'assets/menu/wrap.jpeg'),
            MenuItem('Fries', 3.99, 'assets/menu/fries.jpeg'),
          ],
          'BBQ': [
            MenuItem('BBQ Ribs', 12.99, 'assets/menu/bbq_ribs.jpeg'),
            MenuItem('BBQ Chicken', 10.49, 'assets/menu/bbq_chicken.jpeg'),
            MenuItem('Grilled Vegetables', 9.49, 'assets/menu/grilled_vegetables.jpeg'),
          ],
        };
      case 'Dinner':
        return {
          'Dinner Favorites': [
            MenuItem('Steak', 14.99, 'assets/menu/steak.jpeg'),
            MenuItem('Pizza', 12.99, 'assets/menu/pizza.jpeg'),
            MenuItem('Salmon', 13.99, 'assets/menu/salmon.jpeg'),
          ],
          'Specials': [
            MenuItem('Seafood Platter', 19.99, 'assets/menu/seafood_platter.jpeg'),
            MenuItem('Vegetarian Lasagna', 11.99, 'assets/menu/vegetarian_lasagna.jpeg'),
            MenuItem('Stuffed Peppers', 10.99, 'assets/menu/stuffed_peppers.jpeg'),
          ],
        };
      case 'Drinks':
        return {
          'Soft Drinks': [
            MenuItem('Cola', 2.99, 'assets/menu/cola.jpeg'),
            MenuItem('Lemonade', 2.49, 'assets/menu/lemonade.jpeg'),
            MenuItem('Iced Tea', 2.49, 'assets/menu/iced_tea.jpeg'),
          ],
          'Alcoholic Beverages': [
            MenuItem('Beer', 4.99, 'assets/menu/beer.jpeg'),
            MenuItem('Wine', 5.99, 'assets/menu/wine.jpeg'),
            MenuItem('Cocktails', 6.99, 'assets/menu/cocktails.jpeg'),
          ],
        };
      case 'Desserts':
        return {
          'Sweet Treats': [
            MenuItem('Cheesecake', 4.99, 'assets/menu/cheesecake.jpeg'),
            MenuItem('Brownie', 3.49, 'assets/menu/brownie.jpeg'),
            MenuItem('Ice Cream', 3.99, 'assets/menu/ice_cream.jpeg'),
          ],
          'Pastries': [
            MenuItem('Croissant', 2.49, 'assets/menu/croissant.jpeg'),
            MenuItem('Muffin', 2.99, 'assets/menu/muffin.jpeg'),
            MenuItem('Danish', 3.49, 'assets/menu/danish.jpeg'),
          ],
        };
      default:
        return {};
    }
  }
}

class MenuItemCard extends StatelessWidget {
  final MenuItem item;

  MenuItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: ListTile(
        leading: Image.asset(item.imagePath, width: 50, height: 50, fit: BoxFit.cover),
        title: Text(item.name, style: TextStyle(fontSize: 18)),
        subtitle: Text('\$${item.price.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey)),
        trailing: Icon(Icons.add),
      ),
    );
  }
}

class MenuItem {
  final String name;
  final double price;
  final String imagePath;

  MenuItem(this.name, this.price, this.imagePath);
}
