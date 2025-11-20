import 'dart:typed_data';

class Customer {
  final int? id;
  final String name;
  final String phone;
  final String address;
  final String gst;
  final String balance;
  final Uint8List? imageBytes;
  final String? imageUrl;

  Customer({
    this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.gst,
    required this.balance,
    this.imageBytes,
    this.imageUrl,
  });

  // Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'gst': gst,
      'balance': balance,
    };
  }

  // Parse from JSON response
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      gst: json['gst'] ?? '',
      balance: json['balance'] ?? '',
      imageUrl: json['image_url'] as String?,
    );
  }

  // Copy with changes
  Customer copyWith({
    int? id,
    String? name,
    String? phone,
    String? address,
    String? gst,
    String? balance,
    Uint8List? imageBytes,
    String? imageUrl,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      balance: balance ?? this.balance,
      gst: gst ?? this.gst,
      imageBytes: imageBytes ?? this.imageBytes,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
