import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:healthcare/core/network/base.dart';
import 'package:healthcare/core/storage/token_storage.dart';

class ApiClient {
  static const baseUrl = baseUrlApi;

  /// 🔹 GET with token
  static Future<dynamic> get(String path) async {
    final token = await TokenStorage.getToken();

    final res = await http.get(
      Uri.parse("$baseUrl$path"),
      headers: {
       
       "Authorization": "Bearer $token",
          "Content-Type": "application/json",
      },
    );
     log(res.body);
    _handleError(res);
    return jsonDecode(res.body);
  }

  /// 🔹 POST with token
  static Future<dynamic> post(String path, Map body) async {
    final token = await TokenStorage.getToken();

    final res = await http.post(
      Uri.parse("$baseUrl$path"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      
      },
      body: jsonEncode(body),
    );
    log(  res.body);
    _handleError(res);
    return jsonDecode(res.body);
  }

  /// 🔹 Central error handling
  static void _handleError(http.Response res) {
    if (res.statusCode >= 400) {
      try {
        final body = jsonDecode(res.body);
        throw Exception(body["detail"] ?? "API Error");
      } catch (_) {
        throw Exception("API Error (${res.statusCode})");
      }
    }
  }
}
