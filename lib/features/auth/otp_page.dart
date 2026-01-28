import 'package:flutter/material.dart';
import 'package:healthcare/core/theme/app_theme.dart';
import '../../routes/app_routes.dart';
import 'auth_service.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final otpCtrl = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final phone = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      backgroundColor: AppTheme.primarylight,

      appBar: AppBar(title: const Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text("OTP sent to $phone"),
            const SizedBox(height: 24),

            TextField(
              controller: otpCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter OTP",
                prefixIcon: Icon(Icons.lock),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading
                    ? null
                    : () async {
                        if (otpCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Enter OTP")),
                          );
                          return;
                        }

                        setState(() => loading = true);

                        try {
                          await AuthService.verifyOtp(
                            phone,
                            otpCtrl.text,
                            context,
                          );

                          if (!mounted) return;
                        } catch (e) {
                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                e.toString().replaceAll("Exception:", ""),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          if (mounted) {
                            setState(() => loading = false);
                          }
                        }
                      },
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("VERIFY & LOGIN"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
