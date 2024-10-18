import 'package:flutter/material.dart';
import 'bottom_navigation_bar.dart';
import '../views/private/map_view.dart';
import '../views/private/recommendations_view.dart';
import '../views/private/stores_view.dart';
import '../settings/settings_controller.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import '../services/routes.dart';
import '../settings/app_colors.dart';

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

  void _logout(BuildContext context) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.welcome, // Nombre de la ruta
        (Route<dynamic> route) => false, // Elimina todas las rutas anteriores
      );
    } catch (e) {
      // Manejo de errores al cerrar sesión
      print('Error cerrando sesión: $e');
      // Aquí podrías mostrar un mensaje al usuario, por ejemplo, un Snackbar
    }
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
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              color: Colors.white,
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
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
    );
  }
}
