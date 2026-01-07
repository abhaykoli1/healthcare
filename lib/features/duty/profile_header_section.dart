import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String ward;
  final String status;
  final String workedTime;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.ward,
    required this.status,
    required this.workedTime,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = status == "ACTIVE";

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff4A6CF7), Color(0xff6A8DFF)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 36, backgroundColor: Colors.white),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),

                const SizedBox(height: 4),

                Text("Ward • $ward",
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 13)),

                const SizedBox(height: 12),

                Row(
                  children: [
                    _StatusPill(
                      label: status,
                      color: active ? Colors.greenAccent : Colors.redAccent,
                    ),
                    const SizedBox(width: 8),
                    _StatusPill(
                      label: workedTime,
                      color: Colors.white,
                      darkText: true,
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final bool darkText;

  const _StatusPill({
    required this.label,
    required this.color,
    this.darkText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: darkText ? Colors.white : color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: darkText ? Colors.black : color,
          )),
    );
  }
}
