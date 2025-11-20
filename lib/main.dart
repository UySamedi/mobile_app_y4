// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'Auth/LoginScreen.dart';
// import 'Auth/RegisterScreen.dart';
// import 'Screen/HomeScreen.dart';
// import 'controllers/auth_controller.dart';
//
// void main() {
//   // Initialize AuthController
//   Get.put(AuthController());
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Rental Room App',
//       initialRoute: '/login',
//       getPages: [
//         GetPage(name: '/login', page: () => LoginScreen()),
//         GetPage(name: '/register', page: () => RegisterScreen()),
//         GetPage(name: '/home', page: () => HomeScreen()),
//       ],
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(MyLoginApp());
}

class MyLoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
    );
  }
}
