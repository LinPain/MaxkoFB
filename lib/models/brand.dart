import '../services/api_client.dart';

class Brand {
  final String id;
  final String name;
  final String? shortName;
  final String? code;
  final String? logoUrl;
  final String? heroImage;
  final String? description;
  final double rating;
  final int reviews;
  final int menuCount;
  final int branchCount;
  final String estimatedTime;
  final String? badge;

  Brand({
    required this.id,
    required this.name,
    this.shortName,
    this.code,
    this.logoUrl,
    this.heroImage,
    this.description,
    this.rating = 0,
    this.reviews = 0,
    this.menuCount = 0,
    this.branchCount = 0,
    this.estimatedTime = '',
    this.badge,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    double number(dynamic value, double fallback) =>
        value is num ? value.toDouble() : double.tryParse('$value') ?? fallback;
    int integer(dynamic value, int fallback) =>
        value is num ? value.toInt() : int.tryParse('$value') ?? fallback;
    return Brand(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      shortName: (json['shortName'] ?? json['code'])?.toString(),
      code: json['code']?.toString(),
      logoUrl: ApiClient.resolveUrl(json['logoUrl'] ?? json['logo']),
      heroImage: ApiClient.resolveUrl(json['heroImage'] ?? json['image']),
      description: json['description']?.toString(),
      rating: number(json['rating'], 0),
      reviews: integer(json['reviews'] ?? json['reviewCount'], 0),
      menuCount: integer(json['menuCount'], 0),
      branchCount: integer(json['branchCount'], 0),
      estimatedTime: (json['estimatedTime'] ?? '').toString(),
      badge: json['badge']?.toString(),
    );
  }
}
