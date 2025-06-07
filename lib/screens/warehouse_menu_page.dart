import 'package:flutter/material.dart';

class WarehouseMenuPage extends StatefulWidget {
  const WarehouseMenuPage({Key? key}) : super(key: key);

  @override
  State<WarehouseMenuPage> createState() => _WarehouseMenuPageState();
}

const String backgroundImagePath =
    'https://images.unsplash.com/photo-1650292386081-fed5cb55d588?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
const Color coffeeGreen = Colors.green;

class _WarehouseMenuPageState extends State<WarehouseMenuPage> {
  List<Map<String, dynamic>> items = [
    {
      'name': 'Macchiato',
      'category': 'minuman',
      'price': 20000.00,
      'stock': 71,
      'image': 'https://i.imgur.com/Jc1mR5X.png',
    },
    {
      'name': 'Greek Omelet',
      'category': 'makanan',
      'price': 20000.00,
      'stock': 83,
      'image': 'https://i.imgur.com/Jc1mR5X.png',
    },
    {
      'name': 'Lemon Squash',
      'category': 'minuman',
      'price': 15000.00,
      'stock': 92,
      'image': 'https://i.imgur.com/Jc1mR5X.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Barang Warehouse'),
        centerTitle: true,
        backgroundColor: Colors.brown[900],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(backgroundImagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.7),
              BlendMode.darken,
            ),
          ),
        ),
        child: Column(
          children: [
            // Search and filter bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari barang...',
                        hintStyle: TextStyle(color: Colors.white70),
                        prefixIcon: Icon(Icons.search, color: Colors.white70),
                        filled: true,
                        fillColor: Colors.brown[800]?.withOpacity(0.7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.brown[800]?.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.filter_list, color: Colors.white),
                      onPressed: () {
                        // Filter functionality
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Items count and stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Barang: ${items.length}',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Text(
                    'Stok Total: ${items.fold(0, (sum, item) => sum + (item['stock'] as int))}',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    // Table header
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.brown[800]?.withOpacity(0.7),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Barang',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Kategori',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Harga',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Stok',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Aksi',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Table rows
                    ...items.map((item) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.brown[800]?.withOpacity(0.5),
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.brown[700]!,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16,
                          ),
                          child: Row(
                            children: [
                              // Image and name
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        item['image'],
                                      ),
                                      radius: 20,
                                      backgroundColor: Colors.brown[800],
                                      child: item['image'] == null
                                          ? Text(
                                              item['name'][0],
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            )
                                          : null,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      item['name'],
                                      style: TextStyle(color: Colors.white),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),

                              // Category
                              Expanded(
                                child: Text(
                                  item['category'],
                                  style: TextStyle(color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              // Price
                              Expanded(
                                child: Text(
                                  'Rp${item['price'].toStringAsFixed(2)}',
                                  style: TextStyle(color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              // Stock
                              Expanded(
                                child: Text(
                                  item['stock'].toString(),
                                  style: TextStyle(color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              // Actions
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                      onPressed: () => _editItem(item),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () => _deleteItem(item),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown[900],
        onPressed: _addNewItem,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _addNewItem() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newName = '';
        String newCategory = '';
        double newPrice = 0;
        int newStock = 0;

        return AlertDialog(
          backgroundColor: Colors.brown[800],
          title: const Text(
            'Tambah Barang Baru',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Nama Barang',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) => newName = value,
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) => newCategory = value,
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Harga',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => newPrice = double.tryParse(value) ?? 0,
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Stok',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => newStock = int.tryParse(value) ?? 0,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                if (newName.isNotEmpty && newCategory.isNotEmpty) {
                  setState(() {
                    items.add({
                      'name': newName,
                      'category': newCategory,
                      'price': newPrice,
                      'stock': newStock,
                      'image': 'https://i.imgur.com/Jc1mR5X.png',
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  void _editItem(Map<String, dynamic> item) {
    TextEditingController nameController = TextEditingController(
      text: item['name'],
    );
    TextEditingController categoryController = TextEditingController(
      text: item['category'],
    );
    TextEditingController priceController = TextEditingController(
      text: item['price'].toString(),
    );
    TextEditingController stockController = TextEditingController(
      text: item['stock'].toString(),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.brown[800],
          title: Text(
            'Edit ${item['name']}',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Barang',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: 'Harga',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: stockController,
                  decoration: InputDecoration(
                    labelText: 'Stok',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  item['name'] = nameController.text;
                  item['category'] = categoryController.text;
                  item['price'] = double.tryParse(priceController.text) ?? 0;
                  item['stock'] = int.tryParse(stockController.text) ?? 0;
                });
                Navigator.pop(context);
              },
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.brown[800],
          title: Text(
            'Hapus ${item['name']}?',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus barang ini?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  items.remove(item);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item['name']} telah dihapus'),
                    backgroundColor: Colors.brown[900],
                  ),
                );
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
