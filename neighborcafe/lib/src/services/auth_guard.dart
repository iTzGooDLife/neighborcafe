import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes.dart';
import 'auth_service.dart';

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
    return FutureBuilder<bool>(
      future: context.read<AuthService>().isSignedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final isSignedIn = snapshot.data ?? false;
        final isProtectedRoute = AppRoutes.protectedRoutes.contains(routeName);

        if (isProtectedRoute && !isSignedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.welcome,
              (Route<dynamic> route) => false,
            );
          });
          return Container();
        }

        return child;
      },
    );
  }
}
