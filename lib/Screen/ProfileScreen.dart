import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final AuthController auth = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            final user = auth.user;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(36),
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 36),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user['fullName'] ?? 'No name', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(user['role'] ?? 'user', style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Email'),
                    subtitle: Text(user['email'] ?? 'No email'),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: SvgPicture.asset(
                      'assets/icon/home.svg',
                      width: 24,
                      height: 24,
                    ),
                    title: const Text('My Home'),
                    onTap: () {
                      Get.toNamed('/my-home');
                    },
                  ),
                ),
                const SizedBox(height: 8),

                Card(
                  child: ListTile(
                    leading: SvgPicture.asset(
                      'assets/icon/door-open.svg',
                      width: 24, 
                      height: 24,
                    ),
                    title: const Text('Create Home'),
                    onTap: () {
                      Get.toNamed('/create-home');
                    },
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => auth.logout(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                )
              ],
            );
          }),
        ),
      ),
    );
  }
}
