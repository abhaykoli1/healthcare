import 'dart:convert';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:healthcare/core/network/api_client.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:healthcare/features/duty/attendance.dart';
import 'package:healthcare/features/duty/biometric_auth.dart';
import 'package:healthcare/features/duty/duty_service.dart';
import '../../routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActionCardsSection extends StatelessWidget {
  final String staffId;
  final String status;

  const ActionCardsSection({
    super.key,
    required this.staffId,
    required this.status,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12.0),
          child: PunchCard(status: status),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 11,
          mainAxisSpacing: 11,
          children: [
            _DashboardCard(
              icon: Icons.assignment,
              title: "Visits",
              color: Colors.purple,
              onTap: () => Navigator.pushNamed(context, AppRoutes.visits),
            ),
            _DashboardCard(
              icon: Icons.warning_amber_rounded,
              title: "SOS",
              color: Colors.red,
              onTap: () => Navigator.pushNamed(context, AppRoutes.sos),
            ),
            _DashboardCard(
              icon: Icons.calendar_month,
              title: "Attendance",
              color: Colors.green.shade200,
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => NurseAttendancePage(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class PunchCard extends StatefulWidget {
  final String status;

  const PunchCard({super.key, required this.status});
  @override
  State<PunchCard> createState() => _PunchCardState();
}

class _PunchCardState extends State<PunchCard> {
  bool canPunchIn = true;
  bool canPunchOut = true;
  bool loading = true;
  Timer? _locationTimer;

  void startLiveTracking() {
    if (_locationTimer != null) return; // 🔐 already running

    sendLiveLocation();

    _locationTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => sendLiveLocation(),
    );

    print("🟢 Live tracking started");
  }

  void stopLiveTracking() {
    _locationTimer?.cancel();
    _locationTimer = null;

    print("🔴 Live tracking stopped");
  }

  @override
  void initState() {
    super.initState();
    _applyStatus(widget.status);

    // 🔁 Resume tracking if already on duty
    if (widget.status == "ACTIVE") {
      startLiveTracking();
    }
  }

  void _applyStatus(String status) {
    loading = false;
    canPunchIn = status != "ACTIVE";
    canPunchOut = status == "ACTIVE";
  }

  // 🔁 Load punch status
  Future<void> _loadStatus() async {
    try {
      final status = await DutyService.getDutyStatus();
      if (!mounted) return;
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  Future<void> sendLiveLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print("❌ Location permission denied");
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      await ApiClient.post("/nurse/location/update", {
        "latitude": position.latitude,
        "longitude": position.longitude,
      });

      print("📡 Location sent: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      print("⚠️ Location send failed: $e");
    }
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            const Text(
              "Duty Attendance",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              widget.status == "ACTIVE" ? "On Duty" : "Off Duty",
              style: TextStyle(
                color: widget.status == "ACTIVE" ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),

            Row(
              children: [
                // 🟢 PUNCH IN
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.login),
                    label: const Text("IN"),
                    onPressed: (!canPunchIn || loading)
                        ? null
                        : () => _handlePunchWithBiometric(inOut: true),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // 🔴 PUNCH OUT
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text("OUT"),
                    onPressed: (!canPunchOut || loading)
                        ? null
                        : () => _handlePunchWithBiometric(inOut: false),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🔐 STEP 1: BIOMETRIC CHECK
  Future<void> _handlePunchWithBiometric({required bool inOut}) async {
    final authenticated = await BiometricAuth.authenticate(
      reason: inOut ? "Authenticate to Punch IN" : "Authenticate to Punch OUT",
    );

    if (!authenticated) {
      _snack("Authentication failed. Punch not allowed.");
      return;
    }

    // ✅ BIOMETRIC OK → API CALL
    await _handlePunch(inOut: inOut);
  }

  Future<void> _handlePunch({required bool inOut}) async {
    try {
      setState(() {
        loading = true;

        if (inOut) {
          canPunchIn = false;
          canPunchOut = true;
        } else {
          canPunchIn = true;
          canPunchOut = false;
        }
      });
      // ⭐ save immediately (offline safe)

      if (inOut) {
        await DutyService.checkIn();
        // 🟢 START LIVE TRACKING
        startLiveTracking();
      } else {
        await DutyService.checkOut();
        // 🔴 STOP LIVE TRACKING
        stopLiveTracking();
      }

      await _loadStatus();

      _snack(inOut ? "Punch IN successful" : "Punch OUT successful");
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

/// ================= DASHBOARD CARD =================

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Card(
        color: Colors.grey.shade50,
        elevation: .5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
