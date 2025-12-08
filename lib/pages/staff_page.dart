import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/staff_provider.dart';
import '../../models/staff.dart';
import 'staff_detail_page.dart';

class StaffPage extends StatefulWidget {
  const StaffPage({Key? key}) : super(key: key);

  @override
  State<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<StaffProvider>(context, listen: false).fetchStaff();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Staff')),
      body: Consumer<StaffProvider>(
        builder: (_, prov, __) {
          if (prov.loading) return Center(child: CircularProgressIndicator());
          if (prov.staffList.isEmpty)
            return Center(child: Text('No staff found'));
          return ListView.builder(
            itemCount: prov.staffList.length,
            itemBuilder: (_, i) {
              final s = prov.staffList[i];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(s.name),
                  subtitle: Text(s.phone),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StaffDetailPage(staff: s),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showAddDialog(context),
      ),
    );
  }

  void _showAddDialog(BuildContext ctx) {
    final _name = TextEditingController();
    final _phone = TextEditingController();
    final _address = TextEditingController();
    final _salary = TextEditingController();

    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text('Add Staff'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _name,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _phone,
                decoration: InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: _address,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: _salary,
                decoration: InputDecoration(labelText: 'Salary'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final payload = {
                'name': _name.text,
                'phone': _phone.text,
                'address': _address.text,
                'salary': int.tryParse(_salary.text) ?? 0,
              };
              final ok = await Provider.of<StaffProvider>(
                ctx,
                listen: false,
              ).addStaff(payload);
              Navigator.pop(ctx);
              if (!ok)
                ScaffoldMessenger.of(
                  ctx,
                ).showSnackBar(SnackBar(content: Text('Failed to add')));
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
