import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VisitPage extends StatelessWidget {
  const VisitPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔹 MOCK VISITS DATA (matches Visit model)
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
      appBar: AppBar(title: const Text("Patient Visits"), centerTitle: true),
      body: visits.isEmpty
          ? const Center(child: Text("No visits scheduled"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: visits.length,
              itemBuilder: (context, index) {
                final visit = visits[index];
                return _VisitCard(visit);
              },
            ),
    );
  }
}

class _VisitCard extends StatelessWidget {
  final Map<String, dynamic> visit;
  const _VisitCard(this.visit);

  @override
  Widget build(BuildContext context) {
    final bool completed = visit["completed"];
    final DateTime time = visit["visit_time"];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  visit["patient_name"],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(
                    completed ? "COMPLETED" : "PENDING",
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: completed ? Colors.green : Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 🔹 Address
            Row(
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    visit["address"],
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 🔹 Time
            Row(
              children: [
                const Icon(Icons.access_time, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(DateFormat("dd MMM yyyy • hh:mm a").format(time)),
              ],
            ),

            const SizedBox(height: 16),

            // 🔹 Action Button
            if (!completed)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // future: mark completed
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text("Mark as Completed"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
