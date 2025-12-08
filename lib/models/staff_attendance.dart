class StaffAttendance {
  final int id;
  final int staffId;
  final String date;

  final String? checkIn; // New
  final String? checkOut; // New
  final double? totalHours; // New
  final int? dailySalary; // New

  final String status;
  final String? note;
  final String createdAt;

  StaffAttendance({
    required this.id,
    required this.staffId,
    required this.date,
    required this.status,
    required this.createdAt,

    this.checkIn,
    this.checkOut,
    this.totalHours,
    this.dailySalary,
    this.note,
  });

  factory StaffAttendance.fromJson(Map<String, dynamic> j) {
    return StaffAttendance(
      id: int.parse(j['id'].toString()),
      staffId: int.parse(j['staff_id'].toString()),
      date: j['date'] ?? '',

      checkIn: j['check_in'],
      checkOut: j['check_out'],
      totalHours: j['total_hours'] == null
          ? null
          : double.tryParse(j['total_hours'].toString()),

      dailySalary: j['daily_salary'] == null
          ? null
          : int.tryParse(j['daily_salary'].toString()),

      status: j['status'] ?? 'present',
      note: j['note'],

      createdAt: j['created_at'] ?? '',
    );
  }
}
