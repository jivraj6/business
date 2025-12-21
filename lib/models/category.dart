class Category {
  final int? id;
  final String name;
  final String? img; // 👈 image url

  Category({
    this.id,
    required this.name,
    this.img,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name'] ?? '',
      img: json['img'], // 👈 API se aayega
    );
  }

  // For old form-urlencoded use (optional)
  Map<String, String> toFormFields() => {
        'name': name,
      };
}
