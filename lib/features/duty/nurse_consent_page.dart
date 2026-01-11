import 'package:flutter/material.dart';
import 'consent_service.dart';

class NurseConsentPage extends StatefulWidget {
  const NurseConsentPage({super.key});

  @override
  State<NurseConsentPage> createState() => _NurseConsentPageState();
}

class _NurseConsentPageState extends State<NurseConsentPage> {
  bool confidentiality = false;
  bool noDirectPayment = false;
  bool policeTermination = false;
  bool accepted = false;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F6FA),

      /// 🔹 AppBar
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Nurse Consent Form",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff4FACFE), Color(0xff00F2FE)],
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const _HeaderNote(),

                    _SectionCard(
                      icon: Icons.business,
                      title: "Company Details",
                      child: const Text(
                        "We Care Home Healthcare Services\n\n"
                        "This consent form is mandatory to continue duty.",
                        style: TextStyle(color: Colors.black87, height: 1.5),
                      ),
                    ),

                    _SectionCard(
                      icon: Icons.schedule,
                      title: "Duty Details",
                      child: Column(
                        children: const [
                          _InfoRow("Shift Type", "As allotted"),
                          _InfoRow("Duty Hours", "As per company policy"),
                          _InfoRow("Duty Location", "Assigned by company"),
                        ],
                      ),
                    ),

                    _SectionCard(
                      icon: Icons.payments,
                      title: "Salary & Payment",
                      child: Column(
                        children: const [
                          _InfoRow("Salary Type", "Daily / Monthly"),
                          _InfoRow("Payment Mode", "Cash / Bank / UPI"),
                          _InfoRow("Salary Date", "Company policy"),
                        ],
                      ),
                    ),

                    _SectionCard(
                      icon: Icons.gavel,
                      title: "Legal Declarations",
                      child: Column(
                        children: [
                          _CheckItem(
                            value: confidentiality,
                            onChanged: (v) =>
                                setState(() => confidentiality = v),
                            text:
                                "I will not misuse or leak patient or company data.",
                          ),
                          _CheckItem(
                            value: noDirectPayment,
                            onChanged: (v) =>
                                setState(() => noDirectPayment = v),
                            text:
                                "I will not accept any direct payment from patients.",
                          ),
                          _CheckItem(
                            value: policeTermination,
                            onChanged: (v) =>
                                setState(() => policeTermination = v),
                            text:
                                "I accept termination if police verification fails.",
                          ),
                        ],
                      ),
                    ),

                    _SectionCard(
                      icon: Icons.verified_user,
                      title: "Final Confirmation",
                      child: CheckboxListTile(
                        value: accepted,
                        onChanged: (v) => setState(() => accepted = v ?? false),
                        title: const Text(
                          "I have read and agree to all terms & conditions.",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),

            /// 🔘 Sticky Submit Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15)],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canSubmit() ? Colors.blue : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    if (_canSubmit() && loading == false) {
                      _submit();
                    }
                  },
                  child: loading == true
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Agree & Submit",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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

  /// ✅ Validation
  bool _canSubmit() {
    return confidentiality && noDirectPayment && policeTermination && accepted;
  }

  /// ✅ Submit Logic
  Future<void> _submit() async {
    if (!_canSubmit()) {
      _snack("Please accept all declarations before submitting", error: true);
      return;
    }

    try {
      setState(() {
        loading = true;
      });

      await ConsentService.signConsent(
        confidentiality: confidentiality,
        noDirectPayment: noDirectPayment,
        policeTermination: policeTermination,
      );

      _snack("Consent submitted successfully ✅");
      Navigator.pop(context, true);
      setState(() {
        loading = false;
      });
    } catch (e) {
      _snack("Submission failed. Please try again", error: true);
    } finally {
      setState(() => loading = false);
    }
  }

  /// ✅ Snackbar / Toast
  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// ================= UI COMPONENTS =================

class _HeaderNote extends StatelessWidget {
  const _HeaderNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xffE3F2FD), Color(0xffF1F8FF)],
        ),
      ),
      child: Row(
        children: const [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Please read all details carefully before submitting.",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData icon;

  const _SectionCard({
    required this.title,
    required this.child,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String text;

  const _CheckItem({
    required this.value,
    required this.onChanged,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: (v) => onChanged(v ?? false),
      title: Text(text),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
