import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';
import 'punch_provider.dart';
import '../../routes/app_routes.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffId = ref.watch(authProvider)!;

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _DashboardCard(
              icon: Icons.login,
              title: "Punch In",
              color: Colors.green,
              onTap: () => ref.read(punchProvider).inDuty(staffId),
            ),
            _DashboardCard(
              icon: Icons.logout,
              title: "Punch Out",
              color: Colors.orange,
              onTap: () => ref.read(punchProvider).outDuty(staffId),
            ),
            _DashboardCard(
              icon: Icons.person,
              title: "My Profile",
              color: Colors.blue,
              onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
            ),
            _DashboardCard(
              icon: Icons.assignment,
              title: "Visits",
              color: Colors.purple,
              onTap: () => Navigator.pushNamed(context, AppRoutes.visits),
            ),
            _DashboardCard(
              icon: Icons.warning_amber_rounded,
              title: "SOS",
              color: Colors.red,
              onTap: () => Navigator.pushNamed(context, AppRoutes.sos),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
