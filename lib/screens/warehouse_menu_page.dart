import 'package:flutter/material.dart';

// --- MODEL CLASS (letakkan di atas atau di file terpisah) ---
class WarehouseItem {
  String id;
  String name;
  String category;
  double price;
  int stock;
  String image;

  WarehouseItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.image,
  });
}

// --- MAIN WIDGET ---
class WarehouseMenuPage extends StatefulWidget {
  const WarehouseMenuPage({Key? key}) : super(key: key);

  @override
  State<WarehouseMenuPage> createState() => _WarehouseMenuPageState();
}

class _WarehouseMenuPageState extends State<WarehouseMenuPage> {
  final String backgroundImagePath =
      'assets/images/background.png'; // Pastikan path ini benar

  // Menggunakan Model Class untuk type-safety
  final List<WarehouseItem> _allItems = [
    WarehouseItem(
      id: '1',
      name: 'Bubuk Kopi Arabika',
      category: 'bubuk kopi',
      price: 20000.00,
      stock: 71,
      image: 'https://i.imgur.com/Jc1mR5X.png',
    ),
    WarehouseItem(
      id: '2',
      name: 'Tepung Terigu',
      category: 'bahan baku',
      price: 20000.00,
      stock: 83,
      image: 'https://i.imgur.com/Jc1mR5X.png',
    ),
    WarehouseItem(
      id: '3',
      name: 'Kopi Susu Bubuk',
      category: 'minuman',
      price: 15000.00,
      stock: 92,
      image: 'https://i.imgur.com/Jc1mR5X.png',
    ),
  ];

  // List untuk menampilkan hasil filter/pencarian
  List<WarehouseItem> _filteredItems = [];

  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = [
    'bahan baku',
    'makanan',
    'minuman',
    'bubuk kopi',
  ];

  @override
  void initState() {
    super.initState();
    _filteredItems = _allItems;
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterItems);
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = _allItems.where((item) {
        return item.name.toLowerCase().contains(query);
      }).toList();
    });
  }

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
            // PERBAIKAN: Gunakan AssetImage untuk aset lokal
            image: AssetImage(backgroundImagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.7),
              BlendMode.darken,
            ),
          ),
        ),
        child: Column(
          children: [_buildSearchBar(), _buildStats(), _buildItemsTable()],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown[900],
        onPressed:
            _showItemDialog, // Memanggil fungsi dialog untuk menambah item
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // WIDGET BUILDER UNTUK SEARCH BAR
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari barang...',
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white70),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.white70),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
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
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET BUILDER UNTUK STATISTIK
  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Barang: ${_filteredItems.length}',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          Text(
            'Stok Total: ${_filteredItems.fold<int>(0, (sum, item) => sum + item.stock)}',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // WIDGET BUILDER UNTUK TABEL ITEM
  Widget _buildItemsTable() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _filteredItems.isEmpty
            ? Center(
                child: Text(
                  "Barang tidak ditemukan.",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              )
            : ListView(
                children: [
                  _buildTableHeader(),
                  // Menggunakan ListView.builder untuk performa yang lebih baik
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return _buildTableRow(item);
                    },
                  ),
                ],
              ),
      ),
    );
  }

  // WIDGET BUILDER UNTUK HEADER TABEL
  Widget _buildTableHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.brown[800]?.withOpacity(0.7),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Barang',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Kategori',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Harga',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Stok',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Aksi',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET BUILDER UNTUK BARIS TABEL
  Widget _buildTableRow(WarehouseItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.brown[800]?.withOpacity(0.5),
        border: Border(bottom: BorderSide(color: Colors.brown[700]!, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(item.image),
                  radius: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(item.category, style: TextStyle(color: Colors.white)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Rp${item.price.toStringAsFixed(0)}',
              style: TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              item.stock.toString(),
              style: TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                  onPressed: () => _showItemDialog(item: item),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.redAccent, size: 20),
                  onPressed: () => _deleteItem(item),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // FUNGSI UNTUK MENAMPILKAN DIALOG TAMBAH/EDIT
  void _showItemDialog({WarehouseItem? item}) {
    final _formKey = GlobalKey<FormState>();
    bool isEditing = item != null;

    // Controllers untuk form
    final nameController = TextEditingController(text: item?.name ?? '');
    final priceController = TextEditingController(
      text: item?.price.toStringAsFixed(0) ?? '',
    );
    final stockController = TextEditingController(
      text: item?.stock.toString() ?? '',
    );

    // State untuk Dropdown
    String selectedCategory = item?.category ?? _categories.first;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // StatefulBuilder diperlukan agar Dropdown bisa di-update di dalam dialog
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              backgroundColor: Colors.brown[800],
              title: Text(
                isEditing ? 'Edit Barang' : 'Tambah Barang Baru',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Nama Barang',
                          labelStyle: TextStyle(color: Colors.white70),
                        ),
                        style: TextStyle(color: Colors.white),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Nama tidak boleh kosong'
                            : null,
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Kategori',
                          labelStyle: TextStyle(color: Colors.white70),
                        ),
                        dropdownColor: Colors.brown[700],
                        iconEnabledColor: Colors.white,
                        items: _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(
                              category,
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            dialogSetState(() => selectedCategory = value!),
                        style: TextStyle(color: Colors.white),
                      ),
                      TextFormField(
                        controller: priceController,
                        decoration: InputDecoration(
                          labelText: 'Harga',
                          labelStyle: TextStyle(color: Colors.white70),
                        ),
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Harga tidak boleh kosong'
                            : null,
                      ),
                      TextFormField(
                        controller: stockController,
                        decoration: InputDecoration(
                          labelText: 'Stok',
                          labelStyle: TextStyle(color: Colors.white70),
                        ),
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Stok tidak boleh kosong'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Batal', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (isEditing) {
                        // Logika Update
                        setState(() {
                          item.name = nameController.text;
                          item.category = selectedCategory;
                          item.price =
                              double.tryParse(priceController.text) ?? 0;
                          item.stock = int.tryParse(stockController.text) ?? 0;
                        });
                      } else {
                        // Logika Create
                        setState(() {
                          _allItems.add(
                            WarehouseItem(
                              id: DateTime.now().millisecondsSinceEpoch
                                  .toString(),
                              name: nameController.text,
                              category: selectedCategory,
                              price: double.tryParse(priceController.text) ?? 0,
                              stock: int.tryParse(stockController.text) ?? 0,
                              image:
                                  'https://i.imgur.com/Jc1mR5X.png', // Default image
                            ),
                          );
                        });
                      }
                      _filterItems(); // Refresh list
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // FUNGSI UNTUK MENGHAPUS ITEM
  void _deleteItem(WarehouseItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.brown[800],
          title: Text(
            'Hapus ${item.name}?',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus barang ini?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                setState(() {
                  _allItems.removeWhere((i) => i.id == item.id);
                  _filterItems(); // Refresh list
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item.name} telah dihapus'),
                    backgroundColor: Colors.brown[900],
                  ),
                );
              },
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}
