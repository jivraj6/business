import 'package:flutter/foundation.dart';

import '../models/category.dart' as model;
import '../services/category_service.dart';
import 'dart:typed_data';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _service = CategoryService();

  List<model.Category> categories = [];
  bool loading = false;
  String? error;

  Future<void> fetchCategories() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      categories = await _service.fetchCategories();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> addCategory({
  required String name,
  required Uint8List imageBytes,
}) async {
  try {
    final ok = await _service.addCategory(
      name: name,
      imageBytes: imageBytes,
    );

    if (ok) {
      await fetchCategories();
    }

    return ok;
  } catch (e) {
    error = e.toString();
    notifyListeners();
    return false;
  }
}
}
