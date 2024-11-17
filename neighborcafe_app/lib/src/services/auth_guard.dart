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
    // return FutureBuilder<bool>(
    return FutureBuilder<Map<String, bool>>(
      future: context.read<AuthService>().getAuthStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final authStatus =
            snapshot.data ?? {'isSignedIn': false, 'isEmailVerified': false};
        final isSignedIn = authStatus['isSignedIn'] ?? false;
        final isEmailVerified = authStatus['isEmailVerified'] ?? false;
        final isProtectedRoute = AppRoutes.protectedRoutes.contains(routeName);

        if (isProtectedRoute && !isSignedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.welcome,
              (Route<dynamic> route) => false,
            );
          });
          return Container();
        } else if (isProtectedRoute &&
            isSignedIn &&
            !isEmailVerified &&
            routeName != AppRoutes.checkemail) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.checkemail,
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
