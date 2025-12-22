import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController auth = Get.find();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  bool _obscure = true;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      auth.login(
        email.text.trim(),
        password.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: width > 600 ? 500 : width),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.home_work_outlined, size: 50, color: Colors.blueAccent),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue to your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 40),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildModernTextField(
                          controller: email,
                          label: 'Email',
                          hint: 'Enter your email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Please enter your email';
                            final emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
                            if (!emailRegex.hasMatch(v.trim())) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildModernTextField(
                          controller: password,
                          label: 'Password',
                          hint: 'Enter your password',
                          icon: Icons.lock_outlined,
                          obscureText: _obscure,
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                            onPressed: () => setState(() => _obscure = !_obscure),
                            color: Colors.grey[600],
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Please enter your password' : null,
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text('Forgot Password?', style: TextStyle(color: Colors.blueAccent, fontSize: 14, fontWeight: FontWeight.w500)),
                          ),
                        ),
                        const SizedBox(height: 32),

                        Obx(() {
                          return SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: auth.isLoading.value ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: auth.isLoading.value
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                              auth.clearMessage();
                            });
                          }
                          return const SizedBox.shrink();
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ", style: TextStyle(color: Colors.grey[600])),
                      TextButton(
                        onPressed: () => Get.toNamed('/register'),
                        child: const Text('Sign Up', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 15)),
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

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.blueAccent, size: 22),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.all(18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
