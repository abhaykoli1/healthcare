import 'package:flutter/material.dart';
import 'package:healthcare/core/theme/app_theme.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primarylight,
      appBar: AppBar(title: const Text("About Us"), centerTitle: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// 🔵 Profile Image
            Center(
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: const AssetImage(
                  "assets/media/profile.png", // 👉 your image path
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 🔵 Name
            const Text(
              "M. Shoaib Naqvi",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            /// 🔵 Designation
            Text(
              "Founder & Director – We Care Home Healthcare Services",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 30),

            /// 🔵 Description Card
            Container(
              child: Padding(
                padding: EdgeInsets.all(0),
                child: Text(
                  """M. Shoaib Naqvi is the Founder and Director of We Care Home Healthcare Services, a professionally driven organization dedicated to delivering high-quality home healthcare and elder care solutions. With over 10 years of extensive hands-on experience in advanced nursing and patient-care leadership, he brings deep clinical insight combined with compassionate service excellence.

His expertise encompasses a wide spectrum of critical and specialized care areas, including Operation Theatre (OT) procedures, Emergency Care, ICU & Critical Care, Neuro Care, Geriatric & Elder Care, and Oncology (Cancer Care). He is particularly recognized for his strong command over elder care management, ensuring dignified daily support for senior citizens in the comfort of their homes.

Guided by a patient-first and family-centered philosophy, he integrates medical precision with empathy, ensuring personalized care plans tailored to each individual’s physical, emotional, and social needs.

During the COVID-19 pandemic, he demonstrated impactful leadership by initiating community healthcare outreach programs to support elderly and vulnerable populations.

Under his visionary leadership, We Care Home Healthcare Services has grown into a trusted and respected name in the home healthcare sector, known for quality, safety, professionalism, and compassionate care.

His mission is simple — hospital-level care at home with trust, dignity, and excellence.""",
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.grey.shade800,
                  ),
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
