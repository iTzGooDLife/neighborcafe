import 'package:flutter/material.dart';
// Asegúrate de importar el widget
import '../../components/main_wrapper.dart';
import '../../settings/settings_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.controller,
  });
  final SettingsController controller;

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
    return MainScreenWrapper(controller: widget.controller);
  }
}
