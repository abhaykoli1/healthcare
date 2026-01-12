import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:healthcare/core/theme/app_theme.dart';
import '../../core/network/api_client.dart';

class NurseDetailPage extends StatefulWidget {
  const NurseDetailPage({super.key});

  @override
  State<NurseDetailPage> createState() => _NurseDetailPageState();
}

class _NurseDetailPageState extends State<NurseDetailPage> {
  Map? data;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchNurseDetail();
  }

  Future<void> _fetchNurseDetail() async {
    try {
      final res = await ApiClient.get("/nurse/profile/me/json");
      setState(() {
        data = res;
        loading = false;
      });
    } catch (e) {
      print("Error fetching nurse details: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (data == null)
      return const Scaffold(body: Center(child: Text("No data")));

    final nurse = data!['nurse'];
    final kpi = data!['kpi'];
    final graph = data!['attendance_graph'];
    final attendanceRecords = data!['attendance_records'];
    final visits = data!['recent_visits'];

    return Scaffold(
      backgroundColor: AppTheme.primarylight,

      appBar: AppBar(title: Text(nurse['phone'] ?? "Nurse Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===== BASIC INFO CARD =====
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              color: AppTheme.primary.withOpacity(.8),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (nurse['profile_photo'] != null)
                      CircleAvatar(
                        radius: 45,
                        backgroundImage: NetworkImage(nurse['profile_photo']),
                      ),

                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nurse['phone'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text("${nurse['nurse_type']} Nurse"),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 4,
                            runSpacing: 0,
                            children: [
                              if (nurse['aadhaar_verified'] == true)
                                Chip(
                                  label: Text(
                                    "Aadhaar Verified",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  backgroundColor: Colors.green.shade100,
                                ),
                              Chip(
                                label: Text(
                                  style: TextStyle(color: Colors.black),
                                  nurse['verification_status'] ?? "N/A",
                                ),
                                backgroundColor: Colors.orange.shade100,
                              ),
                              Chip(
                                label: Text(
                                  style: TextStyle(color: Colors.black),
                                  nurse['police_verification_status'] ?? "N/A",
                                ),
                                backgroundColor: Colors.blue.shade100,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ===== KPI CARDS =====
            _buildKpiSection(kpi),
            const SizedBox(height: 20),

            // ===== ATTENDANCE GRAPH CARD =====
            _buildAttendanceGraphSection(graph),
            const SizedBox(height: 20),

            // ===== ATTENDANCE RECORDS CARD =====
            _buildSectionCard(
              "🗓 Attendance Records",
              List<Widget>.from(
                attendanceRecords.map(
                  (a) => ListTile(
                    leading: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.blue,
                    ),
                    title: Text(a['date']),
                    subtitle: Text(
                      "In: ${a['check_in'] ?? '-'} | Out: ${a['check_out'] ?? '-'} | ${a['method']}",
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ===== RECENT VISITS CARD =====
            _buildSectionCard(
              "🏥 Recent Visits",
              List<Widget>.from(
                visits.map(
                  (v) => ListTile(
                    leading: const Icon(
                      Icons.local_hospital,
                      color: Colors.green,
                    ),
                    title: Text(v['visit_type']),
                    subtitle: Text(
                      "Patient: ${v['patient_id']} | ${v['visit_time']}",
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ===== DOCUMENTS CARDS =====
            // _buildSectionCard(
            //   "📄 Qualification Documents",
            //   List<Widget>.from(
            //     (nurse['qualification_docs'] as List).map(
            //       (doc) => ListTile(
            //         leading: const Icon(
            //           Icons.file_present,
            //           color: Colors.orange,
            //         ),
            //         title: Text(doc),
            //       ),
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 10),
            // _buildSectionCard(
            //   "📄 Experience Documents",
            //   List<Widget>.from(
            //     (nurse['experience_docs'] as List).map(
            //       (doc) => ListTile(
            //         leading: const Icon(
            //           Icons.file_present,
            //           color: Colors.orange,
            //         ),
            //         title: Text(doc),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // ================= KPI SECTION =================
  // Widget _buildKpiSection(Map kpi) {
  //   return Wrap(
  //     spacing: 12,
  //     runSpacing: 12,
  //     children: [
  //       _kpiCard("Attendance", "${kpi['attendance']} Days"),
  //       _kpiCard(
  //         "Salary",
  //         "₹ ${kpi['salary'] ?? 'N/A'}",
  //         extra: kpi['salary_paid'] != null
  //             ? (kpi['salary_paid'] ? "Paid" : "Unpaid")
  //             : null,
  //       ),
  //       _kpiCard(
  //         "Active Duty",
  //         kpi['active_duty'] ?? "N/A",
  //         extra: kpi['shift'],
  //       ),
  //       _kpiCard(
  //         "Consent Status",
  //         kpi['consent_status'] ?? "N/A",
  //         extra: kpi['consent_version'] != null
  //             ? "Version ${kpi['consent_version']}"
  //             : null,
  //       ),
  //     ],
  //   );
  // }

  Widget _buildKpiSection(Map kpi) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: width,
              child: _kpiCard("Attendance", "${kpi['attendance']} Days"),
            ),
            SizedBox(
              width: width,
              child: _kpiCard("Salary", "₹ ${kpi['salary'] ?? 'N/A'}"),
            ),
            SizedBox(
              width: width,
              child: _kpiCard(
                "Active Duty",
                kpi['active_duty'] ?? "N/A",
                extra: kpi['shift'],
              ),
            ),
            SizedBox(
              width: width,
              child: _kpiCard(
                "Consent Status",
                kpi['consent_status'] ?? "N/A",
                extra: kpi['consent_version'] != null
                    ? "Version ${kpi['consent_version']}"
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }

  // Widget _kpiCard(String title, String value, {String? extra}) => Container(
  //   // width: 100%,
  //   padding: const EdgeInsets.all(12),
  //   decoration: BoxDecoration(
  //     borderRadius: BorderRadius.circular(12),
  //     color: Colors.grey.shade200,
  //   ),
  //   child: Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
  //       const SizedBox(height: 6),
  //       Text(
  //         value,
  //         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //       ),
  //       if (extra != null)
  //         Text(extra, style: const TextStyle(fontSize: 12, color: Colors.grey)),
  //     ],
  //   ),
  // );
  Widget _kpiCard(String title, String value, {String? extra}) {
    return Material(
      elevation: 3, // 👈 yahin elevation
      borderRadius: BorderRadius.circular(12),
      // color: Colors.grey.shade200,
      shadowColor: Colors.black.withOpacity(0.2),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (extra != null)
              Text(
                extra,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  // ================= ATTENDANCE GRAPH SECTION =================
  Widget _buildAttendanceGraphSection(Map graph) {
    final maxY =
        (graph['values'] as List).fold(0, (a, b) => a > b ? a : b).toDouble() +
        1;
    return Card(
      elevation: .5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "📊 Weekly Attendance",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barGroups: List.generate(
                    graph['values'].length,
                    (i) => BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: (graph['values'][i] as int).toDouble(),
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) =>
                            Text("${graph['labels'][value.toInt()]}"),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= GENERIC SECTION CARD =================
  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: .5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}
