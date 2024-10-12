import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProtectedRoute extends StatelessWidget {
  final Widget child;

  const ProtectedRoute({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Si el usuario no está autenticado, redirige al login
    if (user == null) {
      Future.microtask(
          () => Navigator.pushReplacementNamed(context, 'welcome_screen'));
      return const SizedBox(); // Evita mostrar algo mientras redirige
    }

    // Si el usuario está autenticado, muestra la vista protegida
    return child;
  }
}
