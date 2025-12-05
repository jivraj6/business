import 'package:buisness/models/customer.dart';
import 'package:flutter/material.dart';

class CustomerDetailsPage extends StatefulWidget {
  final Customer customer;

  const CustomerDetailsPage({super.key, required this.customer});

  @override
  State<CustomerDetailsPage> createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.customer;

    return Scaffold(
      appBar: AppBar(
        title: Text(c.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Quotations"),
            Tab(text: "Ledger"),
            Tab(text: "Info"),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQuotationList(c.id!),
          _buildLedgerList(c.id!),
          _buildCustomerInfo(c),
        ],
      ),
    );
  }

  // ---------------------- INFO CARD ----------------------
  Widget _buildCustomerInfo(Customer c) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text("📞  ${c.phone}"),
                const SizedBox(height: 4),
                Text("🏠  ${c.address}"),
                const SizedBox(height: 4),
                Text("🧾  GST: ${c.gst ?? 'N/A'}"),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------- QUOTATIONS TAB ----------------------
  Widget _buildQuotationList(int customerId) {
    return Center(
      child: Text("Quotations filtered by customerId: $customerId"),
    );
  }

  // ---------------------- LEDGER TAB ----------------------
  Widget _buildLedgerList(int customerId) {
    return Center(child: Text("Ledger Entries of customer: $customerId"));
  }
}
