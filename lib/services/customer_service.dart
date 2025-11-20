import 'package:dio/dio.dart';

import '../models/customer.dart';

class CustomerService {
  final Dio _dio;
  static const String _base = 'https://palbalaji.tempudo.com/business/api/';

  CustomerService([Dio? dio]) : _dio = dio ?? Dio();

  Future<List<Customer>> fetchCustomers() async {
    final resp = await _dio.get('${_base}customers.php?action=get');
    if (resp.statusCode != 200) throw Exception('Failed to fetch customers');
    final data = resp.data;
    if (data == null || data['status'] != 'success') return [];
    final List items = data['customers'] ?? [];
    return items.map((e) => Customer.fromJson(e)).toList();
  }

  // Backwards-compatible alias used by providers
  Future<List<Customer>> getCustomers() => fetchCustomers();

  Future<Customer?> getCustomer(String id) async {
    final resp = await _dio.get(
      '${_base}customers.php?action=get_single&id=$id',
    );
    if (resp.statusCode != 200) throw Exception('Failed to fetch customer');
    final data = resp.data;
    if (data == null || data['status'] != 'success') return null;
    final customer = data['customer'];
    if (customer == null) return null;
    return Customer.fromJson(customer);
  }

  Future<bool> addCustomer(
    Customer c, {
    List<int>? imageBytes,
    String? fileName,
  }) async {
    final formData = FormData.fromMap({
      'name': c.name,
      'phone': c.phone,
      'address': c.address,
      'gst': c.gst,
      'balance': c.balance,
    });

    if (imageBytes != null && fileName != null) {
      formData.files.add(
        MapEntry(
          'image',
          MultipartFile.fromBytes(imageBytes, filename: fileName),
        ),
      );
    }

    final resp = await _dio.post(
      '${_base}customers.php?action=add',
      data: formData,
    );

    return resp.statusCode == 200 &&
        resp.data != null &&
        resp.data['status'] == 'success';
  }

  Future<bool> updateCustomer(
    int id,
    Customer c, {
    List<int>? imageBytes,
    String? fileName,
  }) async {
    final formData = FormData.fromMap({
      'id': id.toString(),
      'name': c.name,
      'phone': c.phone,
      'address': c.address,
      'gst': c.gst,
      'balance': c.balance,
    });

    if (imageBytes != null && fileName != null) {
      formData.files.add(
        MapEntry(
          'image',
          MultipartFile.fromBytes(imageBytes, filename: fileName),
        ),
      );
    }

    final resp = await _dio.post(
      '${_base}customers.php?action=update',
      data: formData,
    );

    return resp.statusCode == 200 &&
        resp.data != null &&
        resp.data['status'] == 'success';
  }

  Future<bool> deleteCustomer(int id) async {
    final resp = await _dio.post(
      '${_base}customers.php?action=delete',
      data: {'id': id.toString()},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    return resp.statusCode == 200 &&
        resp.data != null &&
        resp.data['status'] == 'success';
  }
}
