import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:healthcare/core/network/api_client.dart';
import 'package:healthcare/core/theme/app_theme.dart';
import 'package:healthcare/core/utils/app_message.dart';
import 'package:healthcare/features/duty/lang/mainLangChang.dart';
import 'package:image_picker/image_picker.dart';

// ✅ ADD THIS

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

  // ================= SIGNATURE PICK =================
  Future<void> pickSignature(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);

    if (picked != null) {
      setState(() {
        signatureFile = File(picked.path);
      });
    }
  }

  void changeLanguage(AppLanguage lang) {
    setState(() {
      Lang.current = lang;
    });
  }

  // ================= SUBMIT =================
  Future<void> submitConsent() async {
    if (signatureFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(Lang.t("please_upload"))));
      return;
    }

    setState(() => loading = true);

    try {
      final nurseId = widget.statusData["nurse_id"];

      final uploadRes = await ApiClient.uploadFile(
        "/upload/file",
        signatureFile!,
        folder: "signatures",
      );

      final signaturePath = uploadRes["path"];

      await ApiClient.put("/nurse/signature/$nurseId", {
        "signature_path": signaturePath,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Lang.t("success")),
          backgroundColor: Colors.green,
        ),
      );

      AppMessage.snack = Lang.t("signup_done");

      Navigator.pushReplacementNamed(context, "/login");
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed: $e")));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // ================= BOTTOM SHEET =================
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
              Text(
                Lang.t("upload_title"),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(Lang.t("camera")),
                onTap: () {
                  Navigator.pop(context);
                  pickSignature(ImageSource.camera);
                },
              ),

              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(Lang.t("gallery")),
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

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    log(widget.statusData.toString());

    return Scaffold(
      appBar: AppBar(
        title: Text(Lang.t("title")),
        automaticallyImplyLeading: true,

        actions: [
          PopupMenuButton<AppLanguage>(
            icon: const Icon(Icons.language),
            onSelected: changeLanguage,
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: AppLanguage.english,
                child: Text("English"),
              ),
              const PopupMenuItem(
                value: AppLanguage.hindi,
                child: Text("हिंदी"),
              ),
              const PopupMenuItem(
                value: AppLanguage.gujarati,
                child: Text("ગુજરાતી"),
              ),
              const PopupMenuItem(
                value: AppLanguage.marathi,
                child: Text("मराठी"),
              ),
              const PopupMenuItem(
                value: AppLanguage.kannada,
                child: Text("ಕನ್ನಡ"),
              ),
            ],
          ),
        ],
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
                  children: [
                    Text(Lang.t("point1")),
                    const SizedBox(height: 6),
                    Text(Lang.t("point2")),
                    const SizedBox(height: 6),
                    Text(Lang.t("point3")),
                    const SizedBox(height: 6),
                    Text(Lang.t("point4")),
                    const SizedBox(height: 6),
                    Text(Lang.t("point5")),
                    const SizedBox(height: 6),
                    Text(Lang.t("point6")),
                    const SizedBox(height: 6),
                    Text(Lang.t("point7")),
                    const SizedBox(height: 6),
                    Text(Lang.t("point8")),
                    const SizedBox(height: 6),
                    Text(Lang.t("point9")),
                    const SizedBox(height: 6),
                    Text(Lang.t("point10")),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= CONFIDENTIAL =================
            Card(
              color: Colors.grey.shade50,
              elevation: .5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(Lang.t("confidential")),
              ),
            ),

            const SizedBox(height: 24),

            // ================= SIGNATURE =================
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
                    Text(
                      Lang.t("upload_signature"),
                      style: const TextStyle(
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
                            : Center(
                                child: Text(
                                  Lang.t("tap_upload"),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: loading ? null : submitConsent,
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Padding(
                              padding: const EdgeInsets.only(
                                left: 10.0,
                                right: 10.0,
                              ),
                              child: Text(Lang.t("submit")),
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
