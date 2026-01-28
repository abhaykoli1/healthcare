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
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme.copyWith(brightness: Brightness.dark),
      themeMode: ThemeMode.light,

      initialRoute: AppRoutes.root,
      routes: AppRoutes.routes,
    );
  }
}

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:healthcare/core/theme/app_theme.dart';
// import 'package:healthcare/routes/app_routes.dart';
// import 'core/lang/language_provider.dart';

// class HospitalApp extends ConsumerWidget {
//   const HospitalApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final locale = ref.watch(languageProvider);

//     return MaterialApp(
//       title: 'Hospital Management',
//       debugShowCheckedModeBanner: false,

//       theme: AppTheme.lightTheme,
//       themeMode: ThemeMode.light,

//       locale: locale,

//       supportedLocales: const [
//         Locale('en'),
//         Locale('hi'),
//         Locale('gu'),
//         Locale('bn'),
//         Locale('mr'),
//         Locale('ta'),
//         Locale('te'),
//         Locale('kn'),
//       ],

//       localizationsDelegates: const [
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],

//       initialRoute: AppRoutes.root,
//       routes: AppRoutes.routes,
//     );
//   }
// }
