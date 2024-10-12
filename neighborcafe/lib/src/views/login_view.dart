import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neighborcafe/src/settings/app_colors.dart';
import '../components/rounded_button.dart';
import '../components/rounded_text.dart';
import './home_screen.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        'home_screen', // Nombre de la ruta
        (Route<dynamic> route) => false, // Elimina todas las rutas anteriores
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Error desconocido';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Iniciar Sesión',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            RoundedTextField(
                hintText: 'Correo electrónico',
                controller: _emailController,
                backgroundColor: AppColors.backgroundColor,
                textColor: Colors.black,
                obscureText: false),
            RoundedTextField(
                hintText: 'Contraseña',
                controller: _passwordController,
                backgroundColor: AppColors.backgroundColor,
                textColor: Colors.black,
                obscureText: true),
            const SizedBox(height: 20),
            RoundedButton(
                colour: AppColors.secondaryColor,
                title: 'Iniciar Sesión',
                onPressed: _login),
            if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
