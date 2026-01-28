import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:healthcare/core/theme/app_theme.dart';
import 'package:healthcare/features/auth/about_us_page.dart';
import 'package:healthcare/features/duty/nurse_profile_edit_page.dart';
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

    assert(() {
      print("GRAPH: $graph");
      print("LABELS TYPE: ${graph['labels'][0].runtimeType}");
      print("VALUES TYPE: ${graph['values'][0].runtimeType}");
      return true;
    }());
    final attendanceRecords = data!['attendance_records'];
    final visits = data!['recent_visits'];

    return Scaffold(
      backgroundColor: AppTheme.primarylight,
      // nurse['name'] ??
      appBar: AppBar(
        title: const Text("Nurse Details"),

        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline), // about icon
            tooltip: "About Us",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutUsPage()),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
        child: Column(
          children: [
            // ===== BASIC INFO CARD =====

            // const SizedBox(height: 20),
            Stack(
              children: [
                /// MAIN CARD
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  color: AppTheme.primary,
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        if (nurse['profile_photo'] != null)
                          CircleAvatar(
                            radius: 42,
                            backgroundImage: NetworkImage(
                              nurse['profile_photo'],
                            ),
                          )
                        else
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),

                            child: const CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person,
                                size: 36,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),

                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nurse['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                nurse['phone'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  // fontWeight: FontWeigh,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "${nurse['nurse_type']} Nurse",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 3),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 🔹 First line (single badge)
                                  if (nurse['aadhaar_verified'] == true)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                      child: const Text(
                                        "Aadhar Verified",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),

                                  // 🔹 Second line (two badges)
                                  Wrap(
                                    spacing: 4,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade300,
                                          borderRadius: BorderRadius.circular(
                                            28,
                                          ),
                                        ),
                                        child: Text(
                                          nurse['verification_status'] ?? "N/A",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade100,
                                          borderRadius: BorderRadius.circular(
                                            28,
                                          ),
                                        ),
                                        child: Text(
                                          nurse['police_verification_status'] ??
                                              "N/A",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
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

                /// 🔥 TOP RIGHT ICON
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => const NurseEditProfilePage(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 18,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // ===== KPI CARDS =====
            _buildKpiSection(kpi),
            const SizedBox(height: 20),

            // ===== ATTENDANCE GRAPH CARD =====
            _buildAttendanceGraphSection(graph),
            const SizedBox(height: 20),

            // ===== ATTENDANCE RECORDS CARD =====
            // _buildSectionCard(
            //   "🗓 Attendance Records",
            //   List<Widget>.from(
            //     attendanceRecords.map(
            //       (a) => ListTile(
            //         leading: Icon(
            //           Icons.check_circle_outline,
            //           color: AppTheme.primary,
            //         ),
            //         title: Text(a['date']),
            //         subtitle: Text(
            //           "In: ${a['check_in'] ?? '-'} | Out: ${a['check_out'] ?? '-'} | ${a['method']}",
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 20),

            // ===== RECENT VISITS CARD =====
            // _buildSectionCard(
            //   "🏥 Recent Visits",
            //   List<Widget>.from(
            //     visits.map(
            //       (v) => ListTile(
            //         leading: const Icon(
            //           Icons.local_hospital,
            //           color: Colors.green,
            //         ),
            //         title: Text(v['visit_type']),
            //         subtitle: Text(
            //           "Patient: ${v['patient_id']} | ${v['visit_time']}",
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 20),

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
                // extra: kpi['consent_version'] != null
                //     ? "Version ${kpi['consent_version']}"
                //     : null,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _kpiCard(String title, String value, {String? extra}) {
    return Material(
      elevation: 2, // 👈 yahin elevation
      borderRadius: BorderRadius.circular(12),
      color: Colors.grey.shade50,
      shadowColor: Colors.black.withOpacity(0.2),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (extra != null)
              Text(
                extra,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
          ],
        ),
      ),
    );
  }

  // ================= ATTENDANCE GRAPH SECTION =================
  // Widget _buildAttendanceGraphSection(Map graph) {
  //   final maxY =
  //       (graph['values'] as List).fold(0, (a, b) => a > b ? a : b).toDouble() +
  //       1;
  //   return Card(
  //     elevation: .5,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const Text(
  //             "📊 Weekly Attendance",
  //             style: TextStyle(fontWeight: FontWeight.bold),
  //           ),
  //           const SizedBox(height: 12),
  //           SizedBox(
  //             height: 200,
  //             child: BarChart(
  //               BarChartData(
  //                 alignment: BarChartAlignment.spaceAround,
  //                 maxY: maxY,
  //                 barGroups: List.generate(
  //                   graph['values'].length,
  //                   (i) => BarChartGroupData(
  //                     x: i,
  //                     barRods: [
  //                       BarChartRodData(
  //                         toY: (graph['values'][i] as int).toDouble(),
  //                         color: Colors.blue,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 titlesData: FlTitlesData(
  //                   show: true,
  //                   bottomTitles: AxisTitles(
  //                     sideTitles: SideTitles(
  //                       showTitles: true,
  //                       getTitlesWidget: (value, _) =>
  //                           Text("${graph['labels'][value.toInt()]}"),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildAttendanceGraphSection(Map graph) {
    final List<int> labels = (graph['labels'] as List)
        .map((e) => int.parse(e.toString()))
        .toList();

    final List<int> values = (graph['values'] as List)
        .map((e) => int.parse(e.toString()))
        .toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Monthly Attendance",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                maxY: 1,
                alignment: BarChartAlignment.spaceBetween,
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),

                titlesData: FlTitlesData(
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index < 0 || index >= labels.length) {
                          return const SizedBox();
                        }
                        if (![
                          0,
                          2,
                          4,
                          6,
                          8,
                          10,
                          12,
                          14,
                          16,
                          18,
                          20,
                          22,
                          24,
                          26,
                          28,
                          30,
                        ].contains(index)) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            labels[index].toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // 🔥 BARS (present + absent both visible)
                barGroups: List.generate(
                  values.length,
                  (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: values[i] == 1 ? 1 : 0.15, // 👈 important
                        width: 4,
                        borderRadius: BorderRadius.circular(2),
                        color: values[i] == 1
                            ? Colors.green.shade500
                            : Colors.red.shade400,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 🔹 LEGEND
          Row(
            children: [
              _legendDot(Colors.green.shade500, "Present"),
              const SizedBox(width: 16),
              _legendDot(Colors.red.shade400, "Absent"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
      ],
    );
  }

  Widget _kpiCar8d(String title, String value, {String? extra}) {
    return Material(
      elevation: 2, // 👈 yahin elevation
      borderRadius: BorderRadius.circular(12),
      color: Colors.grey.shade50,
      shadowColor: Colors.black.withOpacity(0.2),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (extra != null)
              Text(
                extra,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
          ],
        ),
      ),
    );
  }

  // ================= GENERIC SECTION CARD =================
  Widget _buildSectionCard(String title, List<Widget> children) {
    return Material(
      elevation: 2, // 👈 yahin elevation
      borderRadius: BorderRadius.circular(12),
      color: Colors.grey.shade50,
      shadowColor: Colors.black.withOpacity(0.2),
      child: Container(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}
