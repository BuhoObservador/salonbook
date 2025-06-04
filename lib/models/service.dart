class Service {
  final String id;
  final String name;
  final String description;
  final double price;
  final int duration;
  final String gender;
  final String? imageUrl;
  final bool isActive;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.gender,
    this.imageUrl,
    required this.isActive,
  });

  factory Service.fromMap(String id, Map<String, dynamic> data) {
    return Service(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      duration: data['duration'] ?? 30,
      gender: data['gender'] ?? 'All',
      imageUrl: data['imageUrl'],
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'gender': gender,
      'imageUrl': imageUrl,
      'isActive': isActive,
    };
  }
}