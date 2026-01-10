import 'package:flutter/material.dart';
import 'package:healthcare/core/network/api_client.dart';
import 'package:healthcare/features/duty/consent_service.dart';
import 'package:healthcare/features/duty/nurse_consent_page.dart';

import 'dashboard_service.dart';

import 'profile_header_section.dart';
import 'active_visits_section.dart';
import 'weekly_work_graph.dart';
import 'action_cards_section.dart';

class ConsentService {
  static Future<Map<String, dynamic>> checkConsentStatus() async {
    final res = await ApiClient.get("/consent/status");
    return res;
  }

  static Future<bool> isFullyVerified() async {
    final data = await checkConsentStatus();
    return data["signed"] == true;
  }
}

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

  Future<void> _bootstrap() async {
    try {
      /// 🔍 Step 1: Check consent + verification
      final consentData = await ConsentService.checkConsentStatus();

      final isVerified = consentData["signed"] == true;

      /// ❌ If ANY requirement missing → force consent page
      if (!isVerified && mounted) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NurseConsentPage(
              statusData: consentData, // 🔥 pass full reason
            ),
            fullscreenDialog: true,
          ),
        );

        /// ❌ Nurse came back without completing flow
        if (result != true) {
          return;
        }

        /// 🔁 Re-check status after consent flow
        final recheck = await ConsentService.checkConsentStatus();
        if (recheck["signed"] != true) {
          _showError("Verification still pending");
          return;
        }
      }

      /// ✅ All conditions passed → load dashboard
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    /// 🔒 While consent is being checked
    if (_checkingConsent || _dashboardFuture == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
                    child: WeeklyWorkGraph(hours: data["weekly_hours"] ?? []),
                  ),

                  /// ⚡ ACTIONS
                  _Section(
                    title: "Quick Actions",
                    child: ActionCardsSection(staffId: nurse["nurse_id"]),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 30)),
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

  const _Section({required this.title, required this.child});

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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class NurseConsentPage extends StatelessWidget {
  final Map<String, dynamic> statusData;

  const NurseConsentPage({super.key, required this.statusData});

  @override
  Widget build(BuildContext context) {
    final reason = statusData["reason"];
    final policeStatus = statusData["police_verified"];
    final aadhaarVerified = statusData["aadhaar_verified"] == true;

    final canSignConsent = policeStatus == "CLEAR" && aadhaarVerified == true;

    return Scaffold(
      appBar: AppBar(title: const Text("Complete Verification")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔴 Police pending
            if (policeStatus != "CLEAR")
              _InfoCard(
                icon: Icons.local_police,
                text:
                    "Please wait for the police and admin verification. "
                    "You will be notified once it is completed.",
              ),

            /// 🔴 Aadhaar not verified
            if (!aadhaarVerified)
              _InfoCard(
                icon: Icons.credit_card,
                text:
                    "Aadhaar verification is not completed yet. "
                    "Please wait for admin verification.",
              ),

            /// 🟡 Consent not signed (but allowed)
            if (reason == "CONSENT_NOT_SIGNED" && canSignConsent)
              _InfoCard(
                icon: Icons.edit_document,
                text:
                    "Please review the consent details carefully and sign to continue.",
              ),

            const SizedBox(height: 24),

            /// ✅ Show consent button ONLY when allowed
            if (canSignConsent)
              ElevatedButton(
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Still working on this feature..."),
                    ),
                  );
                },
                child: const Text("Sign Consent"),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _InfoCard({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColor.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: themeColor, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.5,
                color: Colors.grey.shade800,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
