import 'package:flutter/material.dart';
import 'package:neighborcafe/src/settings/app_colors.dart';
import '../../components/rounded_button.dart';
import '../../services/routes.dart';
import '../../services/auth_service.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final isSignedIn = await authService.isSignedIn();

    if (isSignedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Image.asset(
                  'assets/images/cafeIcon.png',
                  height: 300.0,
                ),
                const SizedBox(height: 20),
                RoundedButton(
                  colour: AppColors.primaryColor,
                  title: 'Iniciar Sesión',
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.login);
                  },
                ),
                RoundedButton(
                    colour: AppColors.secondaryColor,
                    title: 'Registrarse',
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.register);
                    }),
              ]),
        ));
  }
}
