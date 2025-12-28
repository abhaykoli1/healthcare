import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const baseUrl = "http://YOUR_SERVER_IP:8000";

  static Future<dynamic> post(String path, Map body) async {
    final res = await http.post(
      Uri.parse("$baseUrl$path"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
    return jsonDecode(res.body);
  }

  static Future<dynamic> get(String path) async {
    final res = await http.get(Uri.parse("$baseUrl$path"));
    return jsonDecode(res.body);
  }
}
