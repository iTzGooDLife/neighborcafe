import 'package:flutter/material.dart';
import '../settings/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Mapa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.coffee_outlined),
          label: 'CoffeeBot',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: 'Favoritos',  
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          label: 'Tiendas',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor:
          !isDarkMode ? AppColors.secondaryColor : Colors.grey[300],
      onTap: (index) {
        onItemTapped(index);
      },
      selectedFontSize: 16,
      unselectedFontSize: 14,
    );
  }
}
