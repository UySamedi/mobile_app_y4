import 'package:get/get.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/home_model.dart';
import 'auth_controller.dart';

class HomeController extends GetxController {
  var homes = <HomeModel>[].obs;
  var isLoading = false.obs;
  var error = ''.obs;
  var favoritedHomes = <HomeModel>[].obs;

  late String baseUrl;
  final AuthController auth = Get.find();

  @override
  void onInit() {
    super.onInit();
    if (Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:6001/api/v1';
    } else {
      baseUrl = 'http://localhost:6001/api/v1';
    }
    fetchHomes();
  }

  void toggleFavorite(HomeModel home) {
    if (favoritedHomes.contains(home)) {
      favoritedHomes.remove(home);
    } else {
      favoritedHomes.add(home);
    }
  }

  Future<void> fetchHomes() async {
    isLoading.value = true;
    error.value = '';
    try {
      final headers = <String, String>{'Content-Type': 'application/json'};

      if (auth.token.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${auth.token.value}';
      }

      final res = await http
          .get(Uri.parse('$baseUrl/homes'), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['data'] as List<dynamic>?) ?? [];
        homes.value = list.map((e) => HomeModel.fromJson(Map<String, dynamic>.from(e))).toList();
      } else if (res.statusCode == 401) {
        error.value = 'Unauthorized. Please login again.';
        Future.delayed(const Duration(milliseconds: 500), () {
          auth.logout();
        });
      } else {
        error.value = 'Failed to load homes (${res.statusCode})';
      }
    } catch (e) {
      error.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
