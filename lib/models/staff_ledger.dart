class StaffLedger {
  final int id;
  final int staffId;
  final String type;
  final int amount;
  final String note;
  final String createdAt;

  StaffLedger({
    required this.id,
    required this.staffId,
    required this.type,
    required this.amount,
    required this.note,
    required this.createdAt,
  });

  factory StaffLedger.fromJson(Map<String, dynamic> j) => StaffLedger(
    id: int.parse(j['id'].toString()),
    staffId: int.parse(j['staff_id'].toString()),
    type: j['type'] ?? '',
    amount: int.tryParse(j['amount'].toString()) ?? 0,
    note: j['note'] ?? '',
    createdAt: j['created_at'] ?? '',
  );
}
