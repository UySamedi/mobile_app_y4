import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/home_controller.dart';
import '../models/home_model.dart';
import 'ProfileScreen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final AuthController auth = Get.find();
  final HomeController homeCtrl = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (homeCtrl.isLoading.value && homeCtrl.homes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => homeCtrl.fetchHomes(),
          child: CustomScrollView(
            slivers: [
              _buildHeroHeader(context),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                sliver: SliverToBoxAdapter(
                  child: _buildSectionTitle("The most relevant"),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 380,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 20, right: 8),
                    itemCount: homeCtrl.homes.length,
                    itemBuilder: (context, index) =>
                        _buildRelevantCard(context, homeCtrl.homes[index]),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                sliver: SliverToBoxAdapter(
                  child: _buildSectionTitle("Discover new places"),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildDiscoverCard(context, homeCtrl.homes[index]),
                    childCount: homeCtrl.homes.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    final Map<String, dynamic> user = Map<String, dynamic>.from(auth.user);
    final String firstName =
        user['fullName']?.toString().split(' ').first ?? 'Martin';

    return SliverToBoxAdapter(
      child: Stack(
        children: [
          Container(
            height: 400,
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              image: DecorationImage(
                image: NetworkImage(
                    'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?q=80&w=1000&auto=format&fit=crop'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.navigation,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'Norway',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => ProfileScreen());
                        },
                        child: const CircleAvatar(
                          backgroundColor: Colors.white24,
                          child:
                              Icon(Icons.person_outline, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Hey, $firstName! Tell us where you want to go',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Search places',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            Text(
                              'Date range • Number of guests',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildRelevantCard(BuildContext context, HomeModel home) {
    String? displayImageUrl;
    if (home.images.isNotEmpty) {
      displayImageUrl = home.images.first;
      if (displayImageUrl.contains('localhost')) {
        displayImageUrl = displayImageUrl.replaceFirst('localhost', '10.0.2.2');
      }
    }

    return InkWell(
      onTap: () {
        try {
          final homeData = home.toJson();
          Get.toNamed('/detail', arguments: homeData);
        } catch (e) {
          print('Error navigating to detail: $e');
          // Fallback: just pass the ID
          Get.toNamed('/detail', arguments: {'id': home.id});
        }
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: displayImageUrl != null
                      ? Image.network(
                          displayImageUrl,
                          height: 220,
                          width: 300,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildCardPlaceholder(220),
                        )
                      : _buildCardPlaceholder(220),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.black26,
                    child: const Icon(Icons.favorite_border,
                        color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    home.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.black, size: 18),
                    const SizedBox(width: 4),
                    const Text('4.96 (217)',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '4 guests • 2 bedrooms • 2 beds • 1 bathroom',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 8),
            _buildPriceDisplay(home),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoverCard(BuildContext context, HomeModel home) {
    String? displayImageUrl;
    if (home.images.isNotEmpty) {
      displayImageUrl = home.images.first;
      if (displayImageUrl.contains('localhost')) {
        displayImageUrl = displayImageUrl.replaceFirst('localhost', '10.0.2.2');
      }
    }

    return InkWell(
      onTap: () {
        try {
          final homeData = home.toJson();
          Get.toNamed('/detail', arguments: homeData);
        } catch (e) {
          print('Error navigating to detail: $e');
          // Fallback: just pass the ID
          Get.toNamed('/detail', arguments: {'id': home.id});
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: displayImageUrl != null
                  ? Image.network(
                      displayImageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildCardPlaceholder(150),
                    )
                  : _buildCardPlaceholder(150),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            home.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            home.address.split(',').last.trim(),
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDisplay(HomeModel home) {
    // Get minimum room price from available rooms
    double? minPrice;
    try {
      // Use the getter from the model
      minPrice = home.minRoomPrice;

      // Also try direct access as fallback
      if (minPrice == null && home.rooms.isNotEmpty) {
        for (var room in home.rooms) {
          if (room is Map<String, dynamic>) {
            final priceValue = room['price'];
            if (priceValue != null) {
              // Handle both string and numeric prices
              double? price;
              if (priceValue is String) {
                price = double.tryParse(priceValue);
              } else if (priceValue is num) {
                price = priceValue.toDouble();
              }

              if (price != null &&
                  price > 0 &&
                  (minPrice == null || price < minPrice)) {
                minPrice = price;
              }
            }
          }
        }
      }
    } catch (e) {
      // If any error occurs, minPrice will remain null and show default
      print('Error parsing room prices: $e');
    }

    // If no price found, show default
    if (minPrice == null) {
      return RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 16),
          children: [
            const TextSpan(
              text: '\$-- night ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: '• \$-- total',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Calculate total for 3 nights (as shown in the original design)
    final totalPrice = minPrice * 3;

    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black, fontSize: 16),
        children: [
          TextSpan(
            text: '\$${minPrice.toStringAsFixed(0)} night ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: '• \$${totalPrice.toStringAsFixed(0)} total',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildCardPlaceholder(double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.home_work_outlined, size: 40, color: Colors.grey),
      ),
    );
  }
}
