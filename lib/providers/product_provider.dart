import 'dart:io';
import 'package:file_picker/file_picker.dart';

import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();

  List<Product> products = [];
  bool loading = false;
  String? error;

  Future<void> fetchProducts() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      products = await _service.fetchProducts();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> addProduct(Product p, List<PlatformFile> files) async {
    try {
      final ok = await _service.addProduct(p, files);
      if (ok) await fetchProducts();
      return ok;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(Product p) async {
    try {
      final ok = await _service.updateProduct(p);
      if (ok) await fetchProducts();
      return ok;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      final ok = await _service.deleteProduct(id);
      if (ok) await fetchProducts();
      return ok;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
