import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../Screen/HomeScreen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final AuthController auth = Get.find();

  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  BoxDecoration box() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Image.asset('assets/images/login_image.png', height: 180),
              const SizedBox(height: 20),
              const Text("Welcome Back 👋",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const Text("Login to continue",
                  style: TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 30),

              // Email
              Container(
                decoration: box(),
                child: TextField(
                  controller: email,
                  decoration: const InputDecoration(
                      hintText: "Email",
                      border: InputBorder.none,
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 14, horizontal: 18)),
                ),
              ),
              const SizedBox(height: 18),

              // Password
              Container(
                decoration: box(),
                child: TextField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(
                      hintText: "Password",
                      border: InputBorder.none,
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 14, horizontal: 18)),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text("Forgot Password?",
                      style: TextStyle(color: Colors.blueAccent)),
                ),
              ),
              const SizedBox(height: 10),

              // LOGIN BUTTON
              Obx(() {
                if (auth.message.isNotEmpty) {
                  // Schedule the snackbar to run after the current frame
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (auth.message.isNotEmpty) { // double-check message
                      Get.snackbar(
                        'Notification',
                        auth.message.value,
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.black87,
                        colorText: Colors.white,
                      );
                      auth.clearMessage();
                    }
                  });
                }

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: auth.isLoading.value
                        ? null
                        : () {
                      auth.login(
                        email.text.trim(),
                        password.text.trim(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: auth.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Login',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                );
              }),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () => Get.toNamed("/register"),
                    child: const Text("Register",
                        style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
