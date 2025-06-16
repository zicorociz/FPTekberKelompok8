import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Untuk Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Untuk Autentikasi Firebase

// --- MODEL CLASS WarehouseItem (Sekarang berada di file yang sama) ---
class WarehouseItem {
  String id; // Ini akan menjadi Document ID dari Firestore
  String name;
  String category;
  double price;
  int stock;
  String image; // URL gambar

  WarehouseItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.image,
  });

  // Factory constructor untuk membuat WarehouseItem dari Firestore DocumentSnapshot
  factory WarehouseItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WarehouseItem(
      id: doc.id, // Menggunakan Document ID Firestore sebagai id item
      name: data['name'] as String,
      category: data['category'] as String,
      // Pastikan konversi tipe data aman (data bisa jadi int atau double dari Firestore)
      price: (data['price'] as num).toDouble(),
      stock: (data['stock'] as num).toInt(),
      image: data['image'] as String,
    );
  }

  // Metode untuk mengkonversi WarehouseItem menjadi Map<String, dynamic> untuk Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'image': image,
    };
  }
}

// --- MAIN WIDGET ---
class WarehouseMenuPage extends StatefulWidget {
  const WarehouseMenuPage({Key? key}) : super(key: key);

  @override
  State<WarehouseMenuPage> createState() => _WarehouseMenuPageState();
}

class _WarehouseMenuPageState extends State<WarehouseMenuPage> {
  // Ganti dengan URL gambar latar belakang yang sesuai untuk NetworkImage
  final String backgroundImagePath =
      'assets/images/background.png'; // Ganti dengan path gambar yang sesuai

  Stream<QuerySnapshot>? _warehouseItemsStream; // Stream dari Firestore
  String? _userId; // ID pengguna yang terautentikasi
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instance Firebase Auth

  // List untuk menyimpan data item dari Firestore setelah di-map
  List<WarehouseItem> _allItemsFromFirestore = []; // Nama diubah agar jelas sumbernya
  // List untuk menampilkan hasil filter/pencarian
  List<WarehouseItem> _filteredItems = [];

  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = [
    'alat makan',
    'bahan baku',
    'packaging',
  ];

  String? _selectedFilterCategory; // Kategori yang dipilih untuk filter

  // Loading state untuk operasi Firebase
  bool _isLoading = true; // Untuk loading awal data
  bool _isSavingOrDeleting = false; // Untuk operasi tambah/edit/hapus

  @override
  void initState() {
    super.initState();
    _initializeFirebaseAndAuth();
    // Panggil _applyFilter saat searchController berubah teks
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilter); // Ubah dari _filterItems
    _searchController.dispose();
    super.dispose();
  }

  // Inisialisasi Firebase dan Autentikasi
  Future<void> _initializeFirebaseAndAuth() async {
    final String appId = const String.fromEnvironment('FLUTTER_APP_ID', defaultValue: 'default-app-id');

    _auth.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _userId = user?.uid ?? 'anonymous_user';
          // BARIS INI DIHAPUS: print("ID Pengguna Saat Ini (Warehouse): $_userId");

          _warehouseItemsStream = FirebaseFirestore.instance
              .collection('artifacts')
              .doc(appId)
              .collection('public')
              .doc('data')
              .collection('warehouse') // UBAH DI SINI: Nama koleksi menjadi 'warehouse' (lowercase)
              .orderBy('name', descending: false) // Urutkan berdasarkan nama
              .snapshots();
          _isLoading = false;
        });
      }
    });
  }

  // Fungsi yang menerapkan filter ke _allItemsFromFirestore dan memperbarui _filteredItems
  void _applyFilter() { // Nama diubah menjadi _applyFilter
    final query = _searchController.text.toLowerCase();
    _filteredItems = _allItemsFromFirestore.where((item) {
      final matchesName = item.name.toLowerCase().contains(query);
      final matchesCategory = _selectedFilterCategory == null ||
          _selectedFilterCategory == 'Kategori' ||
          item.category.toLowerCase() == _selectedFilterCategory!.toLowerCase();
      return matchesName && matchesCategory;
    }).toList();
  }

  // Fungsi untuk menambah item baru ke Firestore
  Future<void> _addItemToFirestore(WarehouseItem item) async {
    setState(() { _isSavingOrDeleting = true; });
    final String appId = const String.fromEnvironment('FLUTTER_APP_ID', defaultValue: 'default-app-id');
    try {
      await FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('data')
          .collection('warehouse') // UBAH DI SINI: Nama koleksi menjadi 'warehouse' (lowercase)
          .add(item.toFirestore()); // Menggunakan toFirestore() dari model
      _showMessage('Barang "${item.name}" berhasil ditambahkan!');
    } catch (e) {
      print("Error menambahkan barang: $e");
      _showMessage('Gagal menambahkan barang: $e');
    } finally {
      setState(() { _isSavingOrDeleting = false; });
    }
  }

  // Fungsi untuk mengupdate item di Firestore
  Future<void> _updateItemInFirestore(WarehouseItem item) async {
    setState(() { _isSavingOrDeleting = true; });
    final String appId = const String.fromEnvironment('FLUTTER_APP_ID', defaultValue: 'default-app-id');
    try {
      await FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('data')
          .collection('warehouse') // UBAH DI SINI: Nama koleksi menjadi 'warehouse' (lowercase)
          .doc(item.id) // Menggunakan Document ID untuk update
          .update(item.toFirestore());
      _showMessage('Barang "${item.name}" berhasil diperbarui!');
    } catch (e) {
      print("Error memperbarui barang: $e");
      _showMessage('Gagal memperbarui barang: $e');
    } finally {
      setState(() { _isSavingOrDeleting = false; });
    }
  }

  // Fungsi untuk menghapus item dari Firestore
  Future<void> _deleteItemFromFirestore(WarehouseItem item) async {
    setState(() { _isSavingOrDeleting = true; });
    final String appId = const String.fromEnvironment('FLUTTER_APP_ID', defaultValue: 'default-app-id');
    try {
      await FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('data')
          .collection('warehouse') // UBAH DI SINI: Nama koleksi menjadi 'warehouse' (lowercase)
          .doc(item.id)
          .delete();
      _showMessage('Barang "${item.name}" telah dihapus!');
    } catch (e) {
      print("Error menghapus barang: $e");
      _showMessage('Gagal menghapus barang: $e');
    } finally {
      setState(() { _isSavingOrDeleting = false; });
    }
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.brown[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(10),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null || _isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Daftar Barang Warehouse')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Barang Warehouse'),
        centerTitle: true,
        backgroundColor: Colors.brown[900],
        elevation: 0,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(backgroundImagePath), // Gunakan NetworkImage untuk URL
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.7),
              BlendMode.darken,
            ),
          ),
        ),
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildItemsTable()), // _buildItemsTable sekarang juga akan menampilkan stats
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown[600],
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        onPressed: _isSavingOrDeleting ? null : () => _showItemDialog(), // Panggil tanpa item untuk tambah baru
        child: _isSavingOrDeleting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.add_shopping_cart), // Ikon yang lebih relevan
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
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white70),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: Colors.brown[800]?.withOpacity(0.7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder( // Border saat aktif tapi tidak fokus
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.brown[700]!, width: 1),
                ),
                focusedBorder: OutlineInputBorder( // Border saat fokus
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.brown[300]!, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.brown[800]?.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.brown[700]!, width: 1),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFilterCategory,
                hint: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Icon(Icons.filter_list, color: Colors.white),
                ),
                dropdownColor: Colors.brown[800],
                iconEnabledColor: Colors.white,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                items: [
                  const DropdownMenuItem(
                    value: null, // Nilai null untuk "Semua Kategori"
                    child: Text('Kategori', style: TextStyle(color: Colors.white)),
                  ),
                  ..._categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category, style: const TextStyle(color: Colors.white)),
                    );
                  }),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedFilterCategory = newValue;
                    _applyFilter(); // Panggil filter ulang saat kategori berubah
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET BUILDER UNTUK STATISTIK (Dinamis, menerima daftar item)
  Widget _buildStatsWidget() { // Diubah nama dari _buildStats
    int totalStock = _filteredItems.fold<int>(0, (sum, item) => sum + item.stock);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        color: Colors.brown[700]?.withOpacity(0.8),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('Total Barang', _filteredItems.length.toString(), Icons.inventory_2),
              _buildStatColumn('Stok Total', totalStock.toString(), Icons.storage),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // WIDGET BUILDER UNTUK TABEL ITEM (Sekarang juga mencakup statistik)
  Widget _buildItemsTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: _warehouseItemsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Konversi snapshot data ke List<WarehouseItem>
        _allItemsFromFirestore = snapshot.data!.docs
            .map((doc) => WarehouseItem.fromFirestore(doc))
            .toList();
        
        // Panggil _applyFilter di sini untuk memperbarui _filteredItems
        // karena _allItemsFromFirestore baru saja diperbarui
        _applyFilter(); 

        if (_filteredItems.isEmpty) {
          return const Center(
            child: Text(
              "Barang tidak ditemukan atau stok kosong.",
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          );
        }

        return Column( // Ganti Expanded(child: ListView) menjadi Column untuk menampung stats
          children: [
            _buildStatsWidget(), // Panggil widget statistik di sini
            _buildTableHeader(),
            Expanded( // Expanded diperlukan karena ListView.builder di dalam Column
              child: ListView.builder(
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  return _buildTableRow(item);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // WIDGET BUILDER UNTUK HEADER TABEL
  Widget _buildTableHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.brown[800]?.withOpacity(0.9), // Warna lebih solid
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10), // Padding disesuaikan
      child: const Row(
        children: [
          Expanded(
            flex: 5, // Disesuaikan untuk nama barang
            child: Text(
              'Barang',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
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
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Harga',
              textAlign: TextAlign.right, // Perataan kanan untuk harga
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Stok',
              textAlign: TextAlign.right, // Perataan kanan untuk stok
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Aksi',
              textAlign: TextAlign.center, // Tetap di tengah untuk aksi
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET BUILDER UNTUK BARIS TABEL
  Widget _buildTableRow(WarehouseItem item) {
    return Card( // Menggunakan Card untuk setiap baris untuk efek elevated
      margin: const EdgeInsets.only(bottom: 1), // Margin kecil antar card
      elevation: 1, // Elevasi kecil
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)), // Hilangkan border radius
      color: Colors.brown[800]?.withOpacity(0.7), // Warna yang sedikit transparan
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10), // Padding disesuaikan
        child: Row(
          children: [
            Expanded(
              flex: 5, // Disesuaikan untuk nama barang
              child: Text(
                item.name,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(item.category, style: const TextStyle(color: Colors.white, fontSize: 14)),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Rp${item.price.toStringAsFixed(0)}',
                textAlign: TextAlign.right, // Perataan kanan untuk harga
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                item.stock.toString(),
                textAlign: TextAlign.right, // Perataan kanan untuk stok
                style: TextStyle(color: item.stock < 10 ? Colors.redAccent : Colors.white, fontWeight: item.stock < 10 ? FontWeight.bold : FontWeight.normal, fontSize: 14), // Sorot stok rendah
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Tetap di tengah untuk aksi
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue[300], size: 20), // Warna lebih cerah
                    onPressed: _isSavingOrDeleting ? null : () => _showItemDialog(item: item),
                    tooltip: 'Edit Barang',
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red[300], size: 20), // Warna lebih cerah
                    onPressed: _isSavingOrDeleting ? null : () => _confirmDeleteItem(item), // Panggil konfirmasi hapus
                    tooltip: 'Hapus Barang',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FUNGSI KONFIRMASI HAPUS ITEM
  void _confirmDeleteItem(WarehouseItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.brown[800],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            'Hapus ${item.name}?',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus barang ini secara permanen dari warehouse?',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]), // Warna tombol hapus lebih gelap
              onPressed: () {
                _deleteItemFromFirestore(item);
                Navigator.pop(context);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // FUNGSI UNTUK MENAMPILKAN DIALOG TAMBAH/EDIT
  void _showItemDialog({WarehouseItem? item}) {
    final _formKey = GlobalKey<FormState>();
    bool isEditing = item != null;

    final nameController = TextEditingController(text: item?.name ?? '');
    final priceController = TextEditingController(text: item?.price.toStringAsFixed(0) ?? '');
    final stockController = TextEditingController(text: item?.stock.toString() ?? '');
    String selectedCategory = item?.category ?? _categories.first;
    String imageUrl = item?.image ?? 'https://i.imgur.com/Jc1mR5X.png'; // Default placeholder jika tidak ada

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              backgroundColor: Colors.brown[800],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: Text(
                isEditing ? 'Edit Barang' : 'Tambah Barang Baru',
                style: const TextStyle(
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
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.brown[700]!)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.brown[300]!)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          fillColor: Colors.brown[700]?.withOpacity(0.5), filled: true,
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) => value == null || value.isEmpty ? 'Nama tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Kategori',
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.brown[700]!)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.brown[300]!)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          fillColor: Colors.brown[700]?.withOpacity(0.5), filled: true,
                        ),
                        dropdownColor: Colors.brown[700],
                        iconEnabledColor: Colors.white,
                        items: _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category, style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (value) => dialogSetState(() => selectedCategory = value!),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: priceController,
                        decoration: InputDecoration(
                          labelText: 'Harga',
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.brown[700]!)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.brown[300]!)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          fillColor: Colors.brown[700]?.withOpacity(0.5), filled: true,
                        ),
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty ? 'Harga tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: stockController,
                        decoration: InputDecoration(
                          labelText: 'Stok',
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.brown[700]!)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.brown[300]!)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          fillColor: Colors.brown[700]?.withOpacity(0.5), filled: true,
                        ),
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty ? 'Stok tidak boleh kosong' : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isSavingOrDeleting ? null : () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _isSavingOrDeleting ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      final newItem = WarehouseItem(
                        id: item?.id ?? '', // Gunakan ID yang ada jika edit, kosong jika baru
                        name: nameController.text,
                        category: selectedCategory,
                        price: double.tryParse(priceController.text) ?? 0,
                        stock: int.tryParse(stockController.text) ?? 0,
                        image: imageUrl, // Sementara menggunakan URL yang sudah ada/placeholder
                      );

                      if (isEditing) {
                        await _updateItemInFirestore(newItem);
                      } else {
                        await _addItemToFirestore(newItem);
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: _isSavingOrDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(isEditing ? 'Update' : 'Tambah'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
