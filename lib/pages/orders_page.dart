import 'package:flutter/material.dart';

// Orders page (standalone file).
// Integrate with your existing OrderProvider / services by replacing the mock data and callbacks.

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'All';

  final List<Order> _orders = List<Order>.generate(
    12,
    (i) => Order(
      id: 1000 + i,
      customerName: 'Customer ${i + 1}',
      date: DateTime.now().subtract(Duration(days: i)),
      total: 1500.0 + i * 120,
      status: i % 3 == 0 ? 'Pending' : (i % 3 == 1 ? 'Shipped' : 'Completed'),
      items: [
        OrderItem(name: 'Chair', qty: 2, price: 500.0 + i * 5),
        OrderItem(name: 'Table', qty: 1, price: 700.0 + i * 10),
      ],
    ),
  );

  List<Order> get filteredOrders {
    final q = _searchController.text.trim().toLowerCase();
    return _orders.where((o) {
      if (_statusFilter != 'All' && o.status != _statusFilter) return false;
      if (q.isEmpty) return true;
      return o.id.toString().contains(q) ||
          o.customerName.toLowerCase().contains(q) ||
          o.items.any((it) => it.name.toLowerCase().contains(q));
    }).toList();
  }

  void _changeStatusFilter(String status) {
    setState(() => _statusFilter = status);
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Replace these mock actions with real provider/service calls.
  void _viewOrder(Order o) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.85,
        child: OrderDetailsSheet(order: o),
      ),
    );
  }

  void _markShipped(Order o) {
    // Call your API/provider to update order status. Here we update locally.
    setState(() {
      final idx = _orders.indexWhere((x) => x.id == o.id);
      if (idx != -1) _orders[idx] = _orders[idx].copyWith(status: 'Shipped');
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Order ${o.id} marked as Shipped')));
  }

  void _deleteOrder(Order o) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Order ${o.id}?'),
        content: const Text('This will permanently delete the order.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _orders.removeWhere((x) => x.id == o.id));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Order ${o.id} deleted')));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // trigger refresh from provider/service
              setState(() {});
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search + Add Order
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by order id, customer or item...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to add order page
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Shipped'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Completed'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Orders list
            Expanded(
              child: filteredOrders.isEmpty
                  ? Center(child: Text('No orders found'))
                  : ListView.separated(
                      itemCount: filteredOrders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final o = filteredOrders[index];
                        return OrderCard(
                          order: o,
                          onView: () => _viewOrder(o),
                          onMarkShipped: () => _markShipped(o),
                          onDelete: () => _deleteOrder(o),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final selected = _statusFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => _changeStatusFilter(label),
    );
  }
}

// ---------- Widgets and Models ----------

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onView;
  final VoidCallback onMarkShipped;
  final VoidCallback onDelete;

  const OrderCard({
    Key? key,
    required this.order,
    required this.onView,
    required this.onMarkShipped,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(order.customerName),
                      const SizedBox(height: 6),
                      Text(
                        '${order.items.length} items • ₹${order.total.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      order.status,
                      style: TextStyle(
                        color: _statusColor(order.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(order.date),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onView,
                  icon: const Icon(Icons.visibility),
                  label: const Text('View'),
                ),
                const SizedBox(width: 8),
                if (order.status != 'Shipped')
                  ElevatedButton.icon(
                    onPressed: onMarkShipped,
                    icon: const Icon(Icons.local_shipping),
                    label: const Text('Mark Shipped'),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Pending':
        return Colors.orange;
      case 'Shipped':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

class OrderDetailsSheet extends StatelessWidget {
  final Order order;
  const OrderDetailsSheet({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.id}'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer: ${order.customerName}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Date: ${order.date.toLocal()}'),
            const SizedBox(height: 8),
            Text('Status: ${order.status}'),
            const SizedBox(height: 12),
            const Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: order.items.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, i) {
                  final it = order.items[i];
                  return ListTile(
                    title: Text(it.name),
                    subtitle: Text('Qty: ${it.qty}'),
                    trailing: Text(
                      '₹${(it.price * it.qty).toStringAsFixed(2)}',
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: ₹${order.total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.receipt),
                    label: const Text('Invoice'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Simple models used by this page. Replace with your real models.

class Order {
  final int id;
  final String customerName;
  final DateTime date;
  final double total;
  final String status;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.customerName,
    required this.date,
    required this.total,
    required this.status,
    required this.items,
  });

  Order copyWith({
    int? id,
    String? customerName,
    DateTime? date,
    double? total,
    String? status,
    List<OrderItem>? items,
  }) {
    return Order(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      date: date ?? this.date,
      total: total ?? this.total,
      status: status ?? this.status,
      items: items ?? this.items,
    );
  }
}

class OrderItem {
  final String name;
  final int qty;
  final double price;
  OrderItem({required this.name, required this.qty, required this.price});
}
