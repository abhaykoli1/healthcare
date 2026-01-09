import 'package:flutter/material.dart';
import 'package:healthcare/features/duty/consent_service.dart';
import 'package:healthcare/features/duty/nurse_consent_page.dart';


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
  Future<Map<String, dynamic>>? _dashboardFuture;
  bool _checkingConsent = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  /// 🔥 STEP 1: Check consent → then load dashboard
  Future<void> _bootstrap() async {
    try {
      final signed = await ConsentService.isConsentSigned();

      if (!signed && mounted) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const NurseConsentPage(),
            fullscreenDialog: true,
          ),
        );

        /// Consent page must return true
        if (result != true) {
          return;
        }
      }

      if (mounted) {
        setState(() {
          _dashboardFuture = DashboardService.fetchDashboard();
          _checkingConsent = false;
        });
      }
    } catch (e) {
      _checkingConsent = false;
      _showError(e.toString());
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    /// 🔒 While consent is being checked
    if (_checkingConsent || _dashboardFuture == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  snapshot.error.toString(),
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final data = snapshot.data!;
            final nurse = data["nurse"];

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _dashboardFuture = DashboardService.fetchDashboard();
                });
              },
              child: CustomScrollView(
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
                      visits: data["today_visits"] ?? [],
                    ),
                  ),

                  /// 📊 WEEKLY GRAPH
                  _Section(
                    title: "Weekly Work Hours",
                    child: WeeklyWorkGraph(
                      hours: data["weekly_hours"] ?? [],
                    ),
                  ),

                  /// ⚡ ACTIONS
                  _Section(
                    title: "Quick Actions",
                    child: ActionCardsSection(
                      staffId: nurse["nurse_id"],
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 30),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// ================= SECTION WRAPPER =================

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
