import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/customer_service.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerService _service = CustomerService();

  List<Customer> _customers = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Fetch all customers
  Future<void> fetchCustomers() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _customers = await _service.getCustomers();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add customer
  Future<bool> addCustomer(
    Customer customer, {
    List<int>? imageBytes,
    String? fileName,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _service.addCustomer(
        customer,
        imageBytes: imageBytes,
        fileName: fileName,
      );
      await fetchCustomers(); // Refresh list
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update customer
  Future<bool> updateCustomer(
    int id,
    Customer customer, {
    List<int>? imageBytes,
    String? fileName,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _service.updateCustomer(
        id,
        customer,
        imageBytes: imageBytes,
        fileName: fileName,
      );
      await fetchCustomers(); // Refresh list
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete customer
  Future<bool> deleteCustomer(int id) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _service.deleteCustomer(id);
      await fetchCustomers(); // Refresh list
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
