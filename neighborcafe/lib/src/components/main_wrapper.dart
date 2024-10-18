import 'package:flutter/material.dart';
import 'bottom_navigation_bar.dart';
import '../services/routes.dart';
import '../views/private/initial_view.dart';
import '../views/private/map_view.dart';
import '../views/private/recommendations_view.dart';
import '../views/private/stores_view.dart';

class MainScreenWrapper extends StatefulWidget {
  const MainScreenWrapper({
    super.key,
  });

  @override
  _MainScreenWrapperState createState() => _MainScreenWrapperState();
}

class _MainScreenWrapperState extends State<MainScreenWrapper> {
  int _selectedIndex = 0;

  final List<Widget> screens = const [
    MapView(),
    RecommendationsView(),
    StoresView(),
  ];

  final List<String> titles = const [
    'Mapa',
    'Recomendaciones',
    'Tiendas online',
  ];

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
            Image.asset(
              'assets/images/cafeIcon.png', // Replace with your image path
              height: 60.0, // Adjust the height as needed
            ),
            const SizedBox(width: 8.0), // Space between the image and title
            Text(titles[_selectedIndex],
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 20.0)),
          ],
        ),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
              color: Colors.white),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
