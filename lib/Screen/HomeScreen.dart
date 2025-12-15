import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../controllers/auth_controller.dart';
import '../controllers/home_controller.dart';
import '../models/home_model.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final AuthController auth = Get.find();
  final HomeController homeCtrl = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 800 ? 3 : (width > 600 ? 2 : 1);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Discover", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        actions: [
          // Refresh homes list
          IconButton(
            onPressed: () => homeCtrl.fetchHomes(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh homes',
          )
        ],
      ),
      body: SafeArea(
        // Pull-to-refresh: call fetchHomes()
        child: RefreshIndicator(
          onRefresh: () => homeCtrl.fetchHomes(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Greeting + avatar
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Hello,', style: TextStyle(fontSize: 16, color: Colors.black54)),
                          const SizedBox(height: 4),
                          Text(
                            auth.user['fullName'] ?? 'Guest',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Search bar
                TextField(
                  onChanged: (v) {
                    // optional: implement local filtering later
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                    hintText: 'Search homes, addresses...',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Section title
                const Text('Recommended', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // Homes list (grid)
                Obx(() {
                  // Show loading
                  if (homeCtrl.isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  // Show error as snackbar and small message
                  if (homeCtrl.error.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (homeCtrl.error.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(homeCtrl.error.value), backgroundColor: Colors.red),
                        );
                      }
                    });
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(child: Text(homeCtrl.error.value, style: const TextStyle(color: Colors.red))),
                    );
                  }

                  if (homeCtrl.homes.isEmpty) {
                    return const Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(child: Text('No homes found', style: TextStyle(color: Colors.black54))),
                    );
                  }

                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.25,
                    ),
                    itemCount: homeCtrl.homes.length,
                    itemBuilder: (context, index) {
                      final HomeModel home = homeCtrl.homes[index];
                      final imageUrl = home.images.isNotEmpty ? home.images.first : null;
                      final String? displayImageUrl = imageUrl != null
                          ? (Platform.isAndroid ? imageUrl.replaceAll('localhost', '10.0.2.2') : imageUrl)
                          : null;

                      return GestureDetector(
                        onTap: () {
                          Get.toNamed('/detail', arguments: home.toJson());
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: const Color.fromRGBO(0,0,0,0.03), blurRadius: 8, offset: const Offset(0, 4))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // let column take available space inside grid tile
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              // Image with rounded corners: expand to fill available vertical space
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(14),
                                    topRight: Radius.circular(14),
                                  ),
                                  child: displayImageUrl != null
                                      ? SizedBox.expand(
                                          child: Image.network(
                                            displayImageUrl,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            errorBuilder: (context, error, stack) => Container(
                                              color: Colors.grey[200],
                                              child: const Center(child: Icon(Icons.home, color: Colors.grey)),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          color: Colors.grey[200],
                                          child: const Center(child: Icon(Icons.home, color: Colors.grey)),
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(home.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on, size: 14, color: Colors.black45),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(home.address, style: const TextStyle(color: Colors.black54, fontSize: 13), overflow: TextOverflow.ellipsis),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
