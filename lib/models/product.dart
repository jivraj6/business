import 'dart:convert';

class Product {
  final int? id;
  final String name;
  final String category;
  final String price;
  final String description;
  final List<String> images;
  final List<String> youtubeUrl;

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.images,
    this.youtubeUrl = const [],
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

    List<String> ytList = [];
    final ytField = json['youtube_url'] ?? json['youtubeUrl'];

    if (ytField is List) {
      ytList = ytField.map((e) => e.toString()).toList();
    } else if (ytField is String && ytField.isNotEmpty) {
      ytList = ytField.startsWith('[')
          ? List<String>.from(jsonDecode(ytField))
          : [ytField];
    }

    return Product(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      price: json['price']?.toString() ?? '',
      description: json['description'] ?? '',
      images: imgs,
      youtubeUrl: ytList,
    );
  }

  Map<String, String> toFormFields() => {
        'name': name,
        'category': category,
        'price': price,
        'description': description,
        if (youtubeUrl != null && youtubeUrl!.isNotEmpty)
          'youtube_url': youtubeUrl.join(','),
      };
}
