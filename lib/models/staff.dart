class Staff {
  final int id;
  final String name;
  final String phone;
  final String address;
  final int salary;
  final String createdAt;

  Staff({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.salary,
    required this.createdAt,
  });

  factory Staff.fromJson(Map<String, dynamic> j) => Staff(
    id: int.parse(j['id'].toString()),
    name: j['name'] ?? '',
    phone: j['phone'] ?? '',
    address: j['address'] ?? '',
    salary: int.tryParse(j['salary'].toString()) ?? 0,
    createdAt: j['created_at'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'address': address,
    'salary': salary,
  };
}
