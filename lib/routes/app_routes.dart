import 'package:flutter/material.dart';
import 'package:healthcare/features/patient/patient_details_page.dart';
import 'package:healthcare/features/patient/patients_list_page.dart';
import 'package:healthcare/features/patient/patients_page.dart';

// AUTH
import '../features/auth/login_page.dart';
import '../features/auth/otp_page.dart';

// STAFF
import '../features/staff/staff_apply_page.dart';
import '../features/staff/staff_profile_page.dart';

// DUTY
import '../features/duty/dashboard_page.dart';
import '../features/duty/visit_page.dart';

// SOS
import '../features/sos/sos_page.dart';

class AppRoutes {
  // 🔐 AUTH
  static const String login = "/";
  static const String otp = "/otp";
  static const String patientsList = "/patients-list";
  static const String patientsDetails = "/patients-details";

  // 🏠 MAIN
  static const String dashboard = "/dashboard";

  // 👩‍⚕️ STAFF
  static const String apply = "/apply";
  static const String profile = "/profile";

  // 🗓️ DUTY
  static const String visits = "/visits";

  // 🚨 SOS
  static const String sos = "/sos";

  static Map<String, WidgetBuilder> routes = {
    // AUTH
    login: (_) => const LoginPage(),
    otp: (_) => const OtpPage(),
    patientsList: (_) => const PatientsPage(),
    // patientsDetails: (_) => const PatientDetailsPage(),

    // MAIN
    dashboard: (_) => const DashboardPage(),

    // STAFF
    apply: (_) => const StaffApplyPage(),
    profile: (_) => const StaffProfilePage(),

    // DUTY
    visits: (_) => const VisitPage(),

    // SOS
    sos: (_) => const SOSPage(),
  };
}
