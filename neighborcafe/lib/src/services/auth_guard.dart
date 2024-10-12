import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'routes.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  final String routeName;

  const AuthGuard({
    super.key,
    required this.child,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final isProtectedRoute = AppRoutes.protectedRoutes.contains(routeName);

    if (isProtectedRoute && user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.welcome,
          (Route<dynamic> route) => false,
        );
      });
      return Container();
    }

    return child;
  }
}
