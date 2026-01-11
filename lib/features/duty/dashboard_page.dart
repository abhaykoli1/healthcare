import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:healthcare/core/network/api_client.dart';
import 'package:healthcare/core/storage/token_storage.dart';
import 'package:healthcare/features/duty/consent_service.dart';
import 'package:healthcare/features/duty/nurse_consent_page.dart';
import 'package:healthcare/features/duty/nurse_profile.dart';
import 'package:image_picker/image_picker.dart';

import 'dashboard_service.dart';

import 'profile_header_section.dart';
import 'active_visits_section.dart';
import 'weekly_work_graph.dart';
import 'action_cards_section.dart';

class ConsentService {
  static Future<Map<String, dynamic>> checkConsentStatus() async {
    final res = await ApiClient.get("/nurse/consent/status");
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

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    /// 🔐 CLEAR TOKEN
    await TokenStorage.clearToken();

    if (!mounted) return;

    /// 🚪 Redirect to Login
    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
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
                      child: GestureDetector(
                        onTap: (){
                          Navigator.push(context, CupertinoPageRoute(builder: (context) => NurseDetailPage()));
                        },
                        child: ProfileHeader(
                          name: nurse["name"],
                          ward: nurse["nurse_type"],
                          status: nurse["status"],
                          workedTime: nurse["worked_time"],
                        ),
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

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: const Text(
                            "Logout",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 3,
                          ),
                        ),
                      ),
                    ),
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

class NurseConsentPage extends StatefulWidget {
  final Map<String, dynamic> statusData;

  const NurseConsentPage({super.key, required this.statusData});

  @override
  State<NurseConsentPage> createState() => _NurseConsentPageState();
}

class _NurseConsentPageState extends State<NurseConsentPage> {
  File? signatureFile;
  bool loading = false;

  final ImagePicker _picker = ImagePicker();

  bool get canSignConsent =>
      widget.statusData["police_verified"] == "CLEAR" &&
      widget.statusData["aadhaar_verified"] == true;

  Future<void> pickSignature() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        signatureFile = File(picked.path);
      });
    }
  }

  Future<void> submitConsent() async {
    if (signatureFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload your signature before submitting."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      // Convert file to base64
      final bytes = await signatureFile!.readAsBytes();
      final base64Signature = "data:image/png;base64,${base64Encode(bytes)}";

      final res = await ApiClient.post("/nurse/consent/sign", {
        "confidentiality_accepted": true,
        "no_direct_payment_accepted": true,
        "police_termination_accepted": true,
        "signature_image": base64Signature,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res["message"] ?? "Consent signed successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to sign consent: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("👩‍⚕️ Staff Legal Declaration & Undertaking"),
        leading: Container(),
      ),
      backgroundColor: const Color(0xffF5F7FB),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ================= LEGAL DECLARATION =================
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "1️⃣ Main declare karta/karti hoon ki mere sabhi documents genuine hain...",
                      style: TextStyle(fontSize: 14.5, height: 1.5),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "2️⃣ Main company ke sabhi rules – duty timing, transfer...",
                      style: TextStyle(fontSize: 14.5, height: 1.5),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "3️⃣ Patient ki medical information, photos, videos...",
                      style: TextStyle(fontSize: 14.5, height: 1.5),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "4️⃣ Bina company ki written permission ke kisi patient se direct payment...",
                      style: TextStyle(fontSize: 14.5, height: 1.5),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "5️⃣ Bina notice duty chhodna company ke financial loss ka karan...",
                      style: TextStyle(fontSize: 14.5, height: 1.5),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "6️⃣ Patient ke ghar par bidi, cigarette, gutka, alcohol ya drugs...",
                      style: TextStyle(fontSize: 14.5, height: 1.5),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "7️⃣ Patient / relatives ke saath misbehaviour, dhamki ya abuse...",
                      style: TextStyle(fontSize: 14.5, height: 1.5),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "8️⃣ Chori, cheating, fraud, ya company/patient ka nuksaan...",
                      style: TextStyle(fontSize: 14.5, height: 1.5),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "9️⃣ Company ke khilaf patient ko bhadkana, ya confidential info misuse...",
                      style: TextStyle(fontSize: 14.5, height: 1.5),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "🔟 Police verification fail hone par meri service bina notice terminate ki ja sakti hai.",
                      style: TextStyle(fontSize: 14.5, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= CONFIDENTIALITY =================
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: const Text(
                  "🔒 CONFIDENTIALITY & DISCIPLINE\n\n"
                  "Main patient & company data ko misuse nahi karunga/karungi. "
                  "Violation par IT Act 2000 ke tahat action liya ja sakta hai.",
                  style: TextStyle(fontSize: 14.5, height: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ================= SIGNATURE UPLOAD =================
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      "Upload your signature",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: pickSignature,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: signatureFile != null
                            ? Image.file(signatureFile!, fit: BoxFit.contain)
                            : const Center(
                                child: Text(
                                  "Tap to upload signature",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: loading ? null : submitConsent,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Submit & Sign",
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
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
