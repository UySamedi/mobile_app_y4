import 'package:dio/dio.dart' hide FormData;
import 'package:dio/dio.dart' as dio;
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
        return {
          "success": false,
          "message": response.data['message'] ?? 'Failed to get homes'
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  static Future<Map<String, dynamic>> getHomeById(
      int homeId, String token) async {
    try {
      // Use /homes endpoint to get all homes, then filter by ID
      final response = await _dio.get(
        '${AuthService.baseUrl}/homes',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> homes = response.data['data'] ?? [];
        // Find the home with matching ID
        final home = homes.firstWhere(
          (h) => h['id'] == homeId,
          orElse: () => null,
        );

        if (home != null) {
          return {"success": true, "data": home};
        } else {
          return {"success": false, "message": "Home not found"};
        }
      } else {
        return {
          "success": false,
          "message": response.data['message'] ?? 'Failed to get home details'
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  static Future<Map<String, dynamic>> updateHome(
      int homeId, Map<String, dynamic> data, String token) async {
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
        return {
          "success": false,
          "message": response.data['message'] ?? 'Failed to update home'
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  static Future<Map<String, dynamic>> deleteHome(
      int homeId, String token) async {
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
        return {
          "success": false,
          "message": response.data['message'] ?? 'Failed to delete home'
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  static Future<Map<String, dynamic>> getRules(String token) async {
    try {
      final response = await _dio.get(
        '${AuthService.baseUrl}/homes/rules',
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
        return {
          "success": false,
          "message": response.data['message'] ?? 'Failed to get rules'
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  static Future<Map<String, dynamic>> createRoom(
    dio.FormData formData,
    String token,
  ) async {
    try {
      final response = await _dio.post(
        '${AuthService.baseUrl}/homes/rooms',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "data": response.data['data']};
      } else {
        return {
          "success": false,
          "message": response.data['message'] ?? 'Failed to create room'
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  static Future<Map<String, dynamic>> createRule(
    Map<String, dynamic> data,
    String token,
  ) async {
    try {
      final response = await _dio.post(
        '${AuthService.baseUrl}/homes/rules',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "data": response.data['data']};
      } else {
        return {
          "success": false,
          "message": response.data['message'] ?? 'Failed to create rule'
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }
}
