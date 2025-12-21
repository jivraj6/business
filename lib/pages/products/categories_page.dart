import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import 'products_page.dart';
import 'dart:html' as html;
import 'dart:typed_data';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<CategoryProvider>().fetchCategories());
  }

  final TextEditingController _categoryController = TextEditingController();
  String? _pickedImage;
  Uint8List? _imageBytes;
  String? _imageName;
  String base = "https://palbalaji.tempudo.com/business/api/";

  void _pickImageWeb(Function(void Function()) setDialogState) {
    final html.FileUploadInputElement uploadInput =
        html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files!.first;
      final reader = html.FileReader();

      reader.readAsArrayBuffer(file);

      reader.onLoadEnd.listen((event) {
        setDialogState(() {
          _imageBytes = reader.result as Uint8List;
        });
      });
    });
  }

  void _openAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                "Add New Category",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // IMAGE PICKER
                    GestureDetector(
                      onTap: () => _pickImageWeb(setDialogState),
                      child: Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: _imageBytes == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add_a_photo, size: 36),
                                  SizedBox(height: 8),
                                  Text("Add Image"),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  _imageBytes!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // CATEGORY NAME
                    TextField(
                      controller: _categoryController,
                      decoration: InputDecoration(
                        labelText: "Category Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ADD BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final name = _categoryController.text.trim();

                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Category name required")),
                            );
                            return;
                          }

                          if (_imageBytes == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Please select an image")),
                            );
                            return;
                          }

                          try {
                            final ok = await context
                                .read<CategoryProvider>()
                                .addCategory(
                                  name: name,
                                  imageBytes: _imageBytes!,
                                );

                            if (ok) {
                              Navigator.pop(context);

                              _categoryController.clear();
                              _imageBytes = null;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text("Category added successfully")),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Failed to add category")),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                        child: const Text(
                          "Add Category",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddCategoryDialog,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Consumer<CategoryProvider>(
          builder: (context, provider, _) {
            if (provider.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.error != null) {
              return Center(child: Text('Error: ${provider.error}'));
            }
            final categories = provider.categories;
            if (categories.isEmpty) {
              return const Center(child: Text('No categories found'));
            }
            // Color palette for cards
            final List<Color> cardColors = [
              Colors.deepPurple,
              Colors.blue,
              Colors.green,
              Colors.orange,
              Colors.pink,
              Colors.teal,
              Colors.red,
              Colors.indigo,
              Colors.brown,
            ];
            final List<IconData> icons = [
              Icons.category,
              Icons.shopping_bag,
              Icons.star,
              Icons.label,
              Icons.widgets,
              Icons.local_offer,
              Icons.apps,
              Icons.dashboard,
              Icons.layers,
            ];
            if (isMobile) {
              // Mobile: single column, big cards
              return ListView.separated(
                padding: const EdgeInsets.all(14),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, idx) {
                  final cat = categories[idx];
                  final color = cardColors[idx % cardColors.length];
                  final icon = icons[idx % icons.length];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductsPage(category: cat),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Container(
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color.withOpacity(0.85),
                              color.withOpacity(0.5),
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 5),
                            Container(
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: cat.img != null && cat.img!.isNotEmpty
                                      ? Image.network(
                                          base + cat.img!,
                                          fit: BoxFit.contain,
                                          width: 90,
                                          height: 90,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                                  Icons.image_not_supported,
                                                  size: 48,
                                                  color: Colors.white70),
                                        )
                                      : const Icon(Icons.image,
                                          size: 48, color: Colors.white70),
                                ),
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Text(
                                cat.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              // Desktop/tablet: grid view
              int crossAxisCount = width > 1200
                  ? 5
                  : width > 900
                      ? 4
                      : 3;
              return Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, idx) {
                    final cat = categories[idx];
                    final color = cardColors[idx % cardColors.length];
                    final icon = icons[idx % icons.length];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductsPage(category: cat),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                color.withOpacity(0.8),
                                color.withOpacity(0.4),
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: cat.img != null &&
                                              cat.img!.isNotEmpty
                                          ? Image.network(
                                              base + cat.img!,
                                              fit: BoxFit.contain,
                                              width: 100,
                                              height: 100,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                      Icons.image_not_supported,
                                                      size: 48,
                                                      color: Colors.white70),
                                            )
                                          : const Icon(Icons.image,
                                              size: 48, color: Colors.white70),
                                    ),
                                  ),
                                ),
                                Text(
                                  cat.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
