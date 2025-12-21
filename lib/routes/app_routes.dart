import '../pages/addcustomerpage.dart';
import 'package:buisness/pages/customer_details_page.dart';
import 'package:go_router/go_router.dart';

// Existing Imports
import '../pages/home_page.dart';
import '../models/customer.dart';
import '../pages/dashboard.dart';
import '../pages/customers_page.dart';
import '../pages/products/products_page.dart';
import '../pages/products/categories_page.dart';
import '../pages/products/product_form_page.dart';
import '../pages/products/product_details_page.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../pages/orders_page.dart';
import '../pages/quotations_page.dart';

// NEW STAFF MODULE IMPORTS
import '../pages/staff_page.dart';
import '../pages/staff_detail_page.dart';
import '../pages/staff_attendance_page.dart';
import '../pages/staff_ledger_page.dart';
import '../models/staff.dart';

class AppRoutes {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      // HOME
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

      // CUSTOMERS
      GoRoute(
        path: '/customers',
        name: 'customers',
        builder: (context, state) => const CustomersPage(),
      ),

      GoRoute(
        path: '/addcustomer',
        name: 'addcustomer',
        builder: (context, state) => const AddCustomerPage(),
      ),

      GoRoute(
        path: '/customer_details',
        name: 'customer_details',
        builder: (context, state) {
          final customer = state.extra as Customer?;
          return customer == null
              ? const CustomersPage()
              : CustomerDetailsPage(customer: customer);
        },
      ),

      // PRODUCTS
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
          return category == null
              ? const CategoriesPage()
              : ProductsPage(category: category);
        },
      ),

      GoRoute(
        path: '/products/new',
        name: 'product_new',
        builder: (context, state) => const ProductFormPage(),
      ),

      GoRoute(
        path: '/product_details',
        name: 'product_details',
        builder: (context, state) {
          final product = state.extra as Product?;
          return product == null
              ? const CategoriesPage()
              : ProductDetailsPage(product: product);
        },
      ),

      // ORDERS
      GoRoute(
        path: '/orders',
        name: 'orders',
        builder: (context, state) => const OrdersPage(),
      ),

      // QUOTATIONS
      GoRoute(
        path: '/quotations',
        name: 'quotations',
        builder: (context, state) => const QuotationsPage(),
      ),

      // --------------------------------------------------------------
      // 🟢 NEW STAFF ROUTES (Complete Staff Module)
      // --------------------------------------------------------------

      // Staff List page
      GoRoute(
        path: '/staff',
        name: 'staff',
        builder: (context, state) => StaffAttendancePage(),
      ),

      // Staff Detail Page
      GoRoute(
        path: '/staff/detail',
        name: 'staff_detail',
        builder: (context, state) {
          final staff = state.extra as Staff?;
          return staff == null
              ? const StaffPage()
              : StaffDetailPage(staff: staff);
        },
      ),

      // Staff Attendance Page (Manual Time IN/OUT)
      GoRoute(
        path: '/staff/attendance',
        name: 'staff_attendance',
        builder: (context, state) {
          final staffId = state.extra as int?;
          return staffId == null ? const StaffPage() : StaffAttendancePage();
        },
      ),

      // Staff Ledger Page
      GoRoute(
        path: '/staff/ledger',
        name: 'staff_ledger',
        builder: (context, state) {
          final staffId = state.extra as int?;
          return staffId == null
              ? const StaffPage()
              : StaffLedgerPage(staffId: staffId);
        },
      ),
    ],
  );
}
