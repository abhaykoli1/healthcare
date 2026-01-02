import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../routes/app_routes.dart';
import '../auth/auth_provider.dart';

import 'profile_header_section.dart';
import 'active_visits_section.dart';
import 'weekly_work_graph.dart';
import 'action_cards_section.dart';

// class DashboardPage extends ConsumerWidget {
//   const DashboardPage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final auth = ref.watch(authProvider);
//     final staffId = auth.staffId;

//     /// 🔒 Redirect if not logged in
//     if (staffId == null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Navigator.pushReplacementNamed(context, AppRoutes.login);
//       });

//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return Scaffold(
//       appBar: AppBar(title: const Text("Dashboard"), centerTitle: true),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// 👤 PROFILE HEADER
//             const ProfileHeader(name: "Riya Sharma", ward: "Ward A"),

//             const SizedBox(height: 20),

//             /// 📍 ACTIVE VISITS
//             const ActiveVisitsSection(),

//             const SizedBox(height: 24),

//             /// 📊 WEEKLY WORK GRAPH
//             const WeeklyWorkGraph(),

//             const SizedBox(height: 24),

//             /// 🧩 ACTION CARDS
//             ActionCardsSection(staffId: staffId),
//           ],
//         ),
//       ),
//     );
//   }
// }

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final staffId = auth.staffId;

    if (staffId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      });

      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text("Dashboard"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 👤 PROFILE HEADER (PRIMARY CARD)
            const ProfileHeader(name: "Riya Sharma", ward: "Ward A"),

            const SizedBox(height: 28),

            /// 📍 ACTIVE VISITS
            _SectionWrapper(
              title: "Today's Visits",
              child: const ActiveVisitsSection(),
            ),

            const SizedBox(height: 28),

            /// 📊 WEEKLY WORK GRAPH
            _SectionWrapper(
              title: "Weekly Work Hours",
              child: const WeeklyWorkGraph(),
            ),

            const SizedBox(height: 28),

            /// 🧩 ACTION CARDS
            _SectionWrapper(
              title: "Quick Actions",
              child: ActionCardsSection(staffId: staffId),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionWrapper extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionWrapper({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Section title
        // Padding(
        //   padding: const EdgeInsets.only(bottom: 12),
        //   child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        // ),

        /// Floating container
        Card(
          child: Padding(padding: const EdgeInsets.all(10), child: child),
        ),
      ],
    );
  }
}
