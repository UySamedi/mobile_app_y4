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
  static Future<Map<String, dynamic>> register(String fullName, String email,
      String password, String phoneNumber) async {
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

  /// GET PROFILE - Fetch user profile from /users/profile
  static Future<Map<String, dynamic>> getProfile(String token) async {
    try {
      final response = await _dio.get(
        '$baseUrl/users/profile',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return {
          "success": true,
          "data": response.data['data'],
        };
      } else {
        return {
          "success": false,
          "message": response.data['message'] ?? 'Failed to get profile',
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }

  /// REQUEST ROLE UPGRADE - Request role upgrade from /role-upgrade/request
  static Future<Map<String, dynamic>> requestRoleUpgrade(
    String requestedRole,
    String reason,
    String token,
  ) async {
    try {
      final response = await _dio.post(
        '$baseUrl/role-upgrade/request',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        data: {
          "requestedRole": requestedRole,
          "reason": reason,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          "success": true,
          "data": response.data['data'],
          "message": response.data['message'] ??
              'Role upgrade request created successfully',
        };
      } else {
        return {
          "success": false,
          "message": response.data['message'] ??
              'Failed to create role upgrade request',
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }

  /// GET MY ROLE UPGRADE REQUESTS - Fetch user's role upgrade requests
  static Future<Map<String, dynamic>> getMyRoleUpgradeRequests(
      String token) async {
    try {
      final response = await _dio.get(
        '$baseUrl/role-upgrade/my-requests',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return {
          "success": true,
          "data": response.data['data'],
          "message": response.data['message'] ??
              'Role upgrade requests retrieved successfully',
        };
      } else {
        return {
          "success": false,
          "message":
              response.data['message'] ?? 'Failed to get role upgrade requests',
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }

  /// GET ADMIN ROLE UPGRADE REQUESTS - Fetch all role upgrade requests for admin
  static Future<Map<String, dynamic>> getAdminRoleUpgradeRequests(
      String token) async {
    try {
      final response = await _dio.get(
        '$baseUrl/role-upgrade/admin/requests',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return {
          "success": true,
          "data": response.data['data'],
          "message": response.data['message'] ??
              'All role upgrade requests retrieved successfully',
        };
      } else {
        return {
          "success": false,
          "message":
              response.data['message'] ?? 'Failed to get role upgrade requests',
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }

  /// APPROVE ROLE UPGRADE REQUEST - Approve a role upgrade request
  static Future<Map<String, dynamic>> approveRoleUpgradeRequest(
    int requestId,
    String adminComment,
    String token,
  ) async {
    try {
      final response = await _dio.post(
        '$baseUrl/role-upgrade/admin/requests/$requestId/approve',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        data: {
          "adminComment": adminComment,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "data": response.data['data'],
          "message": response.data['message'] ??
              'Role upgrade request approved successfully',
        };
      } else {
        return {
          "success": false,
          "message": response.data['message'] ??
              'Failed to approve role upgrade request',
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }

  /// REJECT ROLE UPGRADE REQUEST - Reject a role upgrade request
  static Future<Map<String, dynamic>> rejectRoleUpgradeRequest(
    int requestId,
    String adminComment,
    String token,
  ) async {
    try {
      final response = await _dio.post(
        '$baseUrl/role-upgrade/admin/requests/$requestId/reject',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        data: {
          "adminComment": adminComment,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "data": response.data['data'],
          "message": response.data['message'] ??
              'Role upgrade request rejected successfully',
        };
      } else {
        return {
          "success": false,
          "message": response.data['message'] ??
              'Failed to reject role upgrade request',
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
