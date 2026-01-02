import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes/app_routes.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: HospitalApp()));
}

class HospitalApp extends StatelessWidget {
  const HospitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hospital Management',
      debugShowCheckedModeBanner: false,

      // 🌞 Light Theme
      theme: AppTheme.lightTheme,

      // 🌚 Dark Theme (ready for future)
      darkTheme: AppTheme.lightTheme.copyWith(brightness: Brightness.dark),

      themeMode: ThemeMode.light,

      initialRoute: AppRoutes.patientsList,
      routes: AppRoutes.routes,
    );
  }
}
