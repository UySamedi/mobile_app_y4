import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var message = ''.obs;
  var token = ''.obs;
  var user = {}.obs;

  final String baseUrl = "http://localhost:6001/api/v1";

  /// LOGIN
  Future<bool> login(String email, String password) async {
    isLoading.value = true;
    message.value = '';

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        token.value = data['data']['access_token'];
        user.value = data['data']['user'];
        isLoading.value = false;
        return true;
      } else {
        message.value = data['message'] ?? 'Login failed';
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      message.value = 'Error: $e';
      isLoading.value = false;
      return false;
    }
  }

  /// REGISTER
  Future<void> register(String fullName, String email, String password, String phone) async {
    isLoading.value = true;
    message.value = '';

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fullName": fullName,
          "email": email,
          "password": password,
          "phone": phone,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        message.value = data['message'] ?? 'Registration successful';
      } else {
        message.value = data['message'] ?? 'Registration failed';
      }
    } catch (e) {
      message.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// LOGOUT
  void logout() {
    token.value = '';
    user.value = {};
    Get.offAllNamed('/login'); // Navigate to login
  }

  /// CLEAR MESSAGE
  void clearMessage() {
    message.value = '';
  }
}
