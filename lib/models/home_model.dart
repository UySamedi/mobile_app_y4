class HomeModel {
  final int id;
  final int? ownerId;
  final String name;
  final String address;
  final String description;
  final List<String> images;
  final List<dynamic> rooms;

  HomeModel({
    required this.id,
    this.ownerId,
    required this.name,
    required this.address,
    required this.description,
    required this.images,
    this.rooms = const [],
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    // Safely parse rooms - handle null or missing rooms
    List<dynamic> roomsList = [];
    if (json['rooms'] != null) {
      try {
        if (json['rooms'] is List) {
          final roomsData = json['rooms'] as List<dynamic>;
          // Ensure each room is properly converted to Map
          roomsList = roomsData.map((room) {
            if (room is Map) {
              return Map<String, dynamic>.from(room);
            }
            return room;
          }).toList();
        }
      } catch (e) {
        // If parsing fails, use empty list
        roomsList = [];
      }
    }

    return HomeModel(
      id: json['id'] ?? 0,
      ownerId: json['ownerId'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      description: json['description'] ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      rooms: roomsList,
    );
  }

  Map<String, dynamic> toJson() {
    // Convert rooms to a serializable format
    // Only include essential fields to avoid serialization issues with nested objects
    List<Map<String, dynamic>> serializedRooms = [];
    for (var room in rooms) {
      if (room is Map<String, dynamic>) {
        // Create a clean map with only the fields we need
        final cleanRoom = <String, dynamic>{
          'id': room['id'],
          'homeId': room['homeId'],
          'name': room['name'],
          'price': room['price'],
          'capacity': room['capacity'],
          'isAvailable': room['isAvailable'],
          'images': room['images'] is List ? List.from(room['images']) : [],
        };
        serializedRooms.add(cleanRoom);
      }
    }

    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'address': address,
      'description': description,
      'images': images,
      'rooms': serializedRooms,
    };
  }

  // Get minimum room price
  double? get minRoomPrice {
    if (rooms.isEmpty) return null;
    double? minPrice;
    for (var room in rooms) {
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
    return minPrice;
  }
}
