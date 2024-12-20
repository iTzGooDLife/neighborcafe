import 'package:flutter/material.dart';
import '../settings/settings_controller.dart';
import '../views/public/register_view.dart';
import '../views/public/login_view.dart';
import '../views/public/welcome_screen.dart';
import '../views/public/reset_email.dart';
import '../views/private/email_verification.dart';
import '../views/private/home_screen.dart';
import '../views/private/map_view.dart';
import '../views/private/stores_view.dart';
import '../views/private/recommendations_view.dart';
import '../views/private/review_store_view.dart';
import '../views/private/initial_view.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String resetpassword = '/reset_password';
  static const String map = '/map';
  static const String settings = '/settings';
  static const String stores = '/stores';
  static const String recommendationsview = '/recommendations';
  static const String initialview = '/initialview';
  static const String reviewstore = '/review_store';
  static const String checkemail = '/check_email';

  static Map<String, WidgetBuilder> routes(
          SettingsController settingsController) =>
      {
        welcome: (context) => const WelcomeScreen(),
        login: (context) => const LoginView(),
        register: (context) => const RegisterView(),
        home: (context) => HomePage(controller: settingsController),
        map: (context) => const MapView(),
        stores: (context) => const StoresView(),
        recommendationsview: (context) => const RecommendationsView(),
        initialview: (context) => const InitialView(),
        reviewstore: (context) => const ReviewStoreView(),
        resetpassword: (context) => const PasswordResetView(),
        checkemail: (context) => const EmailVerificationScreen(),
      };

  static List<String> get protectedRoutes => [
        home,
        map,
        settings,
        stores,
        recommendationsview,
        initialview,
        reviewstore,
        checkemail,
      ];
}
