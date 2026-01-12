import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:healthcare/features/doctor/doctor_home.dart';
import '../../core/storage/token_storage.dart';
import '../../routes/app_routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await TokenStorage.getToken();
    final role = await TokenStorage.getRole();

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      if (role == "DOCTOR") {
        Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => const DoctorProfilePage()));
      } else if (role == "NURSE") {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      }
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
