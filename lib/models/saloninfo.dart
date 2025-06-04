class SalonInfo {
  final String name;
  final String address;
  final String phone;
  final String email;
  final Map<String, dynamic> openHours;
  final String description;
  final List<String> images;

  SalonInfo({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.openHours,
    required this.description,
    required this.images,
  });

  factory SalonInfo.fromMap(Map<String, dynamic> data) {
    return SalonInfo(
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      openHours: data['openHours'] ?? {},
      description: data['description'] ?? '',
      images: List<String>.from(data['images'] ?? []),
    );
  }
}
