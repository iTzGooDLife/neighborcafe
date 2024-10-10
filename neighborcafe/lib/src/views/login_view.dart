import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neighborcafe/src/settings/app_colors.dart';
import '../components/rounded_button.dart';
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

      // Si el login es exitoso, redirige al usuario a otra vista o pantalla
      // Por ejemplo, puedes usar Navigator.pushReplacement(...)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                HomePage()), // Cambia HomePage() por tu vista principal
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
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration:
                  const InputDecoration(labelText: 'Correo electrónico'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            RoundedButton(
                colour: AppColors.primaryColor,
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
