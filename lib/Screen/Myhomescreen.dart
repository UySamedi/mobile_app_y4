import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../services/home_service.dart';

class Myhomescreen extends StatefulWidget {
  const Myhomescreen({super.key});

  @override
  State<Myhomescreen> createState() => _MyhomescreenState();
}

class _MyhomescreenState extends State<Myhomescreen> {
  final AuthController auth = Get.find();
  List<dynamic> _homes = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchMyHomes();
  }

  Future<void> _fetchMyHomes() async {
    final token = auth.token.value;
    final result = await HomeService.getMyHomes(token);

    if (!mounted) return;

    if (result['success']) {
      setState(() {
        _homes = result['data'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'];
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteHome(int homeId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this home?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final token = auth.token.value;
    final result = await HomeService.deleteHome(homeId, token);

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Home deleted successfully'),
            backgroundColor: Colors.green),
      );
      _fetchMyHomes();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Properties',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage,
                          style: const TextStyle(color: Colors.red)),
                      TextButton(
                        onPressed: _fetchMyHomes,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _homes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home_work_outlined,
                              size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text('You have not created any properties yet.',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 16)),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => Get.toNamed('/create-home'),
                            icon: const Icon(Icons.add),
                            label: const Text('Create Your First Property'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchMyHomes,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _homes.length,
                        itemBuilder: (context, index) {
                          final home = _homes[index];
                          String? imageUrl;
                          if (home['images'] != null &&
                              home['images'].isNotEmpty) {
                            imageUrl = home['images'][0];
                            if (imageUrl!.contains('localhost')) {
                              imageUrl = imageUrl.replaceFirst(
                                  'localhost', '10.0.2.2');
                            }
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Get.toNamed('/detail', arguments: home);
                                    },
                                    child: Stack(
                                      children: [
                                        imageUrl != null
                                            ? Image.network(
                                                imageUrl,
                                                height: 180,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Container(
                                                    height: 180,
                                                    color: Colors.grey[200],
                                                    child: const Center(
                                                        child: Icon(Icons.home,
                                                            size: 50,
                                                            color:
                                                                Colors.grey)),
                                                  );
                                                },
                                              )
                                            : Container(
                                                height: 180,
                                                color: Colors.grey[200],
                                                child: const Center(
                                                    child: Icon(Icons.home,
                                                        size: 50,
                                                        color: Colors.grey)),
                                              ),
                                        Positioned(
                                          top: 12,
                                          right: 12,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(Icons.more_vert,
                                                size: 20),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Get.toNamed('/detail', arguments: home);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            home['name'] ?? 'No name',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on,
                                                  size: 14, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  home['address'] ??
                                                      'No address',
                                                  style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 13),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 0, 16, 16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildActionButton(
                                          icon: Icons.add_circle_outline,
                                          label: 'Add Room',
                                          color: Colors.green,
                                          onTap: () async {
                                            try {
                                              print(
                                                  'Navigating to create-room with home: ${home['id']}');
                                              final result = await Get.toNamed(
                                                '/create-room',
                                                arguments: home,
                                              );
                                              if (result == true) {
                                                _fetchMyHomes();
                                              }
                                            } catch (e) {
                                              print(
                                                  'Error navigating to create-room: $e');
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text('Error: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                        _buildActionButton(
                                          icon: Icons.edit_outlined,
                                          label: 'Edit',
                                          color: Colors.blue,
                                          onTap: () async {
                                            final result = await Get.toNamed(
                                                '/edit-home',
                                                arguments: home);
                                            if (result == true) {
                                              _fetchMyHomes();
                                            }
                                          },
                                        ),
                                        _buildActionButton(
                                          icon: Icons.delete_outline,
                                          label: 'Delete',
                                          color: Colors.red,
                                          onTap: () => _deleteHome(home['id']),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          print('Button tapped: $label'); // Debug print
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
