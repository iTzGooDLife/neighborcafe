import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'sample_feature/sample_item_details_view.dart';
import 'sample_feature/sample_item_list_view.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';
import 'settings/app_colors.dart'; // Importa el archivo de colores
import 'views/login_view.dart'; // Importa el archivo de colores
import 'views/register_view.dart'; // Importa el archivo de colores
import 'views/welcome_screen.dart'; // Importa el archivo de colores
import 'views/home_screen.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return ListenableBuilder(
      listenable: settingsController,
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
          themeMode: settingsController.themeMode,

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

          initialRoute: 'welcome_screen',
          // home: RegisterView(),
          routes: {
            'registration_screen': (context) => RegisterView(),
            'login_screen': (context) => LoginView(),
            'welcome_screen': (context) => const WelcomeScreen(),
            'home_screen': (context) => HomePage(),
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
