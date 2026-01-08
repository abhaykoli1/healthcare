import 'package:flutter/material.dart';
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
      backgroundColor: const Color(0xffF5F7FB),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
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

            return CustomScrollView(
              slivers: [
                /// 🔷 HEADER
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ProfileHeader(
                      name: nurse["name"],
                      ward: nurse["nurse_type"],
                      status: nurse["status"],
                      workedTime: nurse["worked_time"],
                    ),
                  ),
                ),

                /// 📍 TODAY VISITS
                _Section(
                  title: "Today's Visits",
                  child: ActiveVisitsSection(
                    visits: data["today_visits"],
                  ),
                ),

                /// 📊 WEEKLY GRAPH
                _Section(
                  title: "Weekly Work Hours",
                  child: WeeklyWorkGraph(
                    hours: data["weekly_hours"],
                  ),
                ),

                /// ⚡ ACTIONS
                _Section(
                  title: "Quick Actions",
                  child: ActionCardsSection(staffId: nurse['nurse_id']),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
