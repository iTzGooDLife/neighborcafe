import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';
import 'settings/app_colors.dart'; // Importa el archivo de colores
import 'services/auth_wrapper.dart';
import 'services/protected_route.dart';
import 'views/login_view.dart'; // Importa el archivo de colores
import 'views/register_view.dart'; // Importa el archivo de colores
import 'views/welcome_screen.dart'; // Importa el archivo de colores
import 'views/home_screen.dart';
import 'views/map_view.dart';
import 'views/stores_view.dart';
import 'views/recommendations_view.dart';
import 'views/review_store_view.dart';

/// The Widget that configures your application.
class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  // final SettingsController settingsController;
  final SettingsController settingsController;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupAuthPersistence();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _setupAuthPersistence() async {
    await FirebaseAuth.instance.setPersistence(Persistence.NONE);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _signOut();
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await _clearAuthToken();
      print('Usuario desconectado');
    } catch (e) {
      print('Error al desconectar: $e');
    }
  }

  Future<void> _clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return ListenableBuilder(
      listenable: widget.settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background.
          restorationScopeId: 'app',

          // Provide the generated AppLocalizations to the MaterialApp. This
          // allows descendant Widgets to display the correct translations
          // depending on the user's locale.
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],

          // Use AppLocalizations to configure the correct application title
          // depending on the user's locale.
          //
          // The appTitle is defined in .arb files found in the localization
          // directory.
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          /* theme: ThemeData(),
          darkTheme: ThemeData.dark(), */
          themeMode: widget.settingsController.themeMode,

          theme: ThemeData(
            primaryColor: AppColors.primaryColor,
            scaffoldBackgroundColor: AppColors.backgroundColor,
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.primaryColor,
              titleTextStyle: TextStyle(color: Colors.white),
            ),
            textTheme: const TextTheme(
              bodyMedium: TextStyle(
                  color: AppColors
                      .textColor), // Usa bodyMedium en lugar de bodyText1
            ),
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: AppColors.primaryColor,
              secondary: AppColors.secondaryColor,
            ),
          ),

          // Tema oscuro personalizado
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: AppColors.primaryColor,
            scaffoldBackgroundColor: Colors.black,
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.primaryColor,
              titleTextStyle: TextStyle(color: Colors.white),
            ),
            textTheme: const TextTheme(
              bodyMedium: TextStyle(
                  color: Colors.white), // Usa bodyMedium en lugar de bodyText1
            ),
            colorScheme: const ColorScheme.dark().copyWith(
              primary: AppColors.primaryColor,
              secondary: AppColors.secondaryColor,
            ),
          ),

          initialRoute: 'auth_wrapper',
          // home: RegisterView(),
          routes: {
            'auth_wrapper': (context) => const AuthWrapper(),
            'registration_screen': (context) => RegisterView(),
            'login_screen': (context) => LoginView(),
            'welcome_screen': (context) => const WelcomeScreen(),
            'home_screen': (context) => const ProtectedRoute(child: HomePage()),
            'map_view': (context) => const ProtectedRoute(child: MapView()),
            'stores_view': (context) =>
                const ProtectedRoute(child: StoresView()),
            'recommendations_view': (context) =>
                const ProtectedRoute(child: RecommendationsView()),
            'review_store_view': (context) =>
                const ProtectedRoute(child: ReviewStoreView()),
            'settings_screen': (context) => ProtectedRoute(
                  child: SettingsView(controller: widget.settingsController),
                ),
          },

          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          /* onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);
                  case SampleItemDetailsView.routeName:
                    return const SampleItemDetailsView();
                  case SampleItemListView.routeName:
                  default:
                    return const SampleItemListView();
                }
              },
            );
          }, */
        );
      },
    );
  }
}
