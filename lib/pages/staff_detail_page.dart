import 'package:flutter/material.dart';
import '../../models/staff.dart';
import 'staff_attendance_page.dart';
import 'staff_ledger_page.dart';

class StaffDetailPage extends StatelessWidget {
  final Staff staff;
  const StaffDetailPage({Key? key, required this.staff}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(staff.name)),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                title: Text(staff.name),
                subtitle: Text(
                  'Phone: ${staff.phone}\nSalary: ₹${staff.salary}',
                ),
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.calendar_today),
                    label: Text('Attendance'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StaffAttendancePage(),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.account_balance_wallet),
                    label: Text('Ledger'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StaffLedgerPage(staffId: staff.id),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text('Address:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(staff.address),
            SizedBox(height: 8),
            Text('Joined: ${staff.createdAt}'),
          ],
        ),
      ),
    );
  }
}
