import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import 'dashboard_service.dart';

import 'profile_header_section.dart';
import 'active_visits_section.dart';
import 'weekly_work_graph.dart';
import 'action_cards_section.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<Map<String, dynamic>> dashboardFuture;

  @override
  void initState() {
    super.initState();
    dashboardFuture = DashboardService.fetchDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text("Dashboard"), centerTitle: true),
      body: FutureBuilder<Map<String, dynamic>>(
        future: dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;
          final nurse = data["nurse"];
          final visits = data["today_visits"];
          final weeklyHours = data["weekly_hours"];

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 👤 PROFILE HEADER
                ProfileHeader(
                  name: nurse["name"],
                  ward: nurse["nurse_type"],
                  status: nurse["status"],
                  workedTime: nurse["worked_time"],
                ),

                const SizedBox(height: 28),

                /// 📍 TODAY VISITS
                SectionWrapper(
                  title: "Today's Visits",
                  child: ActiveVisitsSection(visits: visits),
                ),

                const SizedBox(height: 28),

                /// 📊 WEEKLY GRAPH
                SectionWrapper(
                  title: "Weekly Work Hours",
                  child: WeeklyWorkGraph(hours: weeklyHours),
                ),

                const SizedBox(height: 28),

                /// ⚡ ACTIONS
                SectionWrapper(
                  title: "Quick Actions",
                  child: ActionCardsSection(staffId: '',),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 🔹 SECTION WRAPPER
class SectionWrapper extends StatelessWidget {
  final String title;
  final Widget child;

  const SectionWrapper({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(10), child: child),
    );
  }
}
