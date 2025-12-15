import 'package:dio/dio.dart';
import 'dart:io';

class AuthService {
  static final Dio _dio = Dio();

  // Use a getter to ensure baseUrl is always available
  static String get baseUrl {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:6001/api/v1";
    } else {
      return "http://localhost:6001/api/v1";
    }
  }

  /// LOGIN - Call the login API
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/auth/login',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
        data: {
          "email": email,
          "password": password,
        },
      );

      if (response.statusCode == 200) {
        return {
          "success": true,
          "data": response.data,
        };
      } else {
        return {
          "success": false,
          "message": response.data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }

  /// REGISTER - Call the register API
  static Future<Map<String, dynamic>> register(
      String fullName, String email, String password, String phoneNumber) async {
    try {
      final response = await _dio.post(
        '$baseUrl/auth/register',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
        data: {
          "fullName": fullName,
          "email": email,
          "password": password,
          "phoneNumber": phoneNumber,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          "success": true,
          "data": response.data,
        };
      } else {
        return {
          "success": false,
          "message": response.data['message'] ?? 'Registration failed',
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
