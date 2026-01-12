import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:healthcare/core/theme/app_theme.dart';
import 'package:healthcare/routes/app_routes.dart';
import '../../core/network/api_client.dart';

class VisitPage extends StatefulWidget {
  const VisitPage({super.key});

  @override
  State<VisitPage> createState() => _VisitPageState();
}

class _VisitPageState extends State<VisitPage> {
  List visits = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadVisits();
  }

  Future<void> _loadVisits() async {
    try {
      setState(() => loading = true);
      final res = await ApiClient.get("/nurse/nurse/visits");
      visits = res ?? [];
    } catch (e) {
      log(e.toString());
    }
    setState(() => loading = false);
  }

  void _openCompleteDialog(Map visit) async {
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CompleteVisitDialog(
        visitId: visit["visit_id"],
        patientId: visit["patient_id"],
      ),
    );

    if (result == true) {
      _snack("Visit completed successfully");
      _loadVisits();
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(title: const Text("Patient Visits")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : visits.isEmpty
          ? const Center(child: Text("No visits available"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: visits.length,
              itemBuilder: (context, index) {
                final v = visits[index];
                return _VisitCard(
                  visit: v,
                  onComplete: () => _openCompleteDialog(v),
                  onSOS: () {
                    Navigator.pushNamed(context, AppRoutes.sos);
                  },
                );
              },
            ),
    );
  }
}

/// ================= VISIT CARD =================

class _VisitCard extends StatelessWidget {
  final Map visit;
  final VoidCallback onComplete;
  final VoidCallback onSOS;

  const _VisitCard({
    required this.visit,
    required this.onComplete,
    required this.onSOS,
  });

  @override
  Widget build(BuildContext context) {
    final bool completed = visit["completed"] == true;
    final List meds = visit["medications"] ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// NAME + STATUS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  visit["patient_name"] ?? "Unknown",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _StatusBadge(completed: completed),
              ],
            ),

            const SizedBox(height: 6),

            /// ADDRESS
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    visit["address"] ?? "",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// WARD / ROOM
            Text(
              "Ward: ${visit["ward"] ?? "-"} | Room: ${visit["room_no"] ?? "-"}",
              style: const TextStyle(fontSize: 13),
            ),

            const Divider(height: 24),

            /// MEDICATIONS
            if (meds.isNotEmpty) ...[
              const Text(
                "Medicines",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...meds.map((m) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m["medicine_name"],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("Dosage: ${m["dosage"]}"),
                      Text("Timing: ${(m["timing"] as List).join(", ")}"),
                      Text("Duration: ${m["duration_days"]} days"),
                    ],
                  ),
                );
              }).toList(),
            ],

            const SizedBox(height: 12),

            /// BUTTONS
            Row(
              children: [
                if (!completed)
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text("Complete"),
                      onPressed: onComplete,
                    ),
                  ),
                if (!completed) const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    icon: const Icon(Icons.warning_amber),
                    label: const Text("SOS"),
                    onPressed: onSOS,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ================= COMPLETE VISIT DIALOG =================

class _CompleteVisitDialog extends StatefulWidget {
  final String visitId;
  final String patientId;

  const _CompleteVisitDialog({required this.visitId, required this.patientId});

  @override
  State<_CompleteVisitDialog> createState() => _CompleteVisitDialogState();
}

class _CompleteVisitDialogState extends State<_CompleteVisitDialog> {
  final _formKey = GlobalKey<FormState>();

  final noteCtrl = TextEditingController();
  final bpCtrl = TextEditingController();
  final pulseCtrl = TextEditingController();
  final spo2Ctrl = TextEditingController();
  final tempCtrl = TextEditingController();
  final sugarCtrl = TextEditingController();

  bool loading = false;
  bool consentAccepted = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await ApiClient.post("/nurse/patients/${widget.patientId}/notes", {
        "note": noteCtrl.text,
      });

      await ApiClient.post("/nurse/patients/${widget.patientId}/vitals", {
        "bp": bpCtrl.text,
        "pulse": int.parse(pulseCtrl.text),
        "spo2": int.parse(spo2Ctrl.text),
        "temperature": double.parse(tempCtrl.text),
        "sugar": sugarCtrl.text.isEmpty ? null : double.parse(sugarCtrl.text),
      });

      await ApiClient.post("/nurse/visits/${widget.visitId}/complete", {});

      Navigator.pop(context, true);
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to submit")));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "Complete Visit",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _input("Daily Note", noteCtrl, max: 3),
                _input("BP (120/80)", bpCtrl),
                _input("Pulse", pulseCtrl, number: true),
                _input("SpO2", spo2Ctrl, number: true),
                _input("Temperature", tempCtrl, number: true),
                _input(
                  "Sugar (optional)",
                  sugarCtrl,
                  number: true,
                  required: false,
                ),

                const SizedBox(height: 10),

                /// CONSENT
                Row(
                  children: [
                    Checkbox(
                      value: consentAccepted,
                      onChanged: (v) {
                        setState(() => consentAccepted = v ?? false);
                      },
                    ),
                    const Expanded(
                      child: Text(
                        "I confirm that I have visited the patient and entered correct information",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading || !consentAccepted ? null : _submit,
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Submit & Complete"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(
    String label,
    TextEditingController ctrl, {
    bool number = false,
    bool required = true,
    int max = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        maxLines: max,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        validator: required
            ? (v) => v == null || v.isEmpty ? "Required" : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
