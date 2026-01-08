import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/home_model.dart';
import 'SavedScreen.dart';
import '../controllers/auth_controller.dart';
import '../controllers/home_controller.dart';
import '../services/home_service.dart';

class DetailScreen extends StatefulWidget {
  final Map<String, dynamic> home;

  const DetailScreen({super.key, required this.home});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final AuthController auth = Get.find();
  final HomeController homeCtrl = Get.find();
  Map<String, dynamic>? _homeDetails;
  bool _isLoading = true;
  String _errorMessage = '';

  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  late HomeModel _homeModel;

  @override
  void initState() {
    super.initState();
    _homeModel = HomeModel.fromJson(widget.home);
    _fetchHomeDetails();
  }

  Future<void> _fetchHomeDetails() async {
    final token = auth.token.value;
    final result = await HomeService.getHomeById(widget.home['id'], token);

    if (!mounted) return;

    if (result['success']) {
      setState(() {
        // Handle case where 'data' might be a list or a single object
        if (result['data'] is List && (result['data'] as List).isNotEmpty) {
          _homeDetails = result['data'][0];
        } else {
          _homeDetails = result['data'];
        }
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'] ?? 'Failed to load details';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          onPressed: _fetchHomeDetails,
                          child: const Text('Retry'))
                    ],
                  ),
                )
              : _homeDetails == null
                  ? const Center(child: Text('Could not load home details.'))
                  : CustomScrollView(
                      slivers: [
                        _buildSliverAppBar(),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeader(context),
                                const SizedBox(height: 24),
                                _buildRoomsList(
                                    context,
                                    _homeDetails!['rooms'] as List<dynamic>? ??
                                        []),
                                const SizedBox(height: 40), // Bottom padding
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
      bottomNavigationBar: _buildBottomAction(context),
    );
  }

  Widget _buildSliverAppBar() {
    final List<dynamic> images =
        _homeDetails?['images'] as List<dynamic>? ?? [];

    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.black, size: 20),
            onPressed: () => Get.back(),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: Obx(() {
              final isFavorited = homeCtrl.favoritedHomes.contains(_homeModel);
              return IconButton(
                icon: Icon(isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: isFavorited ? Colors.red : Colors.black, size: 20),
                onPressed: () {
                  homeCtrl.toggleFavorite(_homeModel);
                  Get.to(() => const SavedScreen());
                },
              );
            }),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            if (images.isEmpty)
              _buildPlaceholderImage()
            else
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) =>
                    setState(() => _currentImageIndex = index),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  String url = images[index];
                  if (url.contains('localhost')) {
                    url = url.replaceFirst('localhost', '10.0.2.2');
                  }
                  return Image.network(url, fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholderImage();
                  });
                },
              ),
            // Bottom Indicator Dots
            if (images.length > 1)
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
              ),
            // Page Count Indicator (1 / 7)
            if (images.length > 1)
              Positioned(
                bottom: 30,
                right: 20,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentImageIndex + 1} / ${images.length}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child:
          const Center(child: Icon(Icons.house, size: 80, color: Colors.grey)),
    );
  }

  Widget _buildRoomPlaceholder() {
    return Container(
      height: 150,
      width: double.infinity,
      color: Colors.grey[100],
      child: const Center(
        child: Icon(Icons.bed_outlined, size: 40, color: Colors.grey),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _homeDetails!['name'] ?? 'Unnamed Property',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, size: 18),
            const SizedBox(width: 4),
            Text(
              '4.92 (116 reviews)',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
            ),
          ],
        ),
        const Divider(height: 40),
        // Owner Information Section
        if (_homeDetails!['owner'] != null) ...[
          _buildOwnerInfo(context, _homeDetails!['owner']),
          const Divider(height: 40),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildOwnerInfo(BuildContext context, Map<String, dynamic> owner) {
    final String ownerName = owner['fullName']?.toString() ?? 'Owner';
    final String ownerEmail = owner['email']?.toString() ?? 'No email provided';
    final String? phoneNumber = owner['phoneNumber']?.toString();
    final String ownerInitial = ownerName.isNotEmpty ? ownerName[0].toUpperCase() : 'O';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Entire home',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Hosted by ${ownerName.split(' ')[0]}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.blue.shade50,
              backgroundImage: owner['profileImage'] != null
                  ? NetworkImage(owner['profileImage']
                          .toString()
                          .contains('localhost')
                      ? owner['profileImage']
                          .toString()
                          .replaceFirst('localhost', '10.0.2.2')
                      : owner['profileImage'].toString())
                  : null,
              child: owner['profileImage'] == null
                  ? Text(
                      ownerInitial,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.blue,
                      ),
                    )
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSectionTitle(context, 'Owner Information'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.blue,
                    backgroundImage: owner['profileImage'] != null
                        ? NetworkImage(owner['profileImage']
                                .toString()
                                .contains('localhost')
                            ? owner['profileImage']
                                .toString()
                                .replaceFirst('localhost', '10.0.2.2')
                            : owner['profileImage'].toString())
                        : null,
                    child: owner['profileImage'] == null
                        ? Text(
                            ownerInitial,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ownerName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.email_outlined,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                ownerEmail,
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (phoneNumber != null && phoneNumber.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                phoneNumber,
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoomsList(BuildContext context, List<dynamic> rooms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Available Rooms'),
        const SizedBox(height: 16),
        if (rooms.isEmpty)
          const Center(
              child: Padding(
                  padding: EdgeInsets.all(20), child: Text('No rooms found.')))
        else
          ...rooms.map((room) => _buildRoomCard(context, room)),
      ],
    );
  }

  Widget _buildRoomCard(BuildContext context, Map<String, dynamic> room) {
    String? roomImageUrl;
    final roomImages = room['images'] as List<dynamic>?;
    if (roomImages != null && roomImages.isNotEmpty) {
      roomImageUrl = roomImages[0];
      if (roomImageUrl!.contains('localhost')) {
        roomImageUrl = roomImageUrl.replaceFirst('localhost', '10.0.2.2');
      }
    }

    final bool isAvailable = room['isAvailable'] == true;
    final List<dynamic> rules = room['rules'] as List<dynamic>? ?? [];

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                if (roomImageUrl != null)
                  Image.network(
                    roomImageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildRoomPlaceholder(),
                  )
                else
                  _buildRoomPlaceholder(),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isAvailable ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isAvailable ? 'AVAILABLE' : 'BOOKED',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              room['name'] ?? 'Room',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(height: 4),
                            Text(
                                'Capacity: ${room['capacity'] ?? 'N/A'} Persons',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 14)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${room['price'] ?? '0'}',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ),
                          const Text('/mo',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  if (rules.isNotEmpty) ...[
                    const Divider(height: 24),
                    const Text('Room Rules',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    ...rules.map((ruleData) {
                      final rule = ruleData['rule'];
                      if (rule == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline,
                                size: 14, color: Colors.orange),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${rule['ruleTitle']}: ${rule['ruleDescription']}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    // Removed the bottom "Contact for Inquiry" button — return an empty widget instead
    return const SizedBox.shrink();
  }
}
