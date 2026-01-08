import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/network/api_client.dart';

class VisitPage extends StatefulWidget {
  const VisitPage({super.key});

  @override
  State<VisitPage> createState() => _VisitPageState();
}

class _VisitPageState extends State<VisitPage> {
  List visits = [];
  bool loading = true;

  DateTime selectedMonth = DateTime.now();
  final DateTime currentMonth =
      DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    _loadVisits();
  }

  Future<void> _loadVisits() async {
    try {
      setState(() => loading = true);

      final monthStr = DateFormat("yyyy-MM").format(selectedMonth);
      final res = await ApiClient.get("/nurse/visits?month=$monthStr");

      setState(() {
        visits = res ?? [];
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  void _changeMonth(int diff) {
    final newMonth =
        DateTime(selectedMonth.year, selectedMonth.month + diff);

    // ❌ BLOCK FUTURE MONTH
    if (newMonth.isAfter(currentMonth)) return;

    setState(() => selectedMonth = newMonth);
    _loadVisits();
  }

  @override
  Widget build(BuildContext context) {
    final bool isCurrentMonth =
        selectedMonth.year == currentMonth.year &&
            selectedMonth.month == currentMonth.month;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Visits"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          /// 📅 MONTH SELECTOR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeMonth(-1),
                ),
                Text(
                  DateFormat("MMMM yyyy").format(selectedMonth),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.chevron_right,
                    color: isCurrentMonth
                        ? Colors.grey.shade400
                        : Colors.black,
                  ),
                  onPressed:
                      isCurrentMonth ? null : () => _changeMonth(1),
                ),
              ],
            ),
          ),

          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())

                /// 🔴 EMPTY STATE
                : visits.isEmpty
                    ? _EmptyVisits(onRefresh: _loadVisits)

                    /// ✅ VISITS LIST
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: visits.length,
                        itemBuilder: (context, index) {
                          final v = visits[index];

                          return _VisitCard(
                            patientName:
                                v["patient_name"] ?? "Unknown",
                            address: v["address"] ?? "N/A",
                            completed: v["completed"] ?? false,
                            onComplete: () =>
                                _completeVisit(v["visit_id"]),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeVisit(String visitId) async {
    try {
      await ApiClient.post(
          "/nurse/visits/$visitId/complete", {});
      _snack("Visit marked as completed");
      _loadVisits();
    } catch (_) {
      _snack("Failed to complete visit");
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}

/// ================= EMPTY STATE =================

class _EmptyVisits extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyVisits({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 90,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            const Text(
              "Visit Not Available Now",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "You currently have no assigned patient visits.\nPlease check again later.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Text("Refresh"),
              ),
              onPressed: onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}

/// ================= VISIT CARD =================

class _VisitCard extends StatelessWidget {
  final String patientName;
  final String address;
  final bool completed;
  final VoidCallback onComplete;

  const _VisitCard({
    required this.patientName,
    required this.address,
    required this.completed,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 👤 NAME + STATUS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  patientName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _StatusBadge(completed: completed),
              ],
            ),

            const SizedBox(height: 10),

            /// 📍 ADDRESS
            Row(
              children: [
                const Icon(Icons.location_on,
                    size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    address,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),

            if (!completed) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text("Mark as Completed"),
                  onPressed: onComplete,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ================= STATUS BADGE =================

class _StatusBadge extends StatelessWidget {
  final bool completed;
  const _StatusBadge({required this.completed});

  @override
  Widget build(BuildContext context) {
    final color = completed ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
