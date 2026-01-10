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
    if (!_formKey.currentState!.validate()) return;

    try {
      /// 🔥 1️⃣ Upload files first
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

      /// 🔥 2️⃣ Send JSON payload
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Signup successful. Await admin approval."),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nurse Self Signup")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: "Phone"),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.length == 10 ? null : "Invalid phone",
              ),

              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),

              TextFormField(
                controller: fatherCtrl,
                decoration: const InputDecoration(labelText: "Father Name"),
              ),

              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: "Email"),
              ),

              DropdownButtonFormField(
                value: nurseType,
                items: const [
                  DropdownMenuItem(value: "GNM", child: Text("GNM")),
                  DropdownMenuItem(value: "ANM", child: Text("ANM")),
                  DropdownMenuItem(value: "BSC", child: Text("BSc Nursing")),
                ],
                onChanged: (v) => setState(() => nurseType = v!),
                decoration: const InputDecoration(labelText: "Nurse Type"),
              ),

              TextFormField(
                controller: aadhaarCtrl,
                decoration: const InputDecoration(labelText: "Aadhaar Number"),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () async {
                  joiningDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                },
                child: const Text("Select Joining Date"),
              ),

              const Divider(),

              ElevatedButton(
                onPressed: () async {
                  profilePhoto = await pickSingle();
                  setState(() {});
                },
                child: const Text("Pick Profile Photo"),
              ),

              ElevatedButton(
                onPressed: () async {
                  digitalSignature = await pickSingle();
                  setState(() {});
                },
                child: const Text("Pick Digital Signature"),
              ),

              ElevatedButton(
                onPressed: () => pickMultiple(qualificationDocs),
                child: const Text("Pick Qualification Docs"),
              ),

              ElevatedButton(
                onPressed: () => pickMultiple(experienceDocs),
                child: const Text("Pick Experience Docs"),
              ),

              const SizedBox(height: 20),

              ElevatedButton(onPressed: submit, child: const Text("Submit")),
            ],
          ),
        ),
      ),
    );
  }
}
