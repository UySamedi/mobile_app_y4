// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class AuthService {
//   static const String baseUrl = "http://localhost:6001/api/v1";
//
//   static Future<Map<String, dynamic>> login(String email, String password) async {
//     final url = Uri.parse('$baseUrl/auth/login');
//
//     final response = await http.post(
//       url,
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({
//         "email": email,
//         "password": password,
//       }),
//     );
//
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       return jsonDecode(response.body);
//     } else {
//       return {
//         "status": response.statusCode,
//         "message": "Login failed"
//       };
//     }
//   }
//
//   static Future<Map<String, dynamic>> register(String fullName, String email, String password, String phone) async {
//     final url = Uri.parse('$baseUrl/auth/register');
//
//     final response = await http.post(
//       url,
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({
//         "fullName": fullName,
//         "email": email,
//         "password": password,
//         "phone": phone,
//       }),
//     );
//
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       return jsonDecode(response.body);
//     } else {
//       return {
//         "status": response.statusCode,
//         "message": "Registration failed"
//       };
//     }
//   }
// }



import 'package:dio/dio.dart';
import 'dart:convert';

class AuthService {
  static final Dio _dio = Dio();

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await _dio.request(
        'http://10.0.2.2:6001/api/v1/auth/login', // Android Emulator
        // For iOS use http://127.0.0.1:6001
        options: Options(
          method: 'POST',
          headers: {'Content-Type': 'application/json'},
        ),
        data: json.encode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        return {
          "success": true,
          "data": response.data,
        };
      } else {
        return {
          "success": false,
          "message": response.statusMessage,
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }
}
