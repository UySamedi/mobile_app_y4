class HomeModel {
  final int id;
  final int? ownerId;
  final String name;
  final String address;
  final String description;
  final List<String> images;

  HomeModel({
    required this.id,
    this.ownerId,
    required this.name,
    required this.address,
    required this.description,
    required this.images,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      id: json['id'] ?? 0,
      ownerId: json['ownerId'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      description: json['description'] ?? '',
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'address': address,
      'description': description,
      'images': images,
    };
  }
}
