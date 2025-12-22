import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var message = ''.obs;
  // messageType: 'success' | 'error' | '' (empty)
  var messageType = ''.obs;
  var token = ''.obs;
  var user = {}.obs;

  // Dynamic base URL based on platform
  late String baseUrl;
  final GetStorage box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    // For Android emulator: 10.0.2.2, for other platforms: localhost
    if (Platform.isAndroid) {
      baseUrl = "http://10.0.2.2:6001/api/v1";
    } else {
      baseUrl = "http://localhost:6001/api/v1";
    }
    print('🔗 Using baseUrl: $baseUrl');

    // Restore token and user from storage if available
    final storedToken = box.read('token') ?? '';
    final storedUser = box.read('user') ?? {};
    if (storedToken != null && storedToken.toString().isNotEmpty) {
      token.value = storedToken.toString();
      user.value = Map<String, dynamic>.from(storedUser);
      print('🔁 Restored token and user from storage');
    }
  }

  /// Validate stored token by calling a lightweight protected endpoint (/homes).
  /// Returns true when token is valid (HTTP 200). If invalid (401/403) it clears storage.
  Future<bool> validateToken() async {
    final storedToken = box.read('token') ?? '';
    if (storedToken == null || storedToken.toString().isEmpty) {
      return false;
    }

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${storedToken.toString()}'
      };
      final res = await http
          .get(Uri.parse('$baseUrl/homes'), headers: headers)
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        // token looks valid
        token.value = storedToken.toString();
        final storedUser = box.read('user') ?? {};
        user.value = Map<String, dynamic>.from(storedUser);
        return true;
      } else if (res.statusCode == 401 || res.statusCode == 403) {
        // invalid token - clear storage
        box.remove('token');
        box.remove('user');
        token.value = '';
        user.value = {};
        print('🔒 Token invalid (status ${res.statusCode}) - cleared stored credentials');
        return false;
      } else {
        // Other status codes (e.g., 5xx) — keep stored credentials to allow offline
        print('⚠️ Token validation returned status ${res.statusCode} — keeping stored token');
        token.value = storedToken.toString();
        final storedUser = box.read('user') ?? {};
        user.value = Map<String, dynamic>.from(storedUser);
        return true;
      }
    } catch (e) {
      print('⚠️ Token validation error (network?): $e');
      // Network error: treat token as valid to avoid forcing login when offline or server unreachable
      token.value = storedToken.toString();
      final storedUser = box.read('user') ?? {};
      user.value = Map<String, dynamic>.from(storedUser);
      return true;
    }
  }

  /// LOGIN
  Future<bool> login(String email, String password) async {
    isLoading.value = true;
    message.value = '';
    messageType.value = '';

    try {
      print('🔗 API URL: $baseUrl/auth/login');
      print('📤 Login Request: email=$email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timeout. Server not responding.');
        },
      );

      print('📍 Login Response Status: ${response.statusCode}');
      print('📍 Login Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final accessToken = data['data']?['access_token'] ?? data['access_token'] ?? '';
        final userData = data['data']?['user'] ?? data['user'] ?? {};
        
        token.value = accessToken;
        user.value = userData;

        // Persist token and user
        box.write('token', token.value);
        // user is an RxMap; convert to a plain Map before writing
        box.write('user', Map<String, dynamic>.from(user));

        message.value = data['message'] ?? 'Login successful';
        messageType.value = 'success';
        isLoading.value = false;
        
        print('✅ Login Successful');
        print('👤 User: $userData');
        print('🔐 Token Length: ${token.value.length}');
        
        // Navigate to main navigation after successful login
        Future.delayed(const Duration(milliseconds: 500), () {
          print('🚀 Navigating to /main');
          Get.offAllNamed('/main');
        });
        return true;
      } else {
        message.value = data['message'] ?? 'Login failed (Status: ${response.statusCode})';
        messageType.value = 'error';
        isLoading.value = false;
        print('❌ Login Failed: ${response.statusCode}');
        print('📝 Response: $data');
        return false;
      }
    } on TimeoutException catch (e) {
      message.value = 'Connection timeout. Make sure the backend server is running.';
      messageType.value = 'error';
      isLoading.value = false;
      print('⏱️ Timeout: $e');
      return false;
    } catch (e) {
      message.value = 'Error: Unable to connect to server. Is it running?';
      messageType.value = 'error';
      isLoading.value = false;
      print('⚠️ Login Exception: $e');
      return false;
    }
  }

  /// REGISTER
  Future<void> register(String fullName, String email, String password, String phoneNumber) async {
    isLoading.value = true;
    message.value = '';
    messageType.value = '';

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fullName": fullName,
          "email": email,
          "password": password,
          "phoneNumber": phoneNumber,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timeout. Server not responding.');
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        message.value = data['message'] ?? 'Registration successful';
        messageType.value = 'success';
        // Navigate to login screen after successful registration
        await Future.delayed(const Duration(seconds: 1));
        Get.offAllNamed('/login');
      } else {
        message.value = data['message'] ?? 'Registration failed';
        messageType.value = 'error';
      }
    } on TimeoutException catch (e) {
      message.value = 'Connection timeout. Make sure the backend server is running.';
      messageType.value = 'error';
      print('⏱️ Register Timeout: $e');
    } catch (e) {
      message.value = 'Error: Unable to connect to server. Is it running?';
      messageType.value = 'error';
      print('⚠️ Register Exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// LOGOUT
  void logout() {
    token.value = '';
    user.value = {};
    box.remove('token');
    box.remove('user');
    Get.offAllNamed('/login'); // Navigate to login
  }

  /// CLEAR MESSAGE
  void clearMessage() {
    message.value = '';
    messageType.value = '';
  }

  /// FETCH PROFILE - Get full user profile from /users/profile
  Future<bool> fetchProfile() async {
    if (token.value.isEmpty) {
      return false;
    }

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token.value}',
      };

      final response = await http
          .get(Uri.parse('$baseUrl/users/profile'), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final profileData = data['data'] ?? {};
        
        // Update user data with full profile (includes phoneNumber, etc.)
        user.value = Map<String, dynamic>.from(profileData);
        
        // Persist updated user data
        box.write('user', Map<String, dynamic>.from(user));
        
        print('✅ Profile fetched successfully');
        print('👤 Updated User: $profileData');
        return true;
      } else {
        print('❌ Failed to fetch profile: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('⚠️ Profile fetch error: $e');
      return false;
    }
  }

  /// REQUEST ROLE UPGRADE - Request role upgrade
  Future<Map<String, dynamic>> requestRoleUpgrade(
    String requestedRole,
    String reason,
  ) async {
    if (token.value.isEmpty) {
      return {
        "success": false,
        "message": "No authentication token found",
      };
    }

    try {
      final result = await AuthService.requestRoleUpgrade(
        requestedRole,
        reason,
        token.value,
      );

      if (result['success']) {
        message.value = result['message'] ?? 'Role upgrade request submitted successfully';
        messageType.value = 'success';
        print('✅ Role upgrade request created successfully');
        return result;
      } else {
        message.value = result['message'] ?? 'Failed to submit role upgrade request';
        messageType.value = 'error';
        print('❌ Role upgrade request failed: ${result['message']}');
        return result;
      }
    } catch (e) {
      message.value = 'Error: $e';
      messageType.value = 'error';
      print('⚠️ Role upgrade request error: $e');
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }

  /// GET MY ROLE UPGRADE REQUESTS - Fetch user's role upgrade requests
  Future<Map<String, dynamic>> getMyRoleUpgradeRequests() async {
    if (token.value.isEmpty) {
      return {
        "success": false,
        "message": "No authentication token found",
        "data": [],
      };
    }

    try {
      final result = await AuthService.getMyRoleUpgradeRequests(token.value);

      if (result['success']) {
        print('✅ Role upgrade requests fetched successfully');
        return result;
      } else {
        print('❌ Failed to fetch role upgrade requests: ${result['message']}');
        return result;
      }
    } catch (e) {
      print('⚠️ Get role upgrade requests error: $e');
      return {
        "success": false,
        "message": "Error: $e",
        "data": [],
      };
    }
  }

  /// GET ADMIN ROLE UPGRADE REQUESTS - Fetch all role upgrade requests for admin
  Future<Map<String, dynamic>> getAdminRoleUpgradeRequests() async {
    if (token.value.isEmpty) {
      return {
        "success": false,
        "message": "No authentication token found",
        "data": [],
      };
    }

    try {
      final result = await AuthService.getAdminRoleUpgradeRequests(token.value);

      if (result['success']) {
        print('✅ Admin role upgrade requests fetched successfully');
        return result;
      } else {
        print('❌ Failed to fetch admin role upgrade requests: ${result['message']}');
        return result;
      }
    } catch (e) {
      print('⚠️ Get admin role upgrade requests error: $e');
      return {
        "success": false,
        "message": "Error: $e",
        "data": [],
      };
    }
  }

  /// APPROVE ROLE UPGRADE REQUEST - Approve a role upgrade request
  Future<Map<String, dynamic>> approveRoleUpgradeRequest(
    int requestId,
    String adminComment,
  ) async {
    if (token.value.isEmpty) {
      return {
        "success": false,
        "message": "No authentication token found",
      };
    }

    try {
      final result = await AuthService.approveRoleUpgradeRequest(
        requestId,
        adminComment,
        token.value,
      );

      if (result['success']) {
        message.value = result['message'] ?? 'Role upgrade request approved successfully';
        messageType.value = 'success';
        print('✅ Role upgrade request approved');
        return result;
      } else {
        message.value = result['message'] ?? 'Failed to approve role upgrade request';
        messageType.value = 'error';
        print('❌ Failed to approve: ${result['message']}');
        return result;
      }
    } catch (e) {
      message.value = 'Error: $e';
      messageType.value = 'error';
      print('⚠️ Approve role upgrade request error: $e');
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }

  /// REJECT ROLE UPGRADE REQUEST - Reject a role upgrade request
  Future<Map<String, dynamic>> rejectRoleUpgradeRequest(
    int requestId,
    String adminComment,
  ) async {
    if (token.value.isEmpty) {
      return {
        "success": false,
        "message": "No authentication token found",
      };
    }

    try {
      final result = await AuthService.rejectRoleUpgradeRequest(
        requestId,
        adminComment,
        token.value,
      );

      if (result['success']) {
        message.value = result['message'] ?? 'Role upgrade request rejected successfully';
        messageType.value = 'success';
        print('✅ Role upgrade request rejected');
        return result;
      } else {
        message.value = result['message'] ?? 'Failed to reject role upgrade request';
        messageType.value = 'error';
        print('❌ Failed to reject: ${result['message']}');
        return result;
      }
    } catch (e) {
      message.value = 'Error: $e';
      messageType.value = 'error';
      print('⚠️ Reject role upgrade request error: $e');
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }
}
