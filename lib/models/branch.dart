class Branch {
  final String id;
  final String name;
  final String address;
  final String district;
  final String city;
  final String distance;
  final double rating;
  final int reviews;
  final List<String> services; // ['delivery', 'pickup', 'dinein']
  final String? logoUrl;

  Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.district,
    required this.city,
    required this.distance,
    this.rating = 0,
    this.reviews = 0,
    this.services = const [],
    this.logoUrl,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    double number(dynamic value, double fallback) =>
        value is num ? value.toDouble() : double.tryParse('$value') ?? fallback;
    int integer(dynamic value, int fallback) =>
        value is num ? value.toInt() : int.tryParse('$value') ?? fallback;
    final rawServices = json['services'] ?? json['serviceTypes'];
    return Branch(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? json['branchName'] ?? '').toString(),
      address: (json['address'] ?? json['addressLine'] ?? '').toString(),
      district: (json['district'] ?? '').toString(),
      city: (json['city'] ?? json['province'] ?? '').toString(),
      distance:
          (json['formattedDistance'] ?? json['distance'] ?? '').toString(),
      rating: number(json['rating'], 0),
      reviews: integer(json['reviews'] ?? json['reviewCount'], 0),
      services: (rawServices as List<dynamic>?)?.map((value) {
            final service = value.toString().toLowerCase();
            if (service.contains('deliver')) return 'delivery';
            if (service.contains('pickup') || service.contains('takeaway')) {
              return 'pickup';
            }
            if (service.contains('dine') || service.contains('eat')) {
              return 'dinein';
            }
            return service;
          }).toList() ??
          const [],
      logoUrl: (json['logoUrl'] ?? json['logo'])?.toString(),
    );
  }
}
