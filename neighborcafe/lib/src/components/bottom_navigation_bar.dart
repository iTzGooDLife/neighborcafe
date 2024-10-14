import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

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
      currentIndex: selectedIndex == 3 ? 2 : selectedIndex,
      // selectedItemColor: Colors.blueAccent,
      selectedItemColor:
          selectedIndex == 3 ? Colors.grey[300] : Colors.blueAccent,
      selectedFontSize: selectedIndex == 3 ? 12.0 : 14.0,

      unselectedItemColor: Colors.grey[300],
      onTap: (index) {
        onItemTapped(index);
      },
      /* currentIndex: selectedIndex == 0 ? 1 : selectedIndex,
      selectedItemColor:
          selectedIndex == 0 ? Colors.grey[600] : Colors.blueAccent,
      unselectedItemColor: Colors.grey[600],
      onTap: (index) {
        onItemTapped(
            index); // Aumentar el índice para reflejar correctamente el stack
      }, */
    );
  }
}
