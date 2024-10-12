import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../views/home_screen.dart';
import '../views/welcome_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Mientras espera la conexión, muestra un indicador de progreso
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Si el usuario no está autenticado, redirige a la pantalla de login
        if (!snapshot.hasData) {
          return const WelcomeScreen();
        }

        // Si el usuario está autenticado, redirige a la pantalla de inicio
        return const HomePage();
      },
    );
  }
}
