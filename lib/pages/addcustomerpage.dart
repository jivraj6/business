import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../models/customer.dart';
import '../providers/customer_provider.dart';

class AddCustomerPage extends StatefulWidget {
  const AddCustomerPage({Key? key}) : super(key: key);

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _gst = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _balance = TextEditingController();

  Uint8List? _imageBytes;
  String? _imageFileName;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _gst.dispose();
    _balance.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _imageBytes = result.files.first.bytes;
        _imageFileName = result.files.first.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CustomerProvider>(context);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      appBar: AppBar(title: const Text("Add Customer"), centerTitle: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Container(
            width: isMobile ? size.width * 0.95 : size.width * 0.45,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),

            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // -------------------- NAME --------------------
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(
                      labelText: "Customer Name",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Enter customer name" : null,
                  ),
                  const SizedBox(height: 15),

                  // -------------------- PHONE --------------------
                  TextFormField(
                    controller: _phone,
                    decoration: const InputDecoration(
                      labelText: "Phone Number",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Enter phone number";
                      if (v.length < 10) return "Invalid number";
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // -------------------- EMAIL --------------------
                  TextFormField(
                    controller: _gst,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      labelText: "Gst (optional)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // -------------------- BALANCE --------------------
                  TextFormField(
                    controller: _balance,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Opening Balance",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // -------------------- IMAGE PICKER --------------------
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _imageBytes != null
                        ? Stack(
                            children: [
                              Image.memory(_imageBytes!, fit: BoxFit.cover),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    _imageBytes = null;
                                    _imageFileName = null;
                                  }),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.image,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: _pickImage,
                                  icon: const Icon(Icons.upload_file),
                                  label: const Text('Pick Image'),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _address,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Address",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // -------------------- ERROR --------------------
                  if (provider.errorMessage.isNotEmpty)
                    Text(
                      provider.errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),

                  const SizedBox(height: 10),

                  // -------------------- ADD BUTTON --------------------
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final newCustomer = Customer(
                                  name: _name.text.trim(),
                                  phone: _phone.text.trim(),
                                  address: _address.text.trim(),
                                  gst: _gst.text.trim(),
                                  balance: _balance.text.trim(),
                                );

                                bool ok = await provider.addCustomer(
                                  newCustomer,
                                  imageBytes: _imageBytes,
                                  fileName: _imageFileName,
                                );

                                if (ok && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Customer added successfully",
                                      ),
                                    ),
                                  );
                                  Navigator.pop(context);
                                }
                              }
                            },
                            child: const Text("Add Customer"),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
