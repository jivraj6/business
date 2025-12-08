import 'package:flutter/foundation.dart';
import '../models/staff.dart';
import '../models/staff_attendance.dart';
import '../models/staff_ledger.dart';
import '../services/staff_service.dart';

class StaffProvider with ChangeNotifier {
  List<Staff> staffList = [];
  List<StaffAttendance> attendanceList = [];
  List<StaffLedger> ledgerList = [];
  bool loading = false;

  // Fetch all staff
  Future<void> fetchStaff() async {
    loading = true;
    notifyListeners();

    staffList = await StaffService.getAll();

    loading = false;
    notifyListeners();
  }

  // Fetch attendance list for staff
  Future<void> fetchAttendance(int staffId) async {
    attendanceList = await StaffService.getAttendance(staffId);
    notifyListeners();
  }

  // Fetch ledger for staff
  Future<void> fetchLedger(int staffId) async {
    ledgerList = await StaffService.getLedger(staffId);
    notifyListeners();
  }

  // Add new staff
  Future<bool> addStaff(Map<String, dynamic> payload) async {
    final ok = await StaffService.add(payload);
    if (ok) await fetchStaff();
    return ok;
  }

  // OLD simple attendance (still supported)
  Future<bool> addAttendance(Map<String, dynamic> payload, int staffId) async {
    final ok = await StaffService.addAttendance(payload);
    if (ok) await fetchAttendance(staffId);
    return ok;
  }

  // 🔥 NEW: Time-based attendance (IN / OUT)
  Future<bool> addTimeAttendance(
    Map<String, dynamic> payload,
    int staffId,
  ) async {
    final ok = await StaffService.addTimeAttendance(payload);
    if (ok) await fetchAttendance(staffId); // refresh list
    return ok;
  }
Future<void> fetchStaffAttendance(DateTime date) async {}



Future<void> updateAttendance(
   int staffId,
   DateTime date,
   String time,
   bool isInTime
) async {}
  // Add ledger
  Future<bool> addLedger(Map<String, dynamic> payload, int staffId) async {
    final ok = await StaffService.addLedger(payload);
    if (ok) await fetchLedger(staffId);
    return ok;
  }
}
