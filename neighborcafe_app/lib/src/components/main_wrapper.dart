import 'package:flutter/material.dart';
import 'package:neighborcafe/src/views/private/favorites_view.dart';
import 'bottom_navigation_bar.dart';
import '../views/private/map_view.dart';
import '../views/private/recommendations_view.dart';
import '../views/private/stores_view.dart';
import '../settings/settings_controller.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import '../services/routes.dart';
import '../settings/app_colors.dart';
import 'exit_confirmation.dart';

import 'package:logger/logger.dart';

class MainScreenWrapper extends StatefulWidget {
  const MainScreenWrapper({
    super.key,
    required this.controller,
  });
  final SettingsController controller;

  @override
  _MainScreenWrapperState createState() => _MainScreenWrapperState();
}

class _MainScreenWrapperState extends State<MainScreenWrapper> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Logger _logger = Logger();

  final List<Widget> screens = const [
    MapView(),
    RecommendationsView(),
    FavoritesView(),
    StoresView(),
  ];

  final List<String> titles = const [
    'Mapa',
    'CoffeeBot',
    'Favoritos',
    'Tiendas',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout(BuildContext context) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();
      _logger.i("User logged out successfully.");

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.welcome, // Nombre de la ruta
        (Route<dynamic> route) => false, // Elimina todas las rutas anteriores
      );
    } catch (e) {
      _logger.e("Error logging out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExitConfirmationWrapper(
      isDrawerOpen: () => _scaffoldKey.currentState?.isDrawerOpen ?? false,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              color: Colors.white,
            ),
          ),
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
        ),
        drawer: Drawer(
          child: Container(
            color: AppColors.backgroundColor,
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                const SizedBox(
                  height: 100,
                  child: DrawerHeader(
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                    ),
                    child: Text(
                      'NeighborCafe',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.color_lens),
                  title: const Text('Tema'),
                  trailing: DropdownButton<ThemeMode>(
                    value: widget.controller.themeMode,
                    onChanged: widget.controller.updateThemeMode,
                    dropdownColor: AppColors.backgroundColor,
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('Sistema'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Claro'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Oscuro'),
                      )
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text('Cerrar sesión'),
                  onTap: () => _logout(context),
                ),
                // Agrega más opciones de menú aquí
              ],
            ),
          ),
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: screens,
        ),
        bottomNavigationBar: BottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}
