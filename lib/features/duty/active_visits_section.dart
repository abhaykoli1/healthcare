// import 'package:flutter/material.dart';

// class ActiveVisitsSection extends StatelessWidget {
//   const ActiveVisitsSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final visits = [
//       "Patient: Mr. Sharma – Room 201",
//       "Patient: Mrs. Patel – ICU",
//     ];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Today's Visits",
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 10),
//         ...visits.map(
//           (v) => Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: ListTile(
//               leading: const Icon(Icons.local_hospital),
//               title: Text(v),
//               trailing: const Icon(Icons.chevron_right),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';

class ActiveVisitsSection extends StatelessWidget {
  const ActiveVisitsSection({super.key});

  @override
  Widget build(BuildContext context) {
    /// 🔹 Dummy visits (API later)
    final visits = [
      {"patient": "Mr. Sharma", "room": "Room 201", "type": "GENERAL"},
      {"patient": "Mrs. Patel", "room": "ICU", "type": "CRITICAL"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔖 SECTION TITLE
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "Today's Visits",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text("Active", style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),

        const SizedBox(height: 14),

        /// 🏥 VISIT CARDS
        ...visits.map(
          (v) => _VisitCard(
            patient: v["patient"]!,
            room: v["room"]!,
            type: v["type"]!,
          ),
        ),
      ],
    );
  }
}

/// 🔹 SINGLE VISIT CARD
class _VisitCard extends StatelessWidget {
  final String patient;
  final String room;
  final String type;

  const _VisitCard({
    required this.patient,
    required this.room,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final bool critical = type == "CRITICAL";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),

        /// ICON
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: critical
                ? Colors.red.withOpacity(0.1)
                : Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.local_hospital,
            color: critical ? Colors.red : Colors.blue,
          ),
        ),

        /// TITLE
        title: Text(
          patient,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        /// SUBTITLE
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(room, style: const TextStyle(color: Colors.grey)),
        ),

        /// STATUS CHIP
        trailing: _StatusChip(
          label: type,
          color: critical ? Colors.red : Colors.green,
        ),
      ),
    );
  }
}

/// 🔹 STATUS CHIP
class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
