import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:healthcare/core/network/api_client.dart';
import 'package:healthcare/features/doctor/doctor_prescribe.dart';


class PatientDetailPage extends StatefulWidget {
  final String patientId;
  const PatientDetailPage({super.key, required this.patientId});

  @override
  State<PatientDetailPage> createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage> {
  late Future<dynamic> future;

  @override
  void initState() {
    super.initState();
    log(widget.patientId);
    future = ApiClient.get("/patient/${widget.patientId}/view");
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xffF5F7FB),
        appBar: AppBar(
          title: const Text("🧑‍⚕️ Patient Details"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Details"),
              Tab(text: "Vitals"),
              Tab(text: "Medications"),
            ],
          ),
        ),
        body: FutureBuilder<dynamic>(
          future: future,
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snap.data!;
            return TabBarView(
              children: [
                _DetailsTab(data),
                _VitalsTab(data["vitals"]),
                _MedicationsTab(data["medications"]),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DetailsTab extends StatelessWidget {
  final Map data;
  const _DetailsTab(this.data);

  @override
  Widget build(BuildContext context) {
    final patient = data["patient"];
    final duties = data["duties"];
    final notes = data["notes"];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        /// BASIC INFO
        _Card(
          title: "👤 Basic Information",
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 3,
            children: [
              _info("Name", patient["name"]),
              _info("Phone", patient["phone"]),
              _info("Age", patient["age"]),
              _info("Gender", patient["gender"]),
              _info("Address", patient["address"]),
              _info("Service Start", patient["service_start"]),
            ],
          ),
        ),
        GestureDetector(
          onTap: (){
            Navigator.push(context, CupertinoPageRoute(builder: (context) => PrescribeMedicinePage(patientId: patient["id"],)));
          },
          child: Container(
            height: 40,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                "New Prescription Add",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        /// NURSE VISITS
        _Card(
          title: "👩‍⚕️ Nurse Visits",
          child: duties.isEmpty
              ? _empty()
              : Column(
                  children: duties.map<Widget>((d) {
                    return ListTile(
                      title: Text(d["nurse"]["name"]),
                      subtitle: Text(
                        "${d["nurse"]["type"]} | ${d["duty_type"]} | ${d["shift"]}",
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    );
                  }).toList(),
                ),
        ),

        /// NOTES
        _Card(
          title: "📝 Daily Notes",
          child: notes.isEmpty
              ? _empty()
              : Column(
                  children: notes.map<Widget>((n) {
                    return ListTile(
                      title: Text(n["nurse_name"] ?? "Nurse"),
                      subtitle: Text(n["note"]),
                    );
                  }).toList(),
                ),
        ),
        
      ],
    );
  }
}

class _VitalsTab extends StatelessWidget {
  final List vitals;
  const _VitalsTab(this.vitals);

  @override
  Widget build(BuildContext context) {
    if (vitals.isEmpty) return _empty();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vitals.length,
      itemBuilder: (_, i) {
        final v = vitals[i];
        return _Card(
          title: "❤️ ${v["recorded_at"]}",
          child: Text(
            "BP: ${v["bp"]}, Pulse: ${v["pulse"]}, "
            "SpO2: ${v["spo2"]}, Temp: ${v["temperature"]}",
          ),
        );
      },
    );
  }
}

class _MedicationsTab extends StatelessWidget {
  final List meds;
  const _MedicationsTab(this.meds);

  @override
  Widget build(BuildContext context) {
    if (meds.isEmpty) return _empty();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: meds.length,
      itemBuilder: (_, i) {
        final m = meds[i];
        return _Card(
          title: "💊 ${m["medicine"]}",
          child: Text(
            "${m["dosage"]} | ${m["timing"].join(", ")}\n"
            "Duration: ${m["duration"]} days | ₹${m["price"] ?? "-"}",
          ),
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

Widget _info(String label, dynamic val) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.grey)),
      Text(val?.toString() ?? "-", style: const TextStyle(fontSize: 15)),
    ],
  ),
);

Widget _empty() => const Center(
  child: Text("No data available", style: TextStyle(color: Colors.grey)),
);
