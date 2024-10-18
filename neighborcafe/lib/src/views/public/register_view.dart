import 'package:flutter/material.dart';
import 'package:neighborcafe/src/settings/app_colors.dart';
import '../../components/rounded_button.dart';
import '../../components/rounded_text.dart';
import '../../services/routes.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    // Agrega listeners para limpiar el mensaje de error
    _emailController.addListener(_clearErrorMessage);
    _passwordController.addListener(_clearErrorMessage);
    _nameController.addListener(_clearErrorMessage);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _clearErrorMessage() {
    if (_errorMessage.isNotEmpty) {
      setState(() {
        _errorMessage = '';
      });
    }
  }

  Future<void> _register() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, complete todos los campos.';
      });
      return;
    }

    try {
      await context.read<AuthService>().register(
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
        _errorMessage = e.toString();
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
              'Registrarse',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            RoundedTextField(
                hintText: 'Nombre de usuario',
                controller: _nameController,
                backgroundColor: AppColors.backgroundColor,
                textColor: Colors.black,
                obscureText: false),
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
                title: 'Registrarse',
                onPressed: _register),
            if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
