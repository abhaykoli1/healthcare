import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/network/api_client.dart';

class NurseAttendancePage extends StatefulWidget {
  const NurseAttendancePage({super.key});

  @override
  State<NurseAttendancePage> createState() => _NurseAttendancePageState();
}

class _NurseAttendancePageState extends State<NurseAttendancePage> {
  DateTime selectedMonth = DateTime.now();

  bool loading = true;

  List<Map<String, dynamic>> attendance = [];
  int present = 0;
  int absent = 0;
  int half = 0;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() => loading = true);

    try {
      final monthStr = DateFormat("yyyy-MM").format(selectedMonth);

      final res =
          await ApiClient.get("/nurse/attendance?month=$monthStr");

      setState(() {
        attendance =
            List<Map<String, dynamic>>.from(res["attendance"] ?? []);

        present = res["summary"]["present"] ?? 0;
        absent = res["summary"]["absent"] ?? 0;
        half = res["summary"]["half"] ?? 0;

        loading = false;
      });
    } catch (e) {
      loading = false;
      _snack("Failed to load attendance");
      setState(() {});
    }
  }

  void _changeMonth(int diff) {
    setState(() {
      selectedMonth =
          DateTime(selectedMonth.year, selectedMonth.month + diff);
    });
    _loadAttendance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Attendance"),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// 📅 MONTH SELECTOR
                  _MonthSelector(
                    month: selectedMonth,
                    onPrev: () => _changeMonth(-1),
                    onNext: () => _changeMonth(1),
                  ),

                  const SizedBox(height: 20),

                  /// 📊 SUMMARY
                  Row(
                    children: [
                      _SummaryCard(
                        title: "Present",
                        count: present,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 12),
                      _SummaryCard(
                        title: "Absent",
                        count: absent,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 12),
                      _SummaryCard(
                        title: "Half Day",
                        count: half,
                        color: Colors.orange,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// 📋 DAILY LIST
                  Expanded(
                    child: attendance.isEmpty
                        ? _EmptyAttendance(onRefresh: _loadAttendance)
                        : ListView.builder(
                            itemCount: attendance.length,
                            itemBuilder: (context, index) {
                              final a = attendance[index];
                              return _AttendanceTile(
                                day: a["day"],
                                status: a["status"],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}

/// ================= EMPTY STATE =================

class _EmptyAttendance extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyAttendance({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            "No attendance found",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "Attendance data is not available for this month",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text("Refresh"),
            onPressed: onRefresh,
          )
        ],
      ),
    );
  }
}

/// ================= MONTH SELECTOR =================

class _MonthSelector extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _MonthSelector({
    required this.month,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: onPrev,
        ),
        Text(
          DateFormat("MMMM yyyy").format(month),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: onNext,
        ),
      ],
    );
  }
}

/// ================= SUMMARY CARD =================

class _SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ================= ATTENDANCE TILE =================

class _AttendanceTile extends StatelessWidget {
  final int day;
  final String status;

  const _AttendanceTile({
    required this.day,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status) {
      case "PRESENT":
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case "ABSENT":
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.orange;
        icon = Icons.timelapse;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(
          "Day $day",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          status,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
