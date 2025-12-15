import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'Auth/LoginScreen.dart';
import 'Auth/RegisterScreen.dart';
import 'Screen/CreateHomeScreen.dart';
import 'Screen/DetailScreen.dart';
import 'Screen/EditHomeScreen.dart';
import 'Screen/HomeScreen.dart';
import 'Screen/MainNav.dart';
import 'Screen/Myhomescreen.dart';
import 'Screen/SplashScreen.dart';
import 'controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(AuthController());
  runApp(const MyLoginApp());
}

class MyLoginApp extends StatelessWidget {
  const MyLoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(name: '/home', page: () => HomeScreen()),
        GetPage(name: '/create-home', page: () => const Createhomescreen()),
        GetPage(name: '/my-home', page: () => const Myhomescreen()),
        GetPage(name: '/main', page: () => const MainNav()),
        GetPage(
          name: '/detail',
          page: () {
            final Map<String, dynamic> home = Get.arguments;
            return DetailScreen(home: home);
          },
        ),
        GetPage(
          name: '/edit-home',
          page: () {
            final Map<String, dynamic> home = Get.arguments;
            return EditHomeScreen(home: home);
          },
        ),
      ],
    );
  }
}
