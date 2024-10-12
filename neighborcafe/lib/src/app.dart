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
