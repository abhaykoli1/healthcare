import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:healthcare/core/network/base.dart';
import 'package:healthcare/core/storage/token_storage.dart';
import 'dart:io';

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

  /// 🔹 DELETE with token (supports body)
  static Future<dynamic> delete(String path, Map body) async {
    final token = await TokenStorage.getToken();

    final res = await http.delete(
      Uri.parse("$baseUrl$path"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    log(res.body);

    _handleError(res);

    // kuch DELETE APIs empty response bhejti hain
    if (res.body.isEmpty) {
      return {"success": true};
    }

    return jsonDecode(res.body);
  }

  /// 🔹 PUT with token
  static Future<dynamic> put(String path, Map body) async {
    final token = await TokenStorage.getToken();

    final res = await http.put(
      Uri.parse("$baseUrl$path"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    log(res.body);

    _handleError(res);

    return jsonDecode(res.body);
  }

  /// 🔹 POST with token
  // static Future<dynamic> post(String path, Map body) async {
  //   final token = await TokenStorage.getToken();

  //   final res = await http.post(
  //     Uri.parse("$baseUrl$path"),
  //     headers: {
  //       "Authorization": "Bearer $token",
  //       "Content-Type": "application/json",
  //     },
  //     body: jsonEncode(body),
  //   );

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
    log(res.body);
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

// class FileUploadService {
//   static Future<String> uploadFile(
//     File file, {
//     String folder = "documents",
//   }) async {
//     final request = http.MultipartRequest(
//       "POST",
//       Uri.parse("$baseUrlApi/upload/file?folder=$folder"),
//     );

//     request.files.add(
//       await http.MultipartFile.fromPath("file", file.path),
//     );

//     final response = await request.send();
//     final body = await response.stream.bytesToString();

//     log(body);

//     if (response.statusCode != 200) {
//       throw Exception("File upload failed");
//     }

//     final data = jsonDecode(body);
//     return data["path"]; // 🔥 backend ka exact path
//   }
// }
class FileUploadService {
  static Future<String> uploadFile(
    File file, {
    String folder = "documents",
  }) async {
    final token = await TokenStorage.getToken();
    log("UPLOAD TOKEN: $token");

    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrlApi/upload/file?folder=$folder"),
    );

    request.headers.addAll({"Authorization": "Bearer $token"});

    request.files.add(await http.MultipartFile.fromPath("file", file.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    log("UPLOAD STATUS: ${response.statusCode}");
    log("UPLOAD BODY: $body");

    if (response.statusCode != 200) {
      throw Exception("File upload failed (${response.statusCode})");
    }

    final data = jsonDecode(body);
    return data["path"];
  }
}
