import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final BuildContext context;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.context,
  });

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        if (selectedIndex != 0) {
          Navigator.pushNamed(context, 'map_view');
        }
        break;
      case 1:
        if (selectedIndex != 1) {
          Navigator.pushNamed(context, 'recommendations_view');
        }
        break;
      case 2:
        if (selectedIndex != 2) {
          Navigator.pushNamed(context, 'stores_view');
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Mapa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.coffee_outlined),
          label: 'Recomendaciones',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          label: 'Tiendas online',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: Colors.blueAccent,
      onTap: _onItemTapped,
    );
  }
}
