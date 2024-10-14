import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/rounded_button.dart';
import '../components/rounded_text.dart';
import '../settings/app_colors.dart';

class PasswordResetView extends StatefulWidget {
  const PasswordResetView({super.key});

  @override
  _PasswordResetViewState createState() => _PasswordResetViewState();
}

class _PasswordResetViewState extends State<PasswordResetView> {
  final _emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  Future<void> _resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Se ha enviado un correo de recuperación')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RoundedTextField(
                hintText: 'Correo Electrónico',
                controller: _emailController,
                backgroundColor: AppColors.backgroundColor,
                textColor: Colors.black,
                obscureText: false),
            const SizedBox(height: 16),
            RoundedButton(
                colour: AppColors.primaryColor,
                title: 'Enviar Correo de Recuperación',
                onPressed: _resetPassword),
          ],
        ),
      ),
    );
  }
}
