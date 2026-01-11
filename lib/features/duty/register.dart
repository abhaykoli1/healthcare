import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:healthcare/core/network/api_client.dart';

class NurseSelfSignupPage extends StatefulWidget {
  const NurseSelfSignupPage({super.key});

  @override
  State<NurseSelfSignupPage> createState() => _NurseSelfSignupPageState();
}

class _NurseSelfSignupPageState extends State<NurseSelfSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();

  final phoneCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final fatherCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final aadhaarCtrl = TextEditingController();

  String nurseType = "GNM";
  DateTime? joiningDate;

  File? profilePhoto;
  File? digitalSignature;
  List<File> qualificationDocs = [];
  List<File> experienceDocs = [];

  bool loading = false; // 🔹 Loader flag

  Future<File?> pickSingle() async {
    final x = await picker.pickImage(source: ImageSource.gallery);
    return x != null ? File(x.path) : null;
  }

  Future<void> pickMultiple(List<File> target) async {
    final files = await picker.pickMultiImage();
    if (files != null) {
      target.addAll(files.map((e) => File(e.path)));
      setState(() {});
    }
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) {
      _snack("Please fill all required fields", error: true);
      return;
    }
    if (joiningDate == null) {
      _snack("Please select joining date", error: true);
      return;
    }

    setState(() => loading = true); // 🔹 show loader

    try {
      String? profilePhotoPath;
      String? signaturePath;
      List<String> qualificationPaths = [];
      List<String> experiencePaths = [];

      if (profilePhoto != null) {
        profilePhotoPath = await FileUploadService.uploadFile(profilePhoto!);
      }

      if (digitalSignature != null) {
        signaturePath = await FileUploadService.uploadFile(digitalSignature!);
      }

      for (final file in qualificationDocs) {
        qualificationPaths.add(await FileUploadService.uploadFile(file));
      }

      for (final file in experienceDocs) {
        experiencePaths.add(await FileUploadService.uploadFile(file));
      }

      final payload = {
        "phone": phoneCtrl.text,
        "name": nameCtrl.text,
        "father_name": fatherCtrl.text,
        "email": emailCtrl.text,
        "nurse_type": nurseType,
        "aadhaar_number": aadhaarCtrl.text,
        "joining_date": DateFormat("yyyy-MM-dd").format(joiningDate!),
        "profile_photo": profilePhotoPath,
        "digital_signature": signaturePath,
        "qualification_docs": qualificationPaths,
        "experience_docs": experiencePaths,
      };

      await ApiClient.post("/nurse/self-signup", payload);

      _snack("Signup successful. Await admin approval ✅");
      Navigator.pop(context, true);
    } catch (e) {
      _snack("Signup failed: ${e.toString()}", error: true);
    } finally {
      setState(() => loading = false); // 🔹 hide loader
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(title: const Text("Nurse Self Signup"), centerTitle: true),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// 👤 PROFILE PHOTO
              GestureDetector(
                onTap: () async {
                  profilePhoto = await pickSingle();
                  setState(() {});
                },
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage: profilePhoto != null
                      ? FileImage(profilePhoto!)
                      : null,
                  child: profilePhoto == null
                      ? const Icon(Icons.camera_alt, size: 30)
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              _SectionCard(
                title: "Personal Information",
                icon: Icons.person,
                child: Column(
                  children: [
                    _field(phoneCtrl, "Phone", TextInputType.phone),
                    _field(nameCtrl, "Full Name"),
                    _field(fatherCtrl, "Father Name"),
                    _field(emailCtrl, "Email"),
                  ],
                ),
              ),

              _SectionCard(
                title: "Professional Details",
                icon: Icons.medical_services,
                child: Column(
                  children: [
                    DropdownButtonFormField(
                      value: nurseType,
                      items: const [
                        DropdownMenuItem(value: "GNM", child: Text("GNM")),
                        DropdownMenuItem(value: "ANM", child: Text("ANM")),
                        DropdownMenuItem(
                          value: "BSC",
                          child: Text("BSc Nursing"),
                        ),
                      ],
                      onChanged: (v) => setState(() => nurseType = v!),
                      decoration: const InputDecoration(
                        labelText: "Nurse Type",
                      ),
                    ),
                    _field(aadhaarCtrl, "Aadhaar Number", TextInputType.number),
                    const SizedBox(height: 10),
                    ListTile(
                      onTap: () async {
                        joiningDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        setState(() {});
                      },
                      title: const Text("Joining Date"),
                      subtitle: Text(
                        joiningDate == null
                            ? "Select date"
                            : DateFormat("dd MMM yyyy").format(joiningDate!),
                      ),
                      trailing: const Icon(Icons.calendar_month),
                    ),
                  ],
                ),
              ),

              _SectionCard(
                title: "Documents Upload",
                icon: Icons.upload_file,
                child: Column(
                  children: [
                    _UploadTile(
                      title: "Digital Signature",
                      count: digitalSignature == null ? 0 : 1,
                      onTap: () async {
                        digitalSignature = await pickSingle();
                        setState(() {});
                      },
                    ),
                    _UploadTile(
                      title: "Qualification Documents",
                      count: qualificationDocs.length,
                      onTap: () => pickMultiple(qualificationDocs),
                    ),
                    _UploadTile(
                      title: "Experience Documents",
                      count: experienceDocs.length,
                      onTap: () => pickMultiple(experienceDocs),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      /// 🔘 SUBMIT BUTTON
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: loading ? null : submit, // 🔹 disabled while loading
            child: loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    "Submit Application",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label, [
    TextInputType type = TextInputType.text,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: type,
        validator: (v) => v!.isEmpty ? "Required" : null,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData icon;

  const _SectionCard({
    required this.title,
    required this.child,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _UploadTile extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback onTap;

  const _UploadTile({
    required this.title,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: const Icon(Icons.upload),
      title: Text(title),
      trailing: count > 0
          ? CircleAvatar(
              radius: 12,
              backgroundColor: Colors.green,
              child: Text(
                "$count",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            )
          : const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}
