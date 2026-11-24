import '../services/api_client.dart';
import 'menu_item.dart';

class Combo {
  const Combo({
    required this.id,
    required this.name,
    required this.price,
    required this.brandIds,
    this.subtitle,
    this.description,
    this.image,
    this.originalPrice,
    this.isAvailable = true,
  });

  final String id;
  final String name;
  final double price;
  final List<String> brandIds;
  final String? subtitle;
  final String? description;
  final String? image;
  final double? originalPrice;
  final bool isAvailable;

  factory Combo.fromJson(Map<String, dynamic> json) {
    double? number(dynamic value) =>
        value is num ? value.toDouble() : double.tryParse('$value');
    final brands = json['brands'];
    final brandIds = brands is List
        ? brands.map((item) => item.toString()).toList()
        : <String>[];
    return Combo(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? json['comboName'] ?? '').toString(),
      price: number(json['price'] ?? json['basePrice']) ?? 0,
      brandIds: brandIds,
      subtitle: (json['subtitle'] ?? json['description'])?.toString(),
      description: json['description']?.toString(),
      image: ApiClient.resolveUrl(json['imageUrl'] ?? json['image']),
      originalPrice: number(json['originalPrice']),
      isAvailable: json['isAvailable'] != false &&
          json['isActive'] != false &&
          json['isDeleted'] != true,
    );
  }

  MenuItem toMenuItem(String fallbackBrandName) => MenuItem(
        id: id,
        name: name,
        subtitle: subtitle,
        description: description,
        price: price,
        originalPrice: originalPrice,
        image: image,
        brandId: brandIds.isEmpty ? '' : brandIds.first,
        brandName: fallbackBrandName,
      );
}
