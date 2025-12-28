import 'package:flutter/material.dart';
import 'package:healthcare/features/duty/visit_page.dart';
import 'package:healthcare/features/staff/staff_profile_page.dart';

import '../features/duty/dashboard_page.dart';
import '../features/staff/staff_apply_page.dart';
import '../features/sos/sos_page.dart';
import '../features/auth/login_page.dart';

class AppRoutes {
  static const String login = "/";
  static const String dashboard = "/dashboard";
  static const String apply = "/apply";
  static const String sos = "/sos";
  static const String profile = "/profile";
  static const String visits = "/visits";

  static Map<String, WidgetBuilder> routes = {
    login: (_) => const LoginPage(),
    dashboard: (_) => const DashboardPage(),
    apply: (_) => const StaffApplyPage(),
    sos: (_) => const SOSPage(),
    profile: (_) => const StaffProfilePage(),
    visits: (_) => const VisitPage(),
  };
}
