import 'package:flutter/material.dart';
// Asegúrate de importar el widget
import '../components/main_wrapper.dart';
import 'map_view.dart';
import 'stores_view.dart';
import 'recommendations_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const MainScreenWrapper(
      screens: [
        MapView(),
        RecommendationsView(),
        StoresView(),
      ],
      titles: [
        'Mapa',
        'Recomendaciones',
        'Tiendas online',
      ],
    );
  }
}
