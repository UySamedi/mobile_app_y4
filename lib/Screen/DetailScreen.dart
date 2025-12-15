import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../services/home_service.dart';

class DetailScreen extends StatefulWidget {
  final Map<String, dynamic> home;

  const DetailScreen({super.key, required this.home});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final AuthController auth = Get.find();
  Map<String, dynamic>? _homeDetails;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchHomeDetails();
  }

  Future<void> _fetchHomeDetails() async {
    final token = auth.token.value;
    final result = await HomeService.getHomeById(widget.home['id'], token);

    if (!mounted) return;

    if (result['success']) {
      setState(() {
        _homeDetails = result['data'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_homeDetails?['name'] ?? widget.home['name'] ?? 'Home Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
              : _homeDetails == null
                  ? const Center(child: Text('Could not load home details.'))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImage(),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _homeDetails!['name'] ?? 'No Name',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _homeDetails!['address'] ?? 'No Address',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _homeDetails!['description'] ?? 'No Description',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const Divider(height: 32),
                                if (_homeDetails!['owner'] != null)
                                  _buildOwnerInfo(context, _homeDetails!['owner']),
                                const Divider(height: 32),
                                _buildRoomsList(context, _homeDetails!['rooms'] as List<dynamic>? ?? []),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildImage() {
    String? imageUrl;
    final images = _homeDetails?['images'] as List<dynamic>?;
    if (images != null && images.isNotEmpty) {
      imageUrl = images[0];
      if (imageUrl!.contains('localhost')) {
        imageUrl = imageUrl.replaceFirst('localhost', '10.0.2.2');
      }
    }

    if (imageUrl == null) {
      return Container(
        height: 250,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.house, size: 50, color: Colors.grey),
        ),
      );
    }

    return Image.network(
      imageUrl,
      width: double.infinity,
      height: 250,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 250,
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _buildOwnerInfo(BuildContext context, Map<String, dynamic> owner) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Owner Information', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text(owner['fullName'] ?? 'No Name'),
            subtitle: Text(owner['email'] ?? 'No Email'),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomsList(BuildContext context, List<dynamic> rooms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rooms', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (rooms.isEmpty)
          const Center(child: Text('No rooms available.'))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              String? roomImageUrl;
              final roomImages = room['images'] as List<dynamic>?;
              if (roomImages != null && roomImages.isNotEmpty) {
                roomImageUrl = roomImages[0];
                if (roomImageUrl!.contains('localhost')) {
                  roomImageUrl = roomImageUrl.replaceFirst('localhost', '10.0.2.2');
                }
              }

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: roomImageUrl != null
                      ? Image.network(roomImageUrl, width: 80, height: 80, fit: BoxFit.cover)
                      : Container(width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.house, color: Colors.grey)),
                  title: Text(room['name'] ?? 'No Name'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Price: \$${room['price'] ?? 'N/A'}'),
                      Text('Capacity: ${room['capacity'] ?? 'N/A'}'),
                    ],
                  ),
                  trailing: Text(
                    room['isAvailable'] == true ? 'Available' : 'Unavailable',
                    style: TextStyle(
                      color: room['isAvailable'] == true ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
