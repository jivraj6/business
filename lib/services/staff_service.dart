import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/staff.dart';
import '../models/staff_attendance.dart';
import '../models/staff_ledger.dart';

class StaffService {
  // TODO: change to your domain
  static const String baseUrl =
      "https://palbalaji.tempudo.com/business/api/staff.php";

  static Future<List<Staff>> getAll() async {
    final uri = Uri.parse('$baseUrl?action=get_all');
    final res = await http.get(uri);
    final j = jsonDecode(res.body);
    if (j['status'] == true) {
      return (j['data'] as List).map((e) => Staff.fromJson(e)).toList();
    }
    return [];
  }

  static Future<Staff?> getSingle(int id) async {
    final uri = Uri.parse('$baseUrl?action=get_single&id=$id');
    final res = await http.get(uri);
    final j = jsonDecode(res.body);
    if (j['status'] == true) return Staff.fromJson(j['data']);
    return null;
  }

  static Future<bool> add(Map<String, dynamic> payload) async {
    final uri = Uri.parse('$baseUrl?action=add');
    final res = await http.post(
      uri,
      body: jsonEncode(payload),
      headers: {'Content-Type': 'application/json'},
    );
    final j = jsonDecode(res.body);
    return j['status'] == true;
  }

  static Future<bool> update(int id, Map<String, dynamic> payload) async {
    final uri = Uri.parse('$baseUrl?action=update&id=$id');
    final res = await http.post(
      uri,
      body: jsonEncode(payload),
      headers: {'Content-Type': 'application/json'},
    );
    final j = jsonDecode(res.body);
    return j['status'] == true;
  }

  static Future<bool> delete(int id) async {
    final uri = Uri.parse('$baseUrl?action=delete&id=$id');
    final res = await http.get(uri);
    final j = jsonDecode(res.body);
    return j['status'] == true;
  }

  /* Attendance */
  static Future<bool> addAttendance(Map<String, dynamic> payload) async {
    final uri = Uri.parse('$baseUrl?action=add_attendance');
    final res = await http.post(
      uri,
      body: jsonEncode(payload),
      headers: {'Content-Type': 'application/json'},
    );
    final j = jsonDecode(res.body);
    return j['status'] == true;
  }

  static Future<List<StaffAttendance>> getAttendance(int staffId) async {
    final uri = Uri.parse('$baseUrl?action=get_attendance&staff_id=$staffId');
    final res = await http.get(uri);
    final j = jsonDecode(res.body);
    if (j['status'] == true) {
      return (j['data'] as List)
          .map((e) => StaffAttendance.fromJson(e))
          .toList();
    }
    return [];
  }

  static Future<bool> addTimeAttendance(Map<String, dynamic> payload) async {
  try {
    final uri = Uri.parse('$baseUrl?action=add_time_attendance');

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    final json = jsonDecode(response.body);

    return json['status'] == true;
  } catch (e) {
    print("Attendance error: $e");
    return false;
  }
}


  /* Ledger */
  static Future<bool> addLedger(Map<String, dynamic> payload) async {
    final uri = Uri.parse('$baseUrl?action=add_ledger');
    final res = await http.post(
      uri,
      body: jsonEncode(payload),
      headers: {'Content-Type': 'application/json'},
    );
    final j = jsonDecode(res.body);
    return j['status'] == true;
  }

  static Future<List<StaffLedger>> getLedger(int staffId) async {
    final uri = Uri.parse('$baseUrl?action=get_ledger&staff_id=$staffId');
    final res = await http.get(uri);
    final j = jsonDecode(res.body);
    if (j['status'] == true) {
      return (j['data'] as List).map((e) => StaffLedger.fromJson(e)).toList();
    }
    return [];
  }
}
