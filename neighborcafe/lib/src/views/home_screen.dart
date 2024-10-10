import 'package:flutter/material.dart';

// Asegúrate de crear una clase HomePage para redirigir después de iniciar sesión.
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Página Principal')),
      body: Center(child: const Text('Bienvenido a la aplicación!')),
    );
  }
}
