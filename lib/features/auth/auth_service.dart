import 'dart:convert';
import 'package:healthcare/core/network/base.dart';
import 'package:http/http.dart' as http;
import '../../core/storage/token_storage.dart';

class AuthService {
  static const baseUrl = baseUrlApi;

  /// 🔹 SEND OTP
  static Future<void> sendOtp(String phone) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/send-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phone": phone}),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to send OTP");
    }
  }

  static Future<void> verifyOtp(String phone, String otp) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/verify-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "phone": phone,
        "otp": otp,
      }),
    );

    /// ❌ ERROR RESPONSE
    if (res.statusCode != 200) {
      String message = "Something went wrong";

      try {
        final body = jsonDecode(res.body);
        if (body is Map && body.containsKey("detail")) {
          message = body["detail"];
        }
      } catch (_) {}

      throw Exception(message);
    }

    /// ✅ SUCCESS
    final data = jsonDecode(res.body);

    if (!data.containsKey("access_token")) {
      throw Exception("Invalid server response");
    }

    await TokenStorage.saveToken(data["access_token"]);
  }
}
