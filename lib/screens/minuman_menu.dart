import 'dart:typed_data'; // Untuk Uint8List
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MinumanMenuPage extends StatefulWidget {
  @override
  State<MinumanMenuPage> createState() => _MinumanMenuPageState();
}

class _MinumanMenuPageState extends State<MinumanMenuPage> {
  final String backgroundImagePath = 'assets/images/background.png';

  final List<Map<String, dynamic>> _menuItems = [
    {
      'name': 'Matcha Latte',
      'description':
          'A smooth and calming Japanese green tea, rich in antioxidants with a slightly bitter, earthy flavor.',
      'price': 'Rp40.000,-',
      'image': 'assets/images/matcha_latte.jpg',
    },
    {
      'name': 'Espresso',
      'description':
          'Bold and intense, this shot of espresso delivers rich flavor and a perfect caffeine kick.',
      'price': 'Rp35.000,-',
      'image': 'assets/images/espresso.jpg',
    },
    {
      'name': 'Lemon Squash',
      'description':
          'Zesty and refreshing, this sparkling lemon drink brings a burst of citrusy freshness in every sip.',
      'price': 'Rp30.000,-',
      'image': 'assets/images/lemon_squash.jpg',
    },
    {
      'name': 'Caramel Macchiato',
      'description':
          'A layered espresso drink with steamed milk, vanilla syrup, and a rich caramel drizzle for a smooth, sweet finish.',
      'price': 'Rp42.000,-',
      'image': 'assets/images/caramel_macchiato.jpg',
    },
    {
      'name': 'Mango Sticky Rice Latte',
      'description':
          'A unique blend of espresso, mango puree, and coconut milk, inspired by the Thai dessert for a creamy tropical twist.',
      'price': 'Rp50.000,-',
      'image': 'assets/images/mango.jpg',
    },
  ];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Uint8List? _selectedImageBytes; // untuk menyimpan gambar upload

  final ImagePicker _picker = ImagePicker();

  void _showAddMenuItemDialog() {
    _nameController.clear();
    _priceController.clear();
    _descriptionController.clear();
    _selectedImageBytes = null;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              title: Center(
                child: Text(
                  'Tambah Menu Baru',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF6B4226),
                  ),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nama Minuman'),
                    ),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.text,
                      decoration:
                          const InputDecoration(labelText: 'Harga (Misal : Rp35.000,-)'),
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Deskripsi'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    if (_selectedImageBytes != null)
                      Image.memory(
                        _selectedImageBytes!,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      )
                    else
                      const Text("Unggah Gambar"),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(78, 92, 54, 1),
                        foregroundColor: Color.fromRGBO(255, 255, 255, 1)
                      ),
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload Photo'),
                      onPressed: () async {
                        final XFile? pickedFile =
                            await _picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          final bytes = await pickedFile.readAsBytes();
                          setStateDialog(() {
                            _selectedImageBytes = bytes;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(78, 92, 54, 1),
                    foregroundColor: Color.fromARGB(255, 255, 255, 255)
                  ),
                  child: const Text('Simpan'),
                  onPressed: () {
                    if (_nameController.text.isEmpty ||
                        _priceController.text.isEmpty ||
                        _descriptionController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                      return;
                    }

                    // Siapkan data baru
                    final newDrink = {
                      'name': _nameController.text,
                      'price': _priceController.text,
                      'description': _descriptionController.text,
                      'image': _selectedImageBytes ??
                          'assets/images/default_drink.jpg', // pakai default jika null
                    };

                    Navigator.of(dialogContext).pop();

                    // Setelah dialog tutup, update state utama
                    setState(() {
                      _menuItems.add(newDrink);
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditMenuItemDialog(int index) {
    final item = _menuItems[index];

    _nameController.text = item['name'];
    _priceController.text = item['price'];
    _descriptionController.text = item['description'];
    _selectedImageBytes = item['image'] is Uint8List ? item['image'] : null;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              title: Center(
                child: Text(
                  'Edit Menu',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF6B4226),
                  ),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nama Minuman'),
                    ),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(labelText: 'Harga'),
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Deskripsi'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    if (_selectedImageBytes != null)
                      Image.memory(
                        _selectedImageBytes!,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      )
                    else
                      const Text("Unggah Gambar"),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(78, 92, 54, 1),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.upload),
                      label: const Text("Ganti Foto"),
                      onPressed: () async {
                        final XFile? pickedFile =
                            await _picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          final bytes = await pickedFile.readAsBytes();
                          setStateDialog(() {
                            _selectedImageBytes = bytes;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(78, 92, 54, 1),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Simpan'),
                  onPressed: () {
                    if (_nameController.text.isEmpty ||
                        _priceController.text.isEmpty ||
                        _descriptionController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Harap isi semua bidang')),
                      );
                      return;
                    }

                    setState(() {
                      _menuItems[index] = {
                        'name': _nameController.text,
                        'price': _priceController.text,
                        'description': _descriptionController.text,
                        'image': _selectedImageBytes ?? item['image'],
                      };
                    });

                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6B4226),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
        onPressed: _showAddMenuItemDialog,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImagePath),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 20),
            Center(
              child: Text(
                "Today's Available Menu",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[900],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _menuItems.length,
                itemBuilder: (context, index) {
                  final item = _menuItems[index];

                  Widget imageWidget;

                  if (item['image'] is String && item['image'].startsWith('assets/')) {
                    imageWidget = CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage(item['image']),
                    );
                  } else if (item['image'] is Uint8List) {
                    imageWidget = CircleAvatar(
                      radius: 35,
                      backgroundImage: MemoryImage(item['image']),
                    );
                  } else {
                    imageWidget = const CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.fastfood, color: Colors.white),
                    );
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.white.withOpacity(0.9),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          imageWidget,
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown[800],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['description'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.brown[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item['price'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => _showEditMenuItemDialog(index),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(170, 134, 155, 57),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.edit,
                                color: const Color.fromARGB(255, 83, 59, 41),
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  


}
