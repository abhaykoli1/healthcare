import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StaffProfilePage extends StatelessWidget {
  const StaffProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = {
      "full_name": "Riya Sharma",
      "phone": "9876543210",
      "staff_type": "GNM Nurse",
      "aadhaar_verified": true,
      "verification_status": "VERIFIED",
      "is_active": true,
      "created_at": DateTime.now()
          .subtract(const Duration(days: 120))
          .toIso8601String(),
      "qualification_docs": ["GNM Certificate", "Nursing License"],
      "experience_docs": ["2 Years Experience Letter"],
      "signature": null,
    };

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      body: CustomScrollView(
        slivers: [
          _ProfileHeader(data),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SectionTitle("Basic Details"),
                _InfoTile(
                  Icons.person,
                  "Full Name",
                  data["full_name"].toString(),
                ),
                _InfoTile(Icons.phone, "Phone", data["phone"].toString()),
                _InfoTile(
                  Icons.medical_services,
                  "Role",
                  data["staff_type"].toString(),
                ),

                _SectionTitle("Verification"),
                _StatusRow(
                  "Aadhaar Verified",
                  data["aadhaar_verified"] as bool,
                ),
                _StatusRow("Account Active", data["is_active"] as bool),
                _InfoTile(
                  Icons.verified,
                  "Verification Status",
                  data["verification_status"].toString(),
                ),

                _SectionTitle("Joined"),
                _InfoTile(
                  Icons.calendar_today,
                  "Joined On",
                  DateFormat(
                    "dd MMM yyyy",
                  ).format(DateTime.parse(data["created_at"].toString())),
                ),

                _SectionTitle("Documents"),
                _DocList(
                  "Qualification Documents",
                  List<String>.from(data["qualification_docs"] as List<String>),
                ),
                _DocList(
                  "Experience Documents",
                  List<String>.from(data["experience_docs"] as List<String>),
                ),

                _SectionTitle("Signature"),
                _SignatureBox(
                  data["signature"].toString() == "null"
                      ? null
                      : data["signature"].toString(),
                ),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final Map data;
  const _ProfileHeader(this.data);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff4A6CF7), Color(0xff6A8DFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FlexibleSpaceBar(
          titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
          title: Text(data["full_name"], style: const TextStyle(fontSize: 16)),
          background: Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 48),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Badge("VERIFIED", Colors.green),
                    const SizedBox(width: 8),
                    _Badge("ACTIVE", Colors.blue),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final bool value;

  const _StatusRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        title: Text(label),
        trailing: Chip(
          label: Text(value ? "YES" : "NO"),
          backgroundColor: value ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}

class _DocList extends StatelessWidget {
  final String title;
  final List docs;

  const _DocList(this.title, this.docs);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const Divider(),
            ...docs.map(
              (d) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: const [
                    Icon(Icons.picture_as_pdf, size: 18),
                    SizedBox(width: 8),
                    Expanded(child: Text("Document")),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignatureBox extends StatelessWidget {
  final String? signature;
  const _SignatureBox(this.signature);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        height: 100,
        alignment: Alignment.center,
        child: signature == null
            ? const Text("No signature uploaded")
            : Image.network(signature!),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
