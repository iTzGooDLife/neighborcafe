import 'package:flutter/material.dart';
import 'bottom_navigation_bar.dart';
import '../services/routes.dart';

class MainScreenWrapper extends StatefulWidget {
  final List<Widget> screens;
  final List<String> titles;

  const MainScreenWrapper({
    Key? key,
    required this.screens,
    required this.titles,
  }) : super(key: key);

  @override
  _MainScreenWrapperState createState() => _MainScreenWrapperState();
}

class _MainScreenWrapperState extends State<MainScreenWrapper> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.home);
              },
              child: Image.asset(
                'assets/images/cafeIcon.png', // Replace with your image path
                height: 60.0, // Adjust the height as needed
              ),
            ),
            const SizedBox(width: 8.0), // Space between the image and title
            Text(widget.titles[_selectedIndex]),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: widget.screens,
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
