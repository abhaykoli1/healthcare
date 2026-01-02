import 'dart:async';
import 'package:flutter/material.dart';
import 'package:healthcare/routes/app_routes.dart';

class ProfileHeader extends StatefulWidget {
  final String name;
  final String ward;
  const ProfileHeader({super.key, required this.name, required this.ward});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  late DateTime startTime;
  late Timer timer;
  Duration worked = Duration.zero;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now().subtract(const Duration(hours: 2, minutes: 15));
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        worked = DateTime.now().difference(startTime);
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff4A6CF7), Color(0xff6A8DFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            /// 👤 AVATAR
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const CircleAvatar(
                radius: 36,
                backgroundImage: AssetImage("assets/profile.png"),
                backgroundColor: Colors.white,
              ),
            ),

            const SizedBox(width: 16),

            /// 🧾 INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// NAME
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// WARD
                  Text(
                    "Ward • ${widget.ward}",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),

                  const SizedBox(height: 12),

                  /// STATUS ROW
                  Row(
                    children: [
                      _StatusPill(label: "ACTIVE", color: Colors.greenAccent),
                      const SizedBox(width: 8),
                      _StatusPill(
                        label: "${worked.inHours}h ${(worked.inMinutes % 60)}m",
                        color: Colors.white,
                        darkText: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// ➡️ ARROW
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white70,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔹 STATUS CHIP
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
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: darkText ? Colors.black : color,
        ),
      ),
    );
  }
}
