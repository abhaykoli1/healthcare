import 'package:flutter/material.dart';
import 'package:healthcare/core/theme/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  // final String ward;
  final String nurseType;
  final String status;
  final String profile;
  final String workedTime;

  const ProfileHeader({
    super.key,
    required this.name,
    // required this.ward,
    required this.nurseType,
    required this.status,
    required this.profile,
    required this.workedTime,
  });

  @override
  Widget build(BuildContext context) {
    print("profile: $profile");
    final active = status == "ACTIVE";
    final String? p = profile;
    final hasProfile = profile.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.blue.withOpacity(0.25),
        //     blurRadius: 24,
        //     offset: const Offset(0, 12),
        //   ),
        // ],
      ),
      child: Row(
        children: [
          /// Avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            // child: const CircleAvatar(
            //   radius: 34,
            //   backgroundColor: Colors.white,
            //   child: Icon(Icons.person, size: 36, color: AppTheme.primary),
            // ),
            // child: CircleAvatar(
            //   radius: 38,
            //   backgroundColor: Colors.white,
            //   backgroundImage: profile != null && profile.isNotEmpty
            //       ? NetworkImage(profile)
            //       : null,
            //   child: profile == null || profile.isEmpty
            //       ? Icon(Icons.person, size: 38, color: AppTheme.primary)
            //       : null,
            // ),
            child: CircleAvatar(
              radius: 38,
              backgroundColor: Colors.white,
              backgroundImage: hasProfile ? NetworkImage(profile) : null,
              child: hasProfile
                  ? null
                  : const Icon(Icons.person, size: 38, color: AppTheme.primary),
            ),
          ),

          const SizedBox(width: 16),

          /// Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 0),

                Text(
                  "Nurse Type • $nurseType",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    _Pill(
                      label: status,
                      color: active
                          ? Colors.indigoAccent
                          : Colors.white.withOpacity(1),
                    ),
                    const SizedBox(width: 8),
                    _Pill(
                      label: workedTime,
                      color: Colors.white,
                      darkText: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  final bool darkText;

  const _Pill({
    required this.label,
    required this.color,
    this.darkText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: darkText ? Colors.white : color.withOpacity(0.25),
        borderRadius: BorderRadius.circular(30),
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
