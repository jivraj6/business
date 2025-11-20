import 'dart:convert';

class Product {
  final int? id;
  final String name;
  final String category;
  final String price;
  final String description;
  final List<String> images;

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final imageField = json['image_url'];
    List<String> imgs = [];

    try {
      if (imageField != null) {
        if (imageField is String && imageField.isNotEmpty) {
          final parsed = imageField.startsWith('[')
              ? List<String>.from(jsonDecode(imageField))
              : [imageField];
          imgs = parsed.cast<String>().toList();
        } else if (imageField is List) {
          imgs = imageField.map((e) => e.toString()).toList();
        }
      }
    } catch (_) {
      imgs = [];
    }

    return Product(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      price: json['price']?.toString() ?? '',
      description: json['description'] ?? '',
      images: imgs,
    );
  }

  Map<String, String> toFormFields() => {
    'name': name,
    'category': category,
    'price': price,
    'description': description,
  };
}
