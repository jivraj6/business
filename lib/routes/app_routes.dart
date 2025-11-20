import 'package:buisness/models/customer.dart';
import 'package:buisness/pages/addcustomerpage.dart';
import 'package:go_router/go_router.dart';
import '../pages/home_page.dart';
import '../pages/dashboard.dart';
import '../pages/customers_page.dart';
import '../pages/products_page.dart';
import '../pages/product_form_page.dart';
import '../pages/orders_page.dart';
import '../pages/quotations_page.dart';

class AppRoutes {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/customers',
        name: 'customers',
        builder: (context, state) => const CustomersPage(),
      ),
      GoRoute(
        path: '/products',
        name: 'products',
        builder: (context, state) => const ProductsPage(),
      ),
      GoRoute(
        path: '/products/new',
        name: 'product_new',
        builder: (context, state) => const ProductFormPage(),
      ),
      GoRoute(
        path: '/orders',
        name: 'orders',
        builder: (context, state) => const OrdersPage(),
      ),
      GoRoute(
        path: '/quotations',
        name: 'quotations',
        builder: (context, state) => const QuotationsPage(),
      ),
      GoRoute(
        path: '/addcustomer',
        name: 'add',
        builder: (context, state) => const AddCustomerPage(),
      ),

      // GoRoute(
      //   path: '/edit-customer',
      //   builder: (context, state) {
      //     final customer = state.extra as Customer;
      //     return AddCustomerPage(: customer);
      //   },
      // ),
    ],
  );
}
