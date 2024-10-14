import 'package:flutter/material.dart';
// Asegúrate de importar el widget
import '../components/main_wrapper.dart';

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
    return const MainScreenWrapper();
  }
}
