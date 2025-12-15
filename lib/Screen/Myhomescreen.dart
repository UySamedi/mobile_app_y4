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
        const SnackBar(content: Text('Home deleted successfully'), backgroundColor: Colors.green),
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
      appBar: AppBar(title: const Text('My Homes')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
              : _homes.isEmpty
                  ? const Center(child: Text('You have not created any homes yet.'))
                  : ListView.builder(
                      itemCount: _homes.length,
                      itemBuilder: (context, index) {
                        final home = _homes[index];
                        String? imageUrl;
                        if (home['images'] != null && home['images'].isNotEmpty) {
                          imageUrl = home['images'][0];
                          if (imageUrl!.contains('localhost')) {
                            imageUrl = imageUrl.replaceFirst('localhost', '10.0.2.2');
                          }
                        }

                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: SizedBox(
                              width: 80,
                              height: 80,
                              child: imageUrl != null
                                  ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.broken_image, color: Colors.grey),
                                        );
                                      },
                                    )
                                  : Container(
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.house, color: Colors.grey),
                                    ),
                            ),
                            title: Text(home['name'] ?? 'No name'),
                            subtitle: Text(home['address'] ?? 'No address'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                  onPressed: () async {
                                    final result = await Get.toNamed('/edit-home', arguments: home);
                                    if (result == true) {
                                      _fetchMyHomes();
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () {
                                    _deleteHome(home['id']);
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              Get.toNamed('/detail', arguments: home);
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
