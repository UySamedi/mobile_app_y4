import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthController auth = Get.find();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController phone = TextEditingController();

  bool _obscure = true;

  InputDecoration _inputDecoration(String hint, IconData icon) => InputDecoration(
    prefixIcon: Icon(icon, color: Colors.blueAccent),
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );

  @override
  void dispose() {
    fullName.dispose();
    email.dispose();
    password.dispose();
    phone.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      auth.register(
        fullName.text.trim(),
        email.text.trim(),
        password.text.trim(),
        phone.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: width > 600 ? 500 : width),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Image.asset('assets/images/login_image.png', height: 140),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Register to get started',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: fullName,
                          decoration: _inputDecoration('Full Name', Icons.person),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your full name' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration('Email', Icons.email),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Please enter your email';
                            final emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
                            if (!emailRegex.hasMatch(v.trim())) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: password,
                          obscureText: _obscure,
                          decoration: _inputDecoration('Password', Icons.lock).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Please enter a password';
                            if (v.length < 6) return 'Password must be at least 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: phone,
                          keyboardType: TextInputType.phone,
                          decoration: _inputDecoration('Phone Number', Icons.phone),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Please enter phone number';
                            if (v.trim().length < 7) return 'Enter a valid phone number';
                            return null;
                          },
                        ),
                        const SizedBox(height: 22),

                        Obx(() {
                          return SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: auth.isLoading.value ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: auth.isLoading.value
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                          );
                        }),
                        
                        // Show messages (error or success)
                        Obx(() {
                          if (auth.message.isNotEmpty) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              final isError = auth.messageType.value == 'error';
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(auth.message.value),
                                  backgroundColor: isError ? Colors.red : Colors.green,
                                ),
                              );
                              // clear after showing
                              auth.clearMessage();
                            });
                          }
                          return const SizedBox.shrink();
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      TextButton(
                        onPressed: () => Get.toNamed('/login'),
                        child: const Text('Login now', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
