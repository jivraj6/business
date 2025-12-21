import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../models/category.dart' as model;
import 'package:go_router/go_router.dart';
import '../../providers/product_provider.dart';
import 'product_form_page.dart';

class ProductsPage extends StatefulWidget {
  final model.Category category;
  const ProductsPage({Key? key, required this.category}) : super(key: key);

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProductProvider>().fetchProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Consumer<ProductProvider>(builder: (context, provider, _) {
        return Text(
            "${widget.category.name}(${provider.products.where((p) => p.category.trim().toLowerCase() == widget.category.name.trim().toLowerCase()).length})");
      })),
      floatingActionButton:
          _buildFloatingActionButton(context, widget.category.name),
      body: SafeArea(
        child: Consumer<ProductProvider>(
          builder: (context, provider, _) {
            if (provider.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.error != null) {
              return Center(child: Text('Error: ${provider.error}'));
            }
            final products = provider.products
                .where(
                  (p) =>
                      p.category.trim().toLowerCase() ==
                      widget.category.name.trim().toLowerCase(),
                )
                .toList();
            return LayoutBuilder(
              builder: (context, constraints) {
                bool isDesktop = constraints.maxWidth > 800;
                return Column(
                  children: [
                    _buildHeader(
                        context, provider, isDesktop, widget.category.name),
                    Expanded(
                      child: _buildGrid(
                        context,
                        products,
                        constraints,
                        provider,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ---------- HEADER ----------------
  Widget _buildHeader(BuildContext context, ProductProvider provider,
      bool isDesktop, String? id) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (isDesktop)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductFormPage(catid: id),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text("Add Product"),
            ),
        ],
      ),
    );
  }

  // ---------- GRID ----------------
  Widget _buildGrid(
    BuildContext context,
    List<Product> products,
    BoxConstraints c,
    ProductProvider provider,
  ) {
    int crossAxisCount = 2;
    if (c.maxWidth > 1200)
      crossAxisCount = 5;
    else if (c.maxWidth > 900)
      crossAxisCount = 4;
    else if (c.maxWidth > 600) crossAxisCount = 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.88,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _productCard(products[index], provider);
        },
      ),
    );
  }

  // ---------- PRODUCT CARD ----------------
  Widget _productCard(Product p, ProductProvider provider) {
    final thumb = p.images.isNotEmpty ? p.images.first : null;

    return GestureDetector(
      onTap: () {
        // Use GoRouter to navigate to product details, passing the product via extra
        GoRouter.of(context).pushNamed('product_details', extra: p);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: thumb != null
                    ? Image.network(
                        _absoluteUrl(thumb),
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, size: 40),
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: const Center(child: Icon(Icons.image, size: 40)),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "₹${p.price}",
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    p.category,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditForm(p),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, p, provider),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _absoluteUrl(String url) {
    if (url.startsWith("http")) return url;
    return "https://palbalaji.tempudo.com/business/api/$url";
  }

  // ---------- FLOATING BUTTON (mobile only) ------------
  Widget? _buildFloatingActionButton(BuildContext context, String? id) {
    if (MediaQuery.of(context).size.width > 800) return null;
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductFormPage(catid: id)),
        );
      },
      child: const Icon(Icons.add),
    );
  }

  // ---------- EDIT FORM ----------
  void _showEditForm(Product p) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductFormPage(product: p)),
    );
  }

  // ---------- DELETE ----------
  void _confirmDelete(
    BuildContext context,
    Product p,
    ProductProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Product"),
        content: Text("Are you sure you want to delete ${p.name}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final ok = await provider.deleteProduct(p.id.toString());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(ok ? "Deleted" : "Failed")),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
