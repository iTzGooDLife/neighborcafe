import 'package:flutter/material.dart';
import '../settings/settings_controller.dart';
import '../views/register_view.dart';
import '../views/login_view.dart';
import '../views/welcome_screen.dart';
import '../views/home_screen.dart';
import '../views/map_view.dart';
import '../views/stores_view.dart';
import '../views/recommendations_view.dart';
import '../views/review_store_view.dart';
import '../views/initial_view.dart';
import '../settings/settings_view.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String map = '/map';
  static const String settings = '/settings';
  static const String stores = '/stores';
  static const String recommendationsview = '/recommendations';
  static const String initialview = '/initialview';
  static const String reviewstore = '/review_store';

  static Map<String, WidgetBuilder> routes(
          SettingsController settingsController) =>
      {
        welcome: (context) => const WelcomeScreen(),
        login: (context) => LoginView(),
        register: (context) => const RegisterView(),
        home: (context) => const HomePage(),
        map: (context) => const MapView(),
        settings: (context) => SettingsView(controller: settingsController),
        stores: (context) => const StoresView(),
        recommendationsview: (context) => const RecommendationsView(),
        initialview: (context) => const InitialView(),
        reviewstore: (context) => const ReviewStoreView(),
      };

  static List<String> get protectedRoutes => [
        home,
        map,
        settings,
        stores,
        recommendationsview,
        initialview,
        reviewstore,
      ];
}
