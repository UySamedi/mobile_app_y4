import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'Auth/LoginScreen.dart';
import 'Auth/RegisterScreen.dart';
import 'Screen/CreateHomeScreen.dart';
import 'Screen/CreateRoomScreen.dart';
import 'Screen/CreateRuleScreen.dart';
import 'Screen/DetailScreen.dart';
import 'Screen/EditHomeScreen.dart';
import 'Screen/HomeScreen.dart';
import 'Screen/MainNav.dart';
import 'Screen/Myhomescreen.dart';
import 'Screen/RoleUpgradeRequestsScreen.dart';
import 'Screen/AdminRoleUpgradeRequestsScreen.dart';
import 'Screen/SplashScreen.dart';
import 'Screen/onboarding_screen.dart';
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
      initialRoute: '/onboarding',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(name: '/home', page: () => HomeScreen()),
        GetPage(name: '/create-home', page: () => const Createhomescreen()),
        GetPage(name: '/my-home', page: () => const Myhomescreen()),
        GetPage(name: '/main', page: () => const MainNav()),
        GetPage(
          name: '/detail',
          page: () {
            final Map<String, dynamic>? home = Get.arguments;
            if (home == null) {
              return const Scaffold(
                body: Center(child: Text('Error: No home data provided')),
              );
            }
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
        GetPage(
          name: '/create-room',
          page: () {
            final Map<String, dynamic>? home = Get.arguments;
            if (home == null) {
              return const Scaffold(
                body: Center(child: Text('Error: No home data provided')),
              );
            }
            return CreateRoomScreen(home: home);
          },
        ),
        GetPage(
          name: '/create-rule',
          page: () => const CreateRuleScreen(),
        ),
        GetPage(
          name: '/role-upgrade-requests',
          page: () => const RoleUpgradeRequestsScreen(),
        ),
        GetPage(
          name: '/admin-role-upgrade-requests',
          page: () => const AdminRoleUpgradeRequestsScreen(),
        ),
      ],
    );
  }
}
