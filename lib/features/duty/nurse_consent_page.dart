import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:healthcare/core/network/api_client.dart';
import 'package:healthcare/core/theme/app_theme.dart';
import 'package:healthcare/core/utils/app_message.dart';
import 'package:image_picker/image_picker.dart';

class NurseConsentPage extends StatefulWidget {
  final Map<String, dynamic> statusData;

  const NurseConsentPage({super.key, required this.statusData});

  @override
  State<NurseConsentPage> createState() => _NurseConsentPageState();
}

class _NurseConsentPageState extends State<NurseConsentPage> {
  File? signatureFile;
  bool loading = false;

  final ImagePicker _picker = ImagePicker();

  bool get canSignConsent =>
      widget.statusData["police_verified"] == "CLEAR" &&
      widget.statusData["aadhaar_verified"] == true;

  // 👇👇 YAHAN LAGANA HAI
  Future<void> pickSignature(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);

    if (picked != null) {
      setState(() {
        signatureFile = File(picked.path);
      });
    }
  }

  Future<void> submitConsent() async {
    if (signatureFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please upload signature")));
      return;
    }

    setState(() => loading = true);

    try {
      final nurseId = widget.statusData["nurse_id"];

      /* =========================
       1️⃣ Upload file
    ========================= */
      final uploadRes = await ApiClient.uploadFile(
        "/upload/file",
        signatureFile!,
        folder: "signatures",
      );

      final signaturePath = uploadRes["path"]; // ✅ path from backend

      /* =========================
       2️⃣ SAVE SIGNATURE PATH ONLY
       (this matches your FastAPI)
    ========================= */
      await ApiClient.put("/nurse/signature/$nurseId", {
        "signature_path": signaturePath, // 🔥 EXACT MATCH
      });

      /* =========================
       3️⃣ Success
    ========================= */
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Signature uploaded successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      AppMessage.snack =
          "Signup complete ✅\nWait for admin approval.\nYou will get an email after verification.";

      Navigator.pushReplacementNamed(context, "/login");
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed: $e")));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void showSignatureSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Upload Signature",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  pickSignature(ImageSource.camera);
                },
              ),

              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  pickSignature(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    log(widget.statusData.toString());
    return Scaffold(
      appBar: AppBar(
        title: const Text("👩‍⚕️ Staff Legal Declaration & Undertaking"),
        automaticallyImplyLeading: true,
      ),
      backgroundColor: AppTheme.primarylight,

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ================= LEGAL DECLARATION =================
            Card(
              color: Colors.grey.shade50,
              elevation: .5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "1️⃣ Main declare karta/karti hoon ki mere sabhi documents genuine hain...",
                      style: TextStyle(fontSize: 14.5, height: 1.5),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "2️⃣ Main company ke sabhi rules – duty timing, transfer...",
                      style: TextStyle(fontSize: 14.5, height: 1.5),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "3️⃣ Patient ki medical information, photos, videos...",
                      style: TextStyle(fontSize: 14.5, height: 1.5),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "4️⃣ Bina company ki written permission ke kisi patient se direct payment...",
                      style: TextStyle(fontSize: 14.5, height: 1.5),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "5️⃣ Bina notice duty chhodna company ke financial loss ka karan...",
                      style: TextStyle(fontSize: 14.5, height: 1.5),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "6️⃣ Patient ke ghar par bidi, cigarette, gutka, alcohol ya drugs...",
                      style: TextStyle(fontSize: 14.5, height: 1.5),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "7️⃣ Patient / relatives ke saath misbehaviour, dhamki ya abuse...",
                      style: TextStyle(fontSize: 14.5, height: 1.5),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "8️⃣ Chori, cheating, fraud, ya company/patient ka nuksaan...",
                      style: TextStyle(fontSize: 14.5, height: 1.5),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "9️⃣ Company ke khilaf patient ko bhadkana, ya confidential info misuse...",
                      style: TextStyle(fontSize: 14.5, height: 1.5),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "🔟 Police verification fail hone par meri service bina notice terminate ki ja sakti hai.",
                      style: TextStyle(fontSize: 14.5, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= CONFIDENTIALITY =================
            Card(
              color: Colors.grey.shade50,
              elevation: .5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: const Text(
                  "🔒 CONFIDENTIALITY & DISCIPLINE\n\n"
                  "Main patient & company data ko misuse nahi karunga/karungi. "
                  "Violation par IT Act 2000 ke tahat action liya ja sakta hai.",
                  style: TextStyle(fontSize: 14.5, height: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ================= SIGNATURE UPLOAD =================
            Card(
              color: Colors.grey.shade50,
              elevation: .5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      "Upload your signature",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: showSignatureSourceSheet,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: signatureFile != null
                            ? Image.file(signatureFile!, fit: BoxFit.contain)
                            : const Center(
                                child: Text(
                                  "Tap to upload signature",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: loading ? null : submitConsent,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Submit & Sign",
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'consent_service.dart';

// class NurseConsentPage extends StatefulWidget {
//   const NurseConsentPage({super.key});

//   @override
//   State<NurseConsentPage> createState() => _NurseConsentPageState();
// }

// class _NurseConsentPageState extends State<NurseConsentPage> {
//   bool confidentiality = false;
//   bool noDirectPayment = false;
//   bool policeTermination = false;
//   bool accepted = false;
//   bool loading = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xffF4F6FA),

//       /// 🔹 AppBar
//       appBar: AppBar(
//         centerTitle: true,
//         elevation: 0,
//         title: const Text(
//           "Nurse Consent Form",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xff4FACFE), Color(0xff00F2FE)],
//             ),
//           ),
//         ),
//       ),

//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     const _HeaderNote(),

//                     _SectionCard(
//                       icon: Icons.business,
//                       title: "Company Details",
//                       child: const Text(
//                         "We Care Home Healthcare Services\n\n"
//                         "This consent form is mandatory to continue duty.",
//                         style: TextStyle(color: Colors.black87, height: 1.5),
//                       ),
//                     ),

//                     _SectionCard(
//                       icon: Icons.schedule,
//                       title: "Duty Details",
//                       child: Column(
//                         children: const [
//                           _InfoRow("Shift Type", "As allotted"),
//                           _InfoRow("Duty Hours", "As per company policy"),
//                           _InfoRow("Duty Location", "Assigned by company"),
//                         ],
//                       ),
//                     ),

//                     _SectionCard(
//                       icon: Icons.payments,
//                       title: "Salary & Payment",
//                       child: Column(
//                         children: const [
//                           _InfoRow("Salary Type", "Daily / Monthly"),
//                           _InfoRow("Payment Mode", "Cash / Bank / UPI"),
//                           _InfoRow("Salary Date", "Company policy"),
//                         ],
//                       ),
//                     ),

//                     _SectionCard(
//                       icon: Icons.gavel,
//                       title: "Legal Declarations",
//                       child: Column(
//                         children: [
//                           _CheckItem(
//                             value: confidentiality,
//                             onChanged: (v) =>
//                                 setState(() => confidentiality = v),
//                             text:
//                                 "I will not misuse or leak patient or company data.",
//                           ),
//                           _CheckItem(
//                             value: noDirectPayment,
//                             onChanged: (v) =>
//                                 setState(() => noDirectPayment = v),
//                             text:
//                                 "I will not accept any direct payment from patients.",
//                           ),
//                           _CheckItem(
//                             value: policeTermination,
//                             onChanged: (v) =>
//                                 setState(() => policeTermination = v),
//                             text:
//                                 "I accept termination if police verification fails.",
//                           ),
//                         ],
//                       ),
//                     ),

//                     _SectionCard(
//                       icon: Icons.verified_user,
//                       title: "Final Confirmation",
//                       child: CheckboxListTile(
//                         value: accepted,
//                         onChanged: (v) => setState(() => accepted = v ?? false),
//                         title: const Text(
//                           "I have read and agree to all terms & conditions.",
//                           style: TextStyle(fontWeight: FontWeight.w600),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 90),
//                   ],
//                 ),
//               ),
//             ),

//             /// 🔘 Sticky Submit Button
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15)],
//               ),
//               child: SizedBox(
//                 width: double.infinity,
//                 height: 52,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: _canSubmit() ? Colors.blue : Colors.grey,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                   ),
//                   onPressed: () {
//                     if (_canSubmit() && loading == false) {
//                       _submit();
//                     }
//                   },
//                   child: loading == true
//                       ? SizedBox(
//                           height: 22,
//                           width: 22,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: Colors.white,
//                           ),
//                         )
//                       : const Text(
//                           "Agree & Submit",
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// ✅ Validation
//   bool _canSubmit() {
//     return confidentiality && noDirectPayment && policeTermination && accepted;
//   }

//   /// ✅ Submit Logic
//   Future<void> _submit() async {
//     if (!_canSubmit()) {
//       _snack("Please accept all declarations before submitting", error: true);
//       return;
//     }

//     try {
//       setState(() {
//         loading = true;
//       });

//       await ConsentService.signConsent(
//         confidentiality: confidentiality,
//         noDirectPayment: noDirectPayment,
//         policeTermination: policeTermination,
//       );

//       _snack("Consent submitted successfully ✅");
//       Navigator.pop(context, true);
//       setState(() {
//         loading = false;
//       });
//     } catch (e) {
//       _snack("Submission failed. Please try again", error: true);
//     } finally {
//       setState(() => loading = false);
//     }
//   }

//   /// ✅ Snackbar / Toast
//   void _snack(String msg, {bool error = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg),
//         backgroundColor: error ? Colors.red : Colors.green,
//         duration: const Duration(seconds: 2),
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }
// }

// /// ================= UI COMPONENTS =================

// class _HeaderNote extends StatelessWidget {
//   const _HeaderNote();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         gradient: const LinearGradient(
//           colors: [Color(0xffE3F2FD), Color(0xffF1F8FF)],
//         ),
//       ),
//       child: Row(
//         children: const [
//           Icon(Icons.info_outline, color: Colors.blue),
//           SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               "Please read all details carefully before submitting.",
//               style: TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SectionCard extends StatelessWidget {
//   final String title;
//   final Widget child;
//   final IconData icon;

//   const _SectionCard({
//     required this.title,
//     required this.child,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       margin: const EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, color: Colors.blue),
//                 const SizedBox(width: 8),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             child,
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _InfoRow extends StatelessWidget {
//   final String label;
//   final String value;

//   const _InfoRow(this.label, this.value);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         children: [
//           Expanded(
//             child: Text(label, style: const TextStyle(color: Colors.grey)),
//           ),
//           Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
//         ],
//       ),
//     );
//   }
// }

// class _CheckItem extends StatelessWidget {
//   final bool value;
//   final ValueChanged<bool> onChanged;
//   final String text;

//   const _CheckItem({
//     required this.value,
//     required this.onChanged,
//     required this.text,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return CheckboxListTile(
//       contentPadding: EdgeInsets.zero,
//       value: value,
//       onChanged: (v) => onChanged(v ?? false),
//       title: Text(text),
//       controlAffinity: ListTileControlAffinity.leading,
//     );
//   }
// }
