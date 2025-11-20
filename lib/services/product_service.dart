import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

// no http_parser dependency; send files without explicit content-type

import '../models/product.dart';

class ProductService {
  static const String _base = 'https://palbalaji.tempudo.com/business/api/';

  Future<List<Product>> fetchProducts() async {
    final uri = Uri.parse('${_base}products.php?action=get');
    final resp = await http.get(uri).timeout(const Duration(seconds: 20));
    if (resp.statusCode != 200) throw Exception('Failed to fetch products');
    final data = json.decode(resp.body);
    if (data == null || data['status'] != 'success') return [];
    final List items = data['products'] ?? [];
    return items.map((e) => Product.fromJson(e)).toList();
  }

  Future<bool> addProduct(Product p, List<PlatformFile> files) async {
    final uri = Uri.parse('${_base}products.php?action=add');

    final request = http.MultipartRequest('POST', uri);
    // Add form fields
    request.fields.addAll(p.toFormFields());

    // Attach files under 'files[]' so PHP sees $_FILES['files'] as array
    for (final file in files) {
      // if (file.path != null) {
      //   // device/platform with a file path
      //   final filename = file.path!.split(Platform.pathSeparator).last;
      //   final multipartFile = await http.MultipartFile.fromPath(
      //     'files[]',
      //     file.path!,
      //     filename: filename,
      //   );
      //   request.files.add(multipartFile);
      // }
      if (file.bytes != null) {
        // web: bytes are available on PlatformFile
        final multipartFile = http.MultipartFile.fromBytes(
          'files[]',
          file.bytes!,
          filename: file.name,
        );
        request.files.add(multipartFile);
      }
    }

    final streamed = await request.send().timeout(const Duration(seconds: 60));
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode != 200) return false;
    final data = json.decode(resp.body);
    return data != null && data['status'] == 'success';
  }

  Future<bool> updateProduct(Product p) async {
    final uri = Uri.parse('${_base}products.php?action=update');
    final resp = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {'id': p.id?.toString() ?? '', ...p.toFormFields()},
        )
        .timeout(const Duration(seconds: 20));

    if (resp.statusCode != 200) return false;
    final data = json.decode(resp.body);
    return data != null && data['status'] == 'success';
  }

  Future<bool> deleteProduct(String id) async {
    final uri = Uri.parse('${_base}products.php?action=delete');
    final resp = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {'id': id},
        )
        .timeout(const Duration(seconds: 20));

    if (resp.statusCode != 200) return false;
    final data = json.decode(resp.body);
    return data != null && data['status'] == 'success';
  }
}

// note: we avoid external mime deps and let the server infer file types
