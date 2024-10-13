import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neighborcafe/src/settings/app_colors.dart';
import '../components/rounded_button.dart';
import '../components/rounded_text.dart';
import '../services/routes.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, complete todos los campos.';
      });
      return;
    }

    try {
      await context.read<AuthService>().signIn(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

      final isSignedIn = await context.read<AuthService>().isSignedIn();
      if (isSignedIn) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (Route<dynamic> route) => false,
        );
      } else {
        setState(() {
          _errorMessage = 'Error al guardar la sesión';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e is FirebaseAuthException
            ? e.message ?? 'Error desconocido'
            : 'Error al iniciar sesión';
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
