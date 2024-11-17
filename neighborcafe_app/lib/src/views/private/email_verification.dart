import 'dart:async';
import 'package:flutter/material.dart';
import 'package:neighborcafe/src/components/rounded_button.dart';
import 'package:neighborcafe/src/settings/app_colors.dart';
import '../../services/routes.dart';
import '../../services/auth_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool isEmailVerified = false;
  final AuthService _authService = AuthService();
  Timer? timer;
  @override
  void initState() {
// TODO: implement initState
    super.initState();
    // _auth.currentUser?.sendEmailVerification();
    print("SIIII");
    _sendEmailVerification();
    timer = Timer.periodic(
        const Duration(seconds: 3), (_) => _checkEmailVerified());
  }

  Future<void> _sendEmailVerification() async {
    await _authService.sendEmailVerification();
  }

  Future<void> _checkEmailVerified() async {
    final verified = await _authService.checkEmailVerified();
    if (verified) {
      setState(() {
        isEmailVerified = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email Successfully Verified")));
      timer?.cancel();
      // TODO: Navegar a la siguiente pantalla o realizar alguna acción
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (Route<dynamic> route) => false,
      );
    }
  }

  void _onBack() async {
    _authService.signOut();

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.welcome, // Nombre de la ruta
      (Route<dynamic> route) => false, // Elimina todas las rutas anteriores
    );
  }

  @override
  void dispose() {
// TODO: implement dispose
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Verifica tu cuenta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // TODO: agregar una imagen
              const SizedBox(height: 90),
              const Center(
                child: Text(
                  'Revisa tu correo',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Center(
                  child: FutureBuilder<String?>(
                    future: _authService.getUser().then((user) => user?.email),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          'Hemos enviado un correo a: ${snapshot.data}',
                          textAlign: TextAlign.center,
                        );
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (!isEmailVerified) const CircularProgressIndicator(),
              const SizedBox(height: 16),
              if (!isEmailVerified)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: Center(
                    child: Text(
                      'Verificando correo...',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              const SizedBox(height: 57),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: RoundedButton(
                          colour: AppColors.secondaryColor,
                          title: 'Volver',
                          onPressed: _onBack),
                    ),
                    const SizedBox(width: 16), // Espacio entre los botones
                    Expanded(
                      child: RoundedButton(
                        colour: AppColors
                            .primaryColor, // Asume que tienes un color secundario definido
                        title: 'Reenviar',
                        onPressed: _sendEmailVerification,
                      ),
                    ),
                  ],
                ),
              ),

              /* RoundedButton(
                  colour: AppColors.primaryColor,
                  title: 'Reenviar',
                  onPressed: _sendEmailVerification) */
              /* Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: ElevatedButton(
                  child: const Text('Resend'),
                  onPressed: _sendEmailVerification,
                ),
              ), */
            ],
          ),
        ),
      ),
    );
  }
}
