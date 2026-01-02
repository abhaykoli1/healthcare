import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../routes/app_routes.dart';
import '../duty/punch_provider.dart';

class ActionCardsSection extends StatelessWidget {
  final String staffId;
  const ActionCardsSection({super.key, required this.staffId});

  //  PunchCard(staffId: staffId),
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PunchCard(staffId: staffId),
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

/// 🔥 SMART PUNCH CARD (Riverpod safe)
class PunchCard extends ConsumerStatefulWidget {
  final String staffId;
  const PunchCard({super.key, required this.staffId});

  @override
  ConsumerState<PunchCard> createState() => _PunchCardState();
}

class _PunchCardState extends ConsumerState<PunchCard> {
  bool isPunchedIn = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: isPunchedIn
                        ? null
                        : () => _showPunchInDialog(context),
                  ),
                ),

                const SizedBox(width: 10),

                /// 🔴 PUNCH OUT
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text("OUT"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: isPunchedIn
                        ? () async {
                            await ref
                                .read(punchProvider)
                                .outDuty(widget.staffId);

                            setState(() => isPunchedIn = false);

                            _snack("Punch Out successful");
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🔔 Punch In Dialog
  void _showPunchInDialog(BuildContext context) {
    final now = DateTime.now();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Confirm Punch In"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _InfoRow("Date", _fmtDate(now)),
            _InfoRow("Time", _fmtTime(now)),
            const SizedBox(height: 10),
            const Text(
              "Do you want to start duty now?",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              await ref
                  .read(punchProvider)
                  .inDuty(staffId: widget.staffId, location: "Hospital Ward A");

              setState(() => isPunchedIn = true);

              _snack("Punch In successful");
            },
            child: const Text("CONFIRM"),
          ),
        ],
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _fmtDate(DateTime d) => "${d.day}/${d.month}/${d.year}";
  String _fmtTime(DateTime d) =>
      "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
}

/// Helper Row
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
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
