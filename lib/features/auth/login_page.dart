import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../routes/app_routes.dart';
import 'auth_provider.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phoneCtrl = TextEditingController();
    final auth = ref.watch(authProvider);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_hospital, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    "Staff Login",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Registered Mobile Number",
                      prefixIcon: Icon(Icons.phone),
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
                                  .sendOtp(phoneCtrl.text);

                              Navigator.pushNamed(
                                context,
                                AppRoutes.otp,
                                arguments: phoneCtrl.text,
                              );
                            },
                      child: auth.loading
                          ? const CircularProgressIndicator()
                          : const Text("SEND OTP"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
