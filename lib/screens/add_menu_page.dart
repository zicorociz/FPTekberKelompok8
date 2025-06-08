import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddMenuPage extends StatefulWidget {
  const AddMenuPage({Key? key}) : super(key: key);

  @override
  State<AddMenuPage> createState() => _AddMenuPageState();
}

class _AddMenuPageState extends State<AddMenuPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();

  void _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
      });
    }
  }

  void _saveMenu() {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua kolom.')),
      );
      return;
    }

    final newDrink = {
      'name': _nameController.text,
      'price': _priceController.text,
      'description': _descriptionController.text,
      'image': _selectedImageBytes,
    };

    Navigator.of(context).pop(newDrink);
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF6B4226);
    final accentColor = const Color.fromRGBO(78, 92, 54, 1);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: const Text(
          'Tambah Menu Baru',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Optional: semi-transparent overlay supaya konten lebih terbaca
          Container(
            color: Colors.white.withOpacity(0.8),
          ),

          // Konten utama
          SingleChildScrollView(
            padding: const EdgeInsets.all(35),
            child: Card(
              color: const Color.fromRGBO(226, 224, 213, 1),
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildTextField(_nameController, 'Nama Minuman'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _priceController,
                      'Harga (cth: Rp 20.000,-)',
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(_descriptionController, 'Deskripsi', maxLines: 4),
                    const SizedBox(height: 20),

                    if (_selectedImageBytes != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          _selectedImageBytes!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      const Text(
                        'Belum ada gambar dipilih',
                        style: TextStyle(fontStyle: FontStyle.italic, fontFamily: 'Poppins'),
                      ),
                    const SizedBox(height: 12),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _pickImage,
                      icon: const Icon(Icons.upload_file, color: Colors.white),
                      label: const Text(
                        'Upload Gambar',
                        style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                      ),
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: _saveMenu,
                        child: const Text(
                          'Simpan Menu',
                          style: TextStyle(
                              fontSize: 16, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontFamily: 'Poppins'),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Poppins'),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF6B4226), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
