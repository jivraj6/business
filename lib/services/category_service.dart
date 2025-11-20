import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/category.dart';

class CategoryService {
  static const String _base = 'https://palbalaji.tempudo.com/business/api/';

  Future<List<Category>> fetchCategories() async {
    final uri = Uri.parse('${_base}categories.php?action=get');
    final resp = await http.get(uri).timeout(const Duration(seconds: 20));
    if (resp.statusCode != 200) throw Exception('Failed to load categories');
    final data = json.decode(resp.body);
    if (data == null || data['status'] != 'success') return [];
    final List items = data['categories'] ?? [];
    return items.map((e) => Category.fromJson(e)).toList();
  }

  Future<bool> addCategory(String name) async {
    final uri = Uri.parse('${_base}categories.php?action=add');
    final resp = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {'name': name},
        )
        .timeout(const Duration(seconds: 20));
    if (resp.statusCode != 200) return false;
    final data = json.decode(resp.body);
    return data != null && data['status'] == 'success';
  }
}
