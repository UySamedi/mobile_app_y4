import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../models/home_model.dart';
import '../Screen/DetailScreen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeCtrl = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Items'),
      ),
      body: Obx(() {
        if (homeCtrl.favoritedHomes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text('You haven\'t saved any items yet.',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: homeCtrl.favoritedHomes.length,
          itemBuilder: (context, index) {
            final HomeModel home = homeCtrl.favoritedHomes[index];
            String? displayImageUrl;
            if (home.images.isNotEmpty) {
              displayImageUrl = home.images.first;
              if (displayImageUrl.contains('localhost')) {
                displayImageUrl = displayImageUrl.replaceFirst('localhost', '10.0.2.2');
              }
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              child: InkWell(
                onTap: () {
                  Get.to(() => DetailScreen(home: home.toJson()));
                },
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: displayImageUrl != null
                          ? Image.network(
                              displayImageUrl,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => 
                                Container(
                                  height: 180,
                                  color: Colors.grey[200],
                                  child: const Center(child: Icon(Icons.home_work_outlined, size: 40, color: Colors.grey)),
                                ),
                            )
                          : Container(
                              height: 180,
                              color: Colors.grey[200],
                              child: const Center(child: Icon(Icons.home_work_outlined, size: 40, color: Colors.grey)),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            home.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            home.address,
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
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
    );
  }
}
