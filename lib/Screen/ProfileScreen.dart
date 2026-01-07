import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'CreateRuleScreen.dart';
import 'RoleUpgradeRequestsScreen.dart';
import 'AdminRoleUpgradeRequestsScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController auth = Get.find();

  @override
  void initState() {
    super.initState();
    // Fetch full profile when screen loads
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await auth.fetchProfile();
  }

  // Check if user has permission to create listings/rules
  bool _canCreateListing(String? role) {
    if (role == null) return false;
    final roleLower = role.toLowerCase();
    return roleLower == 'admin' || roleLower == 'home_owner';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          final Map<String, dynamic> user =
              Map<String, dynamic>.from(auth.user);
          final String? userRole = user['role']?.toString();
          final bool canCreate = _canCreateListing(userRole);

          return RefreshIndicator(
            onRefresh: _loadProfile,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  _buildProfileHeader(user),
                  const SizedBox(height: 40),
                  _buildSectionTitle('Account Settings'),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    subtitle: user['email']?.toString() ?? 'No email provided',
                    onTap: () {},
                  ),
                  if (user['phoneNumber'] != null)
                    _buildMenuItem(
                      icon: Icons.phone_outlined,
                      title: 'Phone',
                      subtitle: user['phoneNumber']?.toString() ??
                          'No phone provided',
                      onTap: () {},
                    ),
                  // Show Request Role Upgrade only for users with role "user"
                  if (userRole?.toLowerCase() == 'user')
                    _buildMenuItem(
                      icon: Icons.arrow_upward_outlined,
                      title: 'Request Role Upgrade',
                      subtitle: 'Upgrade to home_owner',
                      onTap: () =>
                          _showRoleUpgradeDialog(context, userRole ?? 'user'),
                    ),
                  // Show My Requests for both "user" and "home_owner" to view their request history
                  if (userRole?.toLowerCase() == 'user' ||
                      userRole?.toLowerCase() == 'home_owner')
                    _buildMenuItem(
                      icon: Icons.history_outlined,
                      title: 'My Requests',
                      subtitle: 'View role upgrade requests',
                      onTap: () {
                        try {
                          print('Navigating to role-upgrade-requests...');
                          Get.to(() => const RoleUpgradeRequestsScreen());
                        } catch (e) {
                          print('Error navigating: $e');
                          try {
                            Get.toNamed('/role-upgrade-requests');
                          } catch (e2) {
                            print('Error with named route: $e2');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Navigation error: $e2'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  // Only show My Properties for admin/home_owner
                  if (canCreate)
                    _buildMenuItem(
                      icon: Icons.home_work_outlined,
                      title: 'My Properties',
                      subtitle: 'Manage your listings',
                      onTap: () => Get.toNamed('/my-home'),
                    ),
                  // Only show Create Listing for admin/home_owner
                  if (canCreate)
                    _buildMenuItem(
                      icon: Icons.add_business_outlined,
                      title: 'Create Listing',
                      subtitle: 'Add a new property',
                      onTap: () => Get.toNamed('/create-home'),
                    ),
                  // Only show Create Rule for admin/home_owner
                  if (canCreate)
                    _buildMenuItem(
                      icon: Icons.rule_outlined,
                      title: 'Create Rule',
                      subtitle: 'Add a new rule',
                      onTap: () {
                        // Try direct navigation first, fallback to named route
                        try {
                          Get.to(() => const CreateRuleScreen());
                        } catch (e) {
                          Get.toNamed('/create-rule');
                        }
                      },
                    ),
                  // Show Manage Role Requests only for admin
                  if (userRole?.toLowerCase() == 'admin')
                    _buildMenuItem(
                      icon: Icons.admin_panel_settings_outlined,
                      title: 'Manage Role Requests',
                      subtitle: 'Review and approve/reject requests',
                      onTap: () {
                        try {
                          Get.to(() => const AdminRoleUpgradeRequestsScreen());
                        } catch (e) {
                          Get.toNamed('/admin-role-upgrade-requests');
                        }
                      },
                    ),
                  
                  const SizedBox(height: 40),
                  _buildLogoutButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> user) {
    String fullName = user['fullName']?.toString() ?? '';
    String initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';

    return Column(
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.withOpacity(0.1),
            border: Border.all(color: Colors.blue.withOpacity(0.2), width: 4),
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          fullName.isNotEmpty ? fullName : 'Guest User',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            (user['role'] ?? 'user').toString().toUpperCase(),
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.black87),
          ),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: subtitle != null
              ? Text(subtitle, style: TextStyle(color: Colors.grey[600]))
              : null,
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          // Show success message before logging out
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logout successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
          // Wait a bit for the message to show, then logout
          Future.delayed(const Duration(milliseconds: 500), () {
            auth.logout();
          });
        },
        icon: const Icon(Icons.logout, color: Colors.redAccent),
        label: const Text('Logout',
            style: TextStyle(
                color: Colors.redAccent, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Colors.redAccent),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  void _showRoleUpgradeDialog(BuildContext context, String currentRole) {
    final TextEditingController reasonController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Request Role Upgrade',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Request to upgrade from "user" to "home_owner"',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Reason *',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: reasonController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText:
                            'Explain why you want to upgrade your role...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (reasonController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please provide a reason'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setState(() {
                            isSubmitting = true;
                          });

                          final result = await auth.requestRoleUpgrade(
                            'home_owner',
                            reasonController.text.trim(),
                          );

                          if (!context.mounted) return;

                          Navigator.of(context).pop();

                          if (result['success']) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result['message'] ??
                                      'Role upgrade request submitted successfully',
                                ),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                            // Refresh profile to get updated data
                            await _loadProfile();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result['message'] ??
                                      'Failed to submit role upgrade request',
                                ),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Submit Request'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
