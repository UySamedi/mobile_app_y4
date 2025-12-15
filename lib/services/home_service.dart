import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'auth_service.dart';

class HomeService {
  static final Dio _dio = Dio();

  static Future<Map<String, dynamic>> getMyHomes(String token) async {
    try {
      final response = await _dio.get(
        '${AuthService.baseUrl}/homes/my-homes',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return {"success": true, "data": response.data['data']};
      } else {
        return {"success": false, "message": response.data['message'] ?? 'Failed to get homes'};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  static Future<Map<String, dynamic>> getHomeById(int homeId, String token) async {
    try {
      final response = await _dio.get(
        '${AuthService.baseUrl}/homes/$homeId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return {"success": true, "data": response.data['data']};
      } else {
        return {"success": false, "message": response.data['message'] ?? 'Failed to get home details'};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  static Future<Map<String, dynamic>> updateHome(int homeId, Map<String, dynamic> data, String token) async {
    try {
      final response = await _dio.put(
        '${AuthService.baseUrl}/homes/$homeId',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return {"success": true, "data": response.data['data']};
      } else {
        return {"success": false, "message": response.data['message'] ?? 'Failed to update home'};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  static Future<Map<String, dynamic>> deleteHome(int homeId, String token) async {
    try {
      final response = await _dio.delete(
        '${AuthService.baseUrl}/homes/$homeId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return {"success": true};
      } else {
        return {"success": false, "message": response.data['message'] ?? 'Failed to delete home'};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }
}
