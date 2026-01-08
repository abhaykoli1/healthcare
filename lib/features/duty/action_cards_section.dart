import 'package:flutter/material.dart';
import 'package:healthcare/features/duty/duty_service.dart';
import '../../routes/app_routes.dart';

class ActionCardsSection extends StatelessWidget {
  final String staffId;
  const ActionCardsSection({super.key, required this.staffId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PunchCard(),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
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
          ],
        ),
      ],
    );
  }
}

class PunchCard extends StatefulWidget {
  const PunchCard({super.key});

  @override
  State<PunchCard> createState() => _PunchCardState();
}

class _PunchCardState extends State<PunchCard> {
  bool canPunchIn = false;
  bool canPunchOut = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final status = await DutyService.getDutyStatus();
      setState(() {
        canPunchIn = status["can_punch_in"] ?? false;
        canPunchOut = status["can_punch_out"] ?? false;
        loading = false;
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            const Text(
              "Duty Attendance",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                /// 🟢 PUNCH IN
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.login),
                    label: const Text("IN"),
                    onPressed: (!canPunchIn || loading)
                        ? null
                        : () => _handlePunch(inOut: true),
                  ),
                ),

                const SizedBox(width: 10),

                /// 🔴 PUNCH OUT
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text("OUT"),
                    onPressed: (!canPunchOut || loading)
                        ? null
                        : () => _handlePunch(inOut: false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 SIMPLE PUNCH FLOW (NO BIOMETRIC)
  Future<void> _handlePunch({required bool inOut}) async {
    try {
      setState(() => loading = true);

      if (inOut) {
        await DutyService.checkIn();
      } else {
        await DutyService.checkOut();
      }

      await _loadStatus();

      _snack(inOut ? "Punch IN successful" : "Punch OUT successful");
    } catch (e) {
      _snack(e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}

/// Generic dashboard card
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
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
