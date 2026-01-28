import 'package:flutter/material.dart';
import 'package:healthcare/core/theme/app_theme.dart';
import 'package:healthcare/features/auth/auth_service.dart';
import '../../routes/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final phoneCtrl = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primarylight,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // decoration: const BoxDecoration(
        //   gradient: LinearGradient(
        //     colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
        //     begin: Alignment.topLeft,
        //     end: Alignment.bottomRight,
        //   ),
        // ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// 🔹 LOGO / ICON
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primary,
                  ),
                  child: const Icon(
                    Icons.local_hospital,
                    size: 52,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Secure access for healthcare staff",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),

                const SizedBox(height: 18),

                /// 🔹 LOGIN CARD
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const Text(
                      //   "Login",
                      //   style: TextStyle(
                      //     fontSize: 20,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                      // const SizedBox(height: 8),
                      const Text(
                        "Enter your registered mobile number",
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),

                      const SizedBox(height: 14),

                      /// 🔹 PHONE FIELD
                      // TextField(
                      //   controller: phoneCtrl,
                      //   keyboardType: TextInputType.phone,
                      //   maxLength: 10,
                      //   decoration: InputDecoration(
                      //     fillColor: AppTheme.primarylight,
                      //     labelText: "Mobile Number",
                      //     prefixIcon: const Icon(Icons.phone),
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(12),
                      //     ),
                      //   ),
                      // ),
                      TextFormField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        // validator: (v) => v!.isEmpty ? "Required" : null,
                        maxLength: 10,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.phone),
                          labelText: "Mobile Number",
                          filled: true, // 🔹 important
                          fillColor:
                              AppTheme.primarylight, // 🔹 background color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none, // clean look
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// 🔥 SEND OTP BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: loading
                              ? null
                              : () async {
                                  if (phoneCtrl.text.length != 10) return;

                                  setState(() => loading = true);

                                  await AuthService.sendOtp(phoneCtrl.text);

                                  setState(() => loading = false);

                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.otp,
                                    arguments: phoneCtrl.text,
                                  );
                                },
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
                                  "SEND OTP",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// 🔹 DIVIDER
                      Row(
                        children: const [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              "OR",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),

                      const SizedBox(height: 12),

                      /// 🔥 NURSE CONSENT BUTTON
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.nurseSignup);
                          },
                          child: const Text(
                            "New Nurse? Apply for Verification",
                            style: TextStyle(
                              // color: AppTheme.new,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "© 2025 Healthcare Services",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
