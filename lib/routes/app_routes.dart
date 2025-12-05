import '../pages/addcustomerpage.dart';
import 'package:buisness/pages/customer_details_page.dart';
import 'package:go_router/go_router.dart';
import '../pages/home_page.dart';
import '../models/customer.dart';
import '../pages/dashboard.dart';
import '../pages/customers_page.dart';
import '../pages/products_page.dart';
import '../pages/categories_page.dart';
import '../pages/product_form_page.dart';
import '../pages/product_details_page.dart';
import '../models/product.dart';
import '../models/category.dart';
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
        builder: (context, state) => const CategoriesPage(),
      ),
      GoRoute(
        path: '/products/category',
        name: 'products_by_category',
        builder: (context, state) {
          final category = state.extra as Category?;
          if (category == null) {
            return const CategoriesPage();
          }
          return ProductsPage(category: category);
        },
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
      GoRoute(
        path: '/customer_details',
        name: 'customer_details',
        builder: (context, state) {
          final customer = state.extra as Customer?;
          if (customer == null) {
            // If no customer passed, redirect to customers page
            return const CustomersPage();
          }
          return CustomerDetailsPage(customer: customer);
        },
      ),

      GoRoute(
        path: '/product_details',
        name: 'product_details',
        builder: (context, state) {
          final product = state.extra as Product?;
          if (product == null) {
            return const CategoriesPage();
          }
          return ProductDetailsPage(product: product);
        },
      ),

      // If you need an edit route that passes a Customer object, enable and
      // adjust the page to accept a Customer via constructor and uncomment.
    ],
  );
}
