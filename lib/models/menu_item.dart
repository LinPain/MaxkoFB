import '../services/api_client.dart';

class MenuItem {
  final String id;
  final String name;
  final String? subtitle;
  final String? description;
  final double price;
  final double? originalPrice;
  final int? discountPercent;
  final String? image;
  final String? brandId;
  final String? brandName;
  final String? categoryId;
  final String? categoryName;
  final bool isBestSeller;
  final bool isAvailable;
  final List<Map<String, dynamic>> sizes;

  MenuItem({
    required this.id,
    required this.name,
    this.subtitle,
    this.description,
    required this.price,
    this.originalPrice,
    this.discountPercent,
    this.image,
    this.brandId,
    this.brandName,
    this.categoryId,
    this.categoryName,
    this.isBestSeller = false,
    this.isAvailable = true,
    this.sizes = const [],
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    final images = json['images'];
    Map<String, dynamic> primaryImage = {};
    if (images is List) {
      for (final rawImage in images) {
        if (rawImage is Map) {
          final imageMap = Map<String, dynamic>.from(rawImage);
          if (primaryImage.isEmpty || imageMap['isPrimary'] == true)
            primaryImage = imageMap;
          if (imageMap['isPrimary'] == true) break;
        }
      }
    }
    final brand = json['brand'] is Map
        ? Map<String, dynamic>.from(json['brand'])
        : <String, dynamic>{};
    final category = json['category'] is Map
        ? Map<String, dynamic>.from(json['category'])
        : <String, dynamic>{};
    final rawPrice =
        json['effectivePrice'] ?? json['price'] ?? json['basePrice'] ?? 0;
    final rawOriginal = json['originalPrice'] ?? json['basePrice'];
    final rawImage = json['image'] ?? json['imageUrl'] ?? primaryImage['url'];
    final rawSizes = json['sizes'];
    return MenuItem(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? json['productName'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? json['shortDescription'])?.toString(),
      description: json['description'],
      price: rawPrice is num
          ? rawPrice.toDouble()
          : double.tryParse('$rawPrice') ?? 0,
      originalPrice: rawOriginal == null
          ? null
          : rawOriginal is num
              ? rawOriginal.toDouble()
              : double.tryParse('$rawOriginal'),
      discountPercent: json['discountPercent'] is num
          ? (json['discountPercent'] as num).toInt()
          : int.tryParse('${json['discountPercent']}'),
      image: ApiClient.resolveUrl(rawImage),
      brandId: (json['brandId'] ?? brand['id'] ?? brand['_id'])?.toString(),
      brandName: (json['brandName'] ?? json['brandShort'] ?? brand['name'])
          ?.toString(),
      categoryId:
          (json['categoryId'] ?? category['id'] ?? category['_id'])?.toString(),
      categoryName: (json['categoryName'] ?? category['name'])?.toString(),
      isBestSeller: json['isBestSeller'] == true || json['bestSeller'] == true,
      isAvailable: json['isAvailable'] != false &&
          json['isActive'] != false &&
          json['available'] != false,
      sizes: rawSizes is List
          ? rawSizes
              .whereType<Map>()
              .map((size) => Map<String, dynamic>.from(size))
              .toList()
          : const [],
    );
  }
}
