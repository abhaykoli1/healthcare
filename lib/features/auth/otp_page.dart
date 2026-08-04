import 'dart:async';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:healthcare/core/theme/app_theme.dart';
import 'auth_service.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController otpCtrl = TextEditingController();

  bool loading = false;
  bool resendLoading = false;

  /* ================= TIMER ================= */
  int secondsRemaining = 30;
  bool canResend = false;
  Timer? _timer;

  /* ================= FCM ================= */
  String fcmToken = "";

  /* ================= INIT ================= */
  @override
  void initState() {
    super.initState();
    _startTimer();
    _initFCM(); // 🔥 permission only once
  }

  /* ================= FCM SETUP ================= */
  Future<void> _initFCM() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      await messaging.requestPermission();

      final token = await messaging.getToken();

      if (token != null) {
        fcmToken = token;
        log("🔥 FCM TOKEN => $fcmToken");
      }
    } catch (e) {
      log("FCM ERROR => $e");
    }
  }

  /* ================= TIMER ================= */
  void _startTimer() {
    secondsRemaining = 30;
    canResend = false;

    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining == 0) {
        timer.cancel();
        setState(() => canResend = true);
      } else {
        setState(() => secondsRemaining--);
      }
    });
  }

  /* ================= RESEND OTP ================= */
  Future<void> _resendOtp(String phone) async {
    if (resendLoading || !canResend) return;

    setState(() => resendLoading = true);

    try {
      await AuthService.sendOtp(phone);

      if (!mounted) return;
      otpCtrl.clear();
      _startTimer();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("OTP resent successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception:", "").trim()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => resendLoading = false);
    }
  }

  /* ================= VERIFY OTP ================= */
  Future<void> _verifyOtp(String phone) async {
    final otp = otpCtrl.text.trim();
    if (otp.length != 6 || int.tryParse(otp) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter a valid 6-digit OTP"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await AuthService.verifyOtp(
        phone,
        otp,
        context,
        fcmToken, // 🔥 safe token (no crash)
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception:", "")),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  /* ================= DISPOSE ================= */
  @override
  void dispose() {
    _timer?.cancel();
    otpCtrl.dispose();
    super.dispose();
  }

  /* ================= UI ================= */
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
            Text(
              "OTP sent to $phone",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            /* OTP FIELD */
            TextField(
              controller: otpCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 6,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                if (!loading && !resendLoading) {
                  _verifyOtp(phone);
                }
              },
              decoration: const InputDecoration(
                labelText: "Enter OTP",
                prefixIcon: Icon(Icons.lock),
                counterText: "",
              ),
            ),
            const SizedBox(height: 8),

            /* TIMER */
            if (!canResend)
              Text(
                "Resend OTP in $secondsRemaining sec",
                style: const TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 24),

            /* VERIFY BUTTON */
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    loading || resendLoading ? null : () => _verifyOtp(phone),
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("VERIFY & LOGIN"),
              ),
            ),
            const SizedBox(height: 12),

            /* RESEND BUTTON - independent from Verify */
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: canResend && !loading && !resendLoading
                    ? () => _resendOtp(phone)
                    : null,
                child: resendLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("RESEND OTP"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
