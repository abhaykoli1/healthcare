import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../routes/app_routes.dart';
import 'auth_provider.dart';

class OtpPage extends ConsumerWidget {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phone = ModalRoute.of(context)!.settings.arguments as String;
    final otpCtrl = TextEditingController();
    final auth = ref.watch(authProvider);

    return Scaffold(
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
                onPressed: auth.loading
                    ? null
                    : () async {
                        await ref
                            .read(authProvider.notifier)
                            .verifyOtp(phone, otpCtrl.text);

                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.dashboard,
                        );
                      },
                child: auth.loading
                    ? const CircularProgressIndicator()
                    : const Text("VERIFY & LOGIN"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
