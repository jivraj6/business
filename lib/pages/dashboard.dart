import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<_DashboardItem> _items = [
    _DashboardItem(
      title: 'Customers',
      icon: Icons.people,
      color: Colors.blue,
      count: 0,
    ),
    _DashboardItem(
      title: 'Products',
      icon: Icons.shopping_bag,
      color: Colors.green,
      count: 0,
    ),
    _DashboardItem(
      title: 'Orders',
      icon: Icons.receipt,
      color: Colors.orange,
      count: 0,
    ),
    _DashboardItem(
      title: 'Quotations',
      icon: Icons.description,
      color: Colors.purple,
      count: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Dashboard',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return ListView(
      children: _items.asMap().entries.map((entry) {
        int index = entry.key;
        _DashboardItem item = entry.value;
        return _buildDashboardCard(item, index);
      }).toList(),
    );
  }

  Widget _buildDesktopLayout() {
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 1.5,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: _items.asMap().entries.map((entry) {
        int index = entry.key;
        _DashboardItem item = entry.value;
        return _buildDashboardCard(item, index);
      }).toList(),
    );
  }

  Widget _buildDashboardCard(_DashboardItem item, int index) {
    return GestureDetector(
      onTap: () => _navigateToSection(item.title),
      child: Card(
        elevation: 2,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                item.color.withOpacity(0.7),
                item.color.withOpacity(0.3),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${item.count} items',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                    Icon(item.icon, size: 40, color: Colors.white70),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'View Details →',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToSection(String section) {
    String route = '';
    switch (section.toLowerCase()) {
      case 'customers':
        route = '/customers';
        break;
      case 'products':
        route = '/products';
        break;
      case 'orders':
        route = '/orders';
        break;
      case 'Quotations':
        route = '/quotations';
        break;
    }
    if (route.isNotEmpty) {
      context.push(route);
    }
  }
}

class _DashboardItem {
  final String title;
  final IconData icon;
  final Color color;
  final int count;

  _DashboardItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.count,
  });
}
