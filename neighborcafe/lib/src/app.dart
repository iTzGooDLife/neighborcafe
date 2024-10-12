import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/routes.dart';
import 'services/auth_guard.dart';
import 'services/session_timeout_manager.dart';

import 'settings/settings_controller.dart';
import 'settings/app_colors.dart'; // Importa el archivo de colores

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MultiProvider(
          providers: [
            Provider<AuthService>(
              create: (_) => AuthService(),
            ),
            StreamProvider(
              create: (context) => context.read<AuthService>().authStateChanges,
              initialData: null,
            ),
          ],
          child: MaterialApp(
            restorationScopeId: 'app',
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English, no country code
            ],
            onGenerateTitle: (BuildContext context) =>
                AppLocalizations.of(context)!.appTitle,
            themeMode: settingsController.themeMode,
            theme: ThemeData(
              primaryColor: AppColors.primaryColor,
              scaffoldBackgroundColor: AppColors.backgroundColor,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.primaryColor,
                titleTextStyle: TextStyle(color: Colors.white),
              ),
              textTheme: const TextTheme(
                bodyMedium: TextStyle(color: AppColors.textColor),
              ),
              colorScheme: ColorScheme.fromSwatch().copyWith(
                primary: AppColors.primaryColor,
                secondary: AppColors.secondaryColor,
              ),
            ),
            darkTheme: ThemeData.dark().copyWith(
              primaryColor: AppColors.primaryColor,
              scaffoldBackgroundColor: Colors.black,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.primaryColor,
                titleTextStyle: TextStyle(color: Colors.white),
              ),
              textTheme: const TextTheme(
                bodyMedium: TextStyle(color: Colors.white),
              ),
              colorScheme: const ColorScheme.dark().copyWith(
                primary: AppColors.primaryColor,
                secondary: AppColors.secondaryColor,
              ),
            ),
            initialRoute: AppRoutes.welcome,
            routes: Map.fromEntries(
              AppRoutes.routes(settingsController).entries.map(
                    (entry) => MapEntry(
                      entry.key,
                      (context) => SessionTimeoutManager(
                        child: AuthGuard(
                          routeName: entry.key,
                          child: entry.value(context),
                        ),
                      ),
                    ),
                  ),
            ),
          ),
        );
      },
    );
  }
}




/// The Widget that configures your application.
/* class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  // final SettingsController settingsController;
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
          initialRoute: AppRoutes.welcome,
          routes: Map.fromEntries(
            AppRoutes.routes.entries.map(
              (entry) => MapEntry(
                entry.key,
                (context) => SessionTimeoutManager(
                  child: AuthGuard(
                    routeName: entry.key,
                    child: entry.value(context),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} */
