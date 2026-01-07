import 'package:flutter/material.dart';

class ActiveVisitsSection extends StatelessWidget {
  final List visits;

  const ActiveVisitsSection({super.key, required this.visits});

  @override
  Widget build(BuildContext context) {
    if (visits.isEmpty) {
      return const Text("No visits today");
    }

    return Column(
      children: visits.map((v) {
        final critical = v["visit_type"] == "EMERGENCY";

        return ListTile(
          leading: Icon(
            Icons.local_hospital,
            color: critical ? Colors.red : Colors.blue,
          ),
          title: Text(v["patient_name"]),
          subtitle: Text("${v["ward"]} • ${v["room_no"]}"),
          trailing: Chip(
            label: Text(v["visit_type"]),
          ),
        );
      }).toList(),
    );
  }
}
