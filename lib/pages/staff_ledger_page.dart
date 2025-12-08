import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/staff_provider.dart';
import '../../models/staff_ledger.dart';

class StaffLedgerPage extends StatefulWidget {
  final int staffId;
  const StaffLedgerPage({Key? key, required this.staffId}) : super(key: key);

  @override
  State<StaffLedgerPage> createState() => _StaffLedgerPageState();
}

class _StaffLedgerPageState extends State<StaffLedgerPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<StaffProvider>(
      context,
      listen: false,
    ).fetchLedger(widget.staffId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ledger'),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: () => _showAdd(context)),
        ],
      ),
      body: Consumer<StaffProvider>(
        builder: (_, prov, __) {
          final list = prov.ledgerList;
          if (list.isEmpty) return Center(child: Text('No ledger entries'));
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final l = list[i];
              return Card(
                child: ListTile(
                  title: Text('${l.type.toUpperCase()} • ₹${l.amount}'),
                  subtitle: Text('${l.note}\n${l.createdAt}'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAdd(BuildContext ctx) {
    String type = 'credit';
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text('Add Ledger'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: type,
              items: [
                'credit',
                'debit',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => type = v ?? 'credit',
              decoration: InputDecoration(labelText: 'Type'),
            ),
            TextField(
              controller: amountCtrl,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: noteCtrl,
              decoration: InputDecoration(labelText: 'Note'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final payload = {
                'staff_id': widget.staffId,
                'type': type,
                'amount': int.tryParse(amountCtrl.text) ?? 0,
                'note': noteCtrl.text,
              };
              final ok = await Provider.of<StaffProvider>(
                ctx,
                listen: false,
              ).addLedger(payload, widget.staffId);
              Navigator.pop(ctx);
              if (!ok)
                ScaffoldMessenger.of(
                  ctx,
                ).showSnackBar(SnackBar(content: Text('Failed')));
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
