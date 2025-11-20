class Category {
  final int? id;
  final String name;

  Category({this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name'] ?? '',
    );
  }

  Map<String, String> toFormFields() => {'name': name};
}
