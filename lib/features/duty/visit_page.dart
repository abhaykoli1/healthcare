import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';

class VisitPage extends StatelessWidget {
  const VisitPage({super.key});

  @override
  Widget build(BuildContext context) {
    /// 🔹 MOCK VISITS DATA
    final List<Map<String, dynamic>> visits = [
      {
        "patient_name": "Anita Verma",
        "address": "Flat 12, Green Park, Delhi",
        "visit_time": DateTime.now().add(const Duration(hours: 2)),
        "completed": false,
      },
      {
        "patient_name": "Rajesh Kumar",
        "address": "Sector 21, Noida",
        "visit_time": DateTime.now().subtract(const Duration(hours: 3)),
        "completed": true,
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text("Patient Visits"), elevation: 0),
      body: visits.isEmpty
          ? const Center(
              child: Text(
                "No visits scheduled",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: visits.length,
              itemBuilder: (context, index) {
                return _VisitCard(visit: visits[index]);
              },
            ),
    );
  }
}

class _VisitCard extends StatelessWidget {
  final Map<String, dynamic> visit;
  const _VisitCard({required this.visit});

  @override
  Widget build(BuildContext context) {
    final bool completed = visit["completed"];
    final DateTime time = visit["visit_time"];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 👤 PATIENT + STATUS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  visit["patient_name"],
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                _StatusBadge(completed: completed),
              ],
            ),

            const SizedBox(height: 10),

            /// 📍 ADDRESS
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    visit["address"],
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// ⏰ TIME
            Row(
              children: [
                const Icon(Icons.access_time, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  DateFormat("dd MMM yyyy • hh:mm a").format(time),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),

            if (!completed) ...[
              const SizedBox(height: 16),

              /// ✅ COMPLETE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // future: mark visit completed
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text("Mark as Completed"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 🟢🔴 STATUS BADGE
class _StatusBadge extends StatelessWidget {
  final bool completed;
  const _StatusBadge({required this.completed});

  @override
  Widget build(BuildContext context) {
    final color = completed ? AppTheme.success : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        completed ? "COMPLETED" : "PENDING",
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
