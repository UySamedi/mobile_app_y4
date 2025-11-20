import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final AuthController auth = Get.find();
  final TextEditingController fullName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController phone = TextEditingController();

  BoxDecoration box() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    boxShadow: const [
      BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
    ],
  );

  Widget inputField(String hint, IconData icon,
      {bool obscure = false, TextEditingController? controller}) {
    return Container(
      decoration: box(),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          hintText: hint,
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        ),
      ),
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
              Image.asset('assets/images/login_image.png', height: 150),
              const SizedBox(height: 20),
              const Text('Create Account ✨',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Register to get started',
                  style: TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 25),

              inputField("Full Name", Icons.person, controller: fullName),
              const SizedBox(height: 18),
              inputField("Email", Icons.email, controller: email),
              const SizedBox(height: 18),
              inputField("Password", Icons.lock,
                  obscure: true, controller: password),
              const SizedBox(height: 18),
              inputField("Phone Number", Icons.phone, controller: phone),
              const SizedBox(height: 25),

              Obx(() {
                if (auth.message.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Get.snackbar(
                      'Notification',
                      auth.message.value,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.black87,
                      colorText: Colors.white,
                    );
                    auth.clearMessage();
                  });
                }

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: auth.isLoading.value
                        ? null
                        : () {
                      auth.register(
                        fullName.text.trim(),
                        email.text.trim(),
                        password.text.trim(),
                        phone.text.trim(),
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
                        : const Text('Register',
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
                  const Text("Already have an account? "),
                  TextButton(
                    onPressed: () => Get.toNamed('/login'),
                    child: const Text('Login now',
                        style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
