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
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        title: const Text("Consent Form"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _SectionCard(
                      title: "Company Details",
                      child: const Text(
                        "We Care Home Healthcare Services\n\n"
                        "This consent form is mandatory to continue duty.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),

                    _SectionCard(
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
                      title: "Legal Declarations",
                      child: Column(
                        children: [
                          _CheckItem(
                            value: confidentiality,
                            onChanged: (v) =>
                                setState(() => confidentiality = v),
                            text:
                                "I will not misuse or leak patient/company data.",
                          ),
                          _CheckItem(
                            value: noDirectPayment,
                            onChanged: (v) =>
                                setState(() => noDirectPayment = v),
                            text:
                                "I will not accept direct payment from patient.",
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
                      title: "Final Confirmation",
                      child: CheckboxListTile(
                        value: accepted,
                        onChanged: (v) => setState(() => accepted = v ?? false),
                        title: const Text(
                          "I have read, understood and accept all terms & conditions.",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            /// 🔘 SUBMIT BUTTON
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 10),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _canSubmit() && !loading ? _submit : null,
                  child: loading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "I Agree & Submit",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canSubmit() {
    return confidentiality &&
        noDirectPayment &&
        policeTermination &&
        accepted;
  }

  Future<void> _submit() async {
    try {
      setState(() => loading = true);

      await ConsentService.signConsent(
        confidentiality: confidentiality,
        noDirectPayment: noDirectPayment,
        policeTermination: policeTermination,
      );

      _snack("Consent signed successfully");

      /// 🔥 Redirect to dashboard
      Navigator.pop(context, true);

    } catch (e) {
      _snack(e.toString(), error: true);
    } finally {
      setState(() => loading = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }
}



class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                )),
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
              child: Text(label,
                  style: const TextStyle(color: Colors.grey))),
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
    );
  }
}
