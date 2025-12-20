import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/category.dart' as model;
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product;
  const ProductFormPage({Key? key, this.product}) : super(key: key);

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  late TextEditingController nameCtrl;
  late TextEditingController priceCtrl;
  late TextEditingController descCtrl;
  late TextEditingController youtubeCtrl;
  String? selectedCategoryId;
  List<PlatformFile> picked = [];

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.product?.name ?? '');
    priceCtrl = TextEditingController(text: widget.product?.price ?? '');
    descCtrl = TextEditingController(text: widget.product?.description ?? '');
    youtubeCtrl = TextEditingController(
      text: widget.product?.youtubeUrl.join(', ') ?? '',
    );

    Future.microtask(() => context.read<CategoryProvider>().fetchCategories());
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    descCtrl.dispose();
    youtubeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catProv = context.watch<CategoryProvider>();
    final prodProv = context.read<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceCtrl,
                decoration: const InputDecoration(labelText: 'Price'),
              ),
              const SizedBox(height: 12),
              catProv.loading
                  ? const CircularProgressIndicator()
                  : Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: selectedCategoryId,
                            items: [
                              ...catProv.categories.map(
                                (c) => DropdownMenuItem(
                                  value: c.name?.toString(),
                                  child: Text(c.name),
                                ),
                              ),
                              const DropdownMenuItem(
                                value: '__add_new__',
                                child: Text('➕ Add new category'),
                              ),
                            ],
                            onChanged: (v) async {
                              if (v == '__add_new__') {
                                await _showAddCategoryDialog();
                                return;
                              }
                              setState(() => selectedCategoryId = v);
                            },
                            decoration: const InputDecoration(
                              labelText: 'Category',
                            ),
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: youtubeCtrl,
                decoration: const InputDecoration(
                  labelText: 'YouTube Links (comma separated)',
                  hintText: 'https://youtu.be/abc, https://youtu.be/xyz',
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.attach_file),
                label: const Text('Pick images/videos'),
                onPressed: () async {
                  final res = await FilePicker.platform.pickFiles(
                    allowMultiple: true,
                    withData: true,
                    type: FileType.custom, // MOST IMPORTANT
                    allowedExtensions: [
                      'jpg',
                      'jpeg',
                      'png',
                      'webp',
                      'mp4',
                      'mov',
                      'mkv',
                      'avi',
                    ],
                  );
                  if (res != null && res.files.isNotEmpty)
                    setState(() => picked = res.files);
                },
              ),
              const SizedBox(height: 8),
              if (picked.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: picked.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (c, i) {
                      final pf = picked[i];
                      try {
                        if (pf.bytes != null)
                          return Image.memory(
                            pf.bytes!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          );
                        if (!kIsWeb && pf.path != null)
                          return Image.file(
                            File(pf.path!),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          );
                      } catch (_) {}
                      return SizedBox(
                        width: 100,
                        height: 100,
                        child: Center(child: Text(pf.name)),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final youtubeList = youtubeCtrl.text
    .split(',')
    .map((e) => e.trim())
    .where((e) => e.isNotEmpty)
    .toList();
                      final name = nameCtrl.text.trim();
                      final price = priceCtrl.text.trim();
                      if (name.isEmpty || price.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Name and price required'),
                          ),
                        );
                        return;
                      }
                      final prod = Product(
                        id: widget.product?.id,
                        name: name,
                        category: selectedCategoryId ?? '',
                        price: price,
                        description: descCtrl.text.trim(),
                        images: widget.product?.images ?? [],
                        youtubeUrl: youtubeList,
                      );
                      final ok = await prodProv.addProduct(prod, picked);
                      if (ok) Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok ? 'Product saved' : 'Save failed'),
                        ),
                      );
                    },
                    child: const Text('Save'),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddCategoryDialog() async {
    final ctrl = TextEditingController();
    final prov = context.read<CategoryProvider>();
    final res = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Category name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (res == true) {
      final name = ctrl.text.trim();
      if (name.isEmpty) return;
      final ok = await prov.addCategory(name);
      if (ok) {
        // select the newly added category if present
        final added = prov.categories.firstWhere(
          (e) => e.name == name,
          orElse: () => model.Category(id: null, name: name),
        );
        setState(() => selectedCategoryId = added.id?.toString());
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to add category')));
      }
    }
  }
}
