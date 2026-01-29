// import 'package:flutter/material.dart';
// import 'package:healthcare/core/theme/app_theme.dart';

// class AboutUsPage extends StatelessWidget {
//   const AboutUsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.primarylight,
//       appBar: AppBar(title: const Text("About Us"), centerTitle: true),

//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             /// 🔵 Profile Image
//             Center(
//               child: CircleAvatar(
//                 radius: 70,
//                 backgroundColor: Colors.grey.shade200,
//                 backgroundImage: const AssetImage(
//                   "assets/media/profile.png", // 👉 your image path
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),

//             /// 🔵 Name
//             const Text(
//               "M. Shoaib Naqvi",
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 6),

//             /// 🔵 Designation
//             Text(
//               "Founder & Director – We Care Home Healthcare Services",
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//             ),

//             const SizedBox(height: 30),

//             /// 🔵 Description Card
//             Container(
//               child: Padding(
//                 padding: EdgeInsets.all(0),
//                 child: Text(
//                   """M. Shoaib Naqvi is the Founder and Director of We Care Home Healthcare Services, a professionally driven organization dedicated to delivering high-quality home healthcare and elder care solutions. With over 10 years of extensive hands-on experience in advanced nursing and patient-care leadership, he brings deep clinical insight combined with compassionate service excellence.

// His expertise encompasses a wide spectrum of critical and specialized care areas, including Operation Theatre (OT) procedures, Emergency Care, ICU & Critical Care, Neuro Care, Geriatric & Elder Care, and Oncology (Cancer Care). He is particularly recognized for his strong command over elder care management, ensuring dignified daily support for senior citizens in the comfort of their homes.

// Guided by a patient-first and family-centered philosophy, he integrates medical precision with empathy, ensuring personalized care plans tailored to each individual’s physical, emotional, and social needs.

// During the COVID-19 pandemic, he demonstrated impactful leadership by initiating community healthcare outreach programs to support elderly and vulnerable populations.

// Under his visionary leadership, We Care Home Healthcare Services has grown into a trusted and respected name in the home healthcare sector, known for quality, safety, professionalism, and compassionate care.

// His mission is simple — hospital-level care at home with trust, dignity, and excellence.""",
//                   style: TextStyle(
//                     fontSize: 15,
//                     height: 1.6,
//                     color: Colors.grey.shade800,
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 30),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:healthcare/core/network/api_client.dart';
import '../../core/theme/app_theme.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  Map<String, dynamic>? about;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /* =====================================================
      🔹 LOAD ABOUT DATA
  ===================================================== */
  Future<void> _load() async {
    try {
      final res = await ApiClient.getWithoutTokern("/nurse/about-us-get");

      setState(() {
        about = res;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  /* =====================================================
      🔹 UI
  ===================================================== */
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final name = about?["name"] ?? "";
    final designation = about?["designation"] ?? "";
    final description = about?["description"] ?? "";
    final image = about?["profile_image"] ?? "";

    return Scaffold(
      backgroundColor: AppTheme.primarylight,
      appBar: AppBar(title: const Text("About Us"), centerTitle: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// 🔵 Profile Image (same as old)
            Center(
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
                child: image.isEmpty
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            /// 🔵 Name (same styling as old)
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            /// 🔵 Designation
            Text(
              designation,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 30),

            /// 🔵 Description Card (same like OLD)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                // color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(0),
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.grey.shade800,
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
