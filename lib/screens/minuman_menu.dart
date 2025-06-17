import 'dart:typed_data'; // Untuk Uint8List
import 'package:flutter/material.dart';
import 'add_menu_page.dart';
import 'package:intl/intl.dart'; // Penting: Import ini untuk DateFormat
import 'package:cloud_firestore/cloud_firestore.dart';


// --- MODEL DATA (Tidak ada perubahan) ---
class OrderItem {
  final String name;
  final String price;
  final String image;
  int quantity;

  OrderItem({
    required this.name,
    required this.price,
    required this.image,
    this.quantity = 0,
  });

  double get priceAsDouble => double.parse(
        price.replaceAll('Rp', '').replaceAll('.', '').replaceAll(',-', '').trim(),
      );

  double get totalPrice => quantity * priceAsDouble;
}

// --- HALAMAN MENU UTAMA (DENGAN FITUR SEARCH) ---

// Typedef untuk callback saat pesanan dikonfirmasi dan siap dikirim ke parent
typedef OnOrderConfirmedCallback = void Function(Map<String, dynamic> newOrder);

class MinumanMenuPage extends StatefulWidget {
  // Tambahkan properti callback untuk mengirim pesanan yang dikonfirmasi
  final OnOrderConfirmedCallback? onOrderConfirmed;

  const MinumanMenuPage({Key? key, this.onOrderConfirmed}) : super(key: key);

  @override
  State<MinumanMenuPage> createState() => _MinumanMenuPageState();
}

class _MinumanMenuPageState extends State<MinumanMenuPage> {
  final String backgroundImagePath = 'assets/images/background.png';
  

  // Katalog produk asli (tidak diubah-ubah)
  List<Map<String, dynamic>> _allMenuItems = [];

  // List untuk menampilkan item yang sudah difilter
  List<Map<String, dynamic>> _filteredMenuItems = [];

  // Controller dan state untuk fitur search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Keranjang pesanan
  final List<OrderItem> _cart = [];

  @override
  void initState() {
    super.initState();
    // Awalnya, tampilkan semua menu
    _filteredMenuItems = _allMenuItems;
    // Tambahkan listener untuk mendeteksi perubahan pada input search
    _searchController.addListener(_onSearchChanged);
    _loadMinumanFromFirebase(); // tambahkan ini
  }

  @override
  void dispose() {
    // Hapus listener dan controller untuk mencegah memory leak
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi yang dipanggil setiap kali user mengetik di search bar
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      // Filter list menu berdasarkan query
      _filteredMenuItems = _allMenuItems.where((item) {
        final itemName = item['name'].toString().toLowerCase();
        final searchLower = _searchQuery.toLowerCase();
        return itemName.contains(searchLower);
      }).toList();
    });
  }

  // --- FUNGSI HELPER KERANJANG (Tidak ada perubahan) ---
  double get totalOrderPrice {
    return _cart.fold(0.0, (total, item) => total + item.totalPrice);
  }

  int get totalCartItems {
    return _cart.length;
  }

  int _getQuantityInCart(Map<String, dynamic> menuItem) {
    return _cart
        .firstWhere(
          (item) => item.name == menuItem['name'],
          orElse: () => OrderItem(name: '', price: '', image: '', quantity: 0),
        )
        .quantity;
  }

  void _updateQuantity(Map<String, dynamic> menuItem, int change) {
    setState(() {
      final index = _cart.indexWhere((item) => item.name == menuItem['name']);
      if (index != -1) {
        _cart[index].quantity += change;
        if (_cart[index].quantity <= 0) {
          _cart.removeAt(index);
        }
      } else if (change > 0) {
        _cart.add(
          OrderItem(
            name: menuItem['name'],
            price: menuItem['price'],
            image: menuItem['image'],
            quantity: 1,
          ),
        );
      }
    });
  }
  void _loadMinumanFromFirebase() {
  FirebaseFirestore.instance
      .collection('minuman_menu')
      .snapshots()
      .listen((snapshot) {
    setState(() {
      _allMenuItems = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id, // penting untuk edit/hapus nanti
          'name': data['name'],
          'description': data['description'],
          'price': data['price'],
          'image': data['image'],
        };
      }).toList();

      _onSearchChanged(); // update hasil search
    });
  });
}


  // --- BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    int columns = (width > 1200)
        ? 5
        : (width > 900)
            ? 4
            : (width > 600)
                ? 3
                : 2;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[800],
        // Ganti title dengan TextField untuk search
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari menu...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              // Tambahkan tombol untuk menghapus teks pencarian
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
            ),
          ),
        ),
        actions: [
          // Tombol keranjang
          IconButton(
            icon: Badge(
              label: Text('$totalCartItems'),
              isLabelVisible: totalCartItems > 0,
              child: const Icon(Icons.shopping_cart),
            ),
            onPressed: () async {
              // Menunggu hasil dari CartPage (Map data pesanan)
              final newOrderData = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CartPage(
                    cart: _cart,
                    totalOrderPrice: totalOrderPrice,
                    // Callback onConfirm yang sekarang menerima customerName
                    onConfirm: (List<OrderItem> confirmedCart, double finalPrice, String customerName) {
                      // Buat format data pesanan yang sesuai untuk PesananMasukPage
                      final orderItemsNames =
                          confirmedCart.map((item) => "${item.name} (${item.quantity}x)").toList();
                      final newOrderId = DateTime.now().millisecondsSinceEpoch;
                      final newOrder = {
                        'id': newOrderId,
                        'nama': customerName, // Gunakan nama dari input form
                        'pesanan': orderItemsNames,
                        'waktu': DateFormat('HH:mm a').format(DateTime.now()), // Format waktu lebih spesifik
                        'status': 'Baru',
                        'totalHarga': finalPrice, // Tambahkan total harga
                      };
                      return newOrder; // Kembalikan data pesanan
                    },
                  ),
                ),
              );

              // Jika ada data pesanan yang dikonfirmasi kembali dari CartPage
              if (newOrderData != null && newOrderData is Map<String, dynamic>) {
                setState(() {
                  _cart.clear(); // Hapus item dari keranjang setelah dikonfirmasi
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pesanan berhasil dikonfirmasi dan ditambahkan!'),
                  ),
                );

                // Panggil callback onOrderConfirmed yang diberikan dari parent (misal DashboardPage)
                if (widget.onOrderConfirmed != null) {
                  widget.onOrderConfirmed!(newOrderData);
                }
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddMenuPage()),
          );

          if (result != null && result is Map<String, dynamic>) {
            try {
              final String imageUrl = result['image']?.isNotEmpty == true
                  ? result['image']
                  : 'https://placehold.co/300x300/CCCCCC/000000?text=No+Image';

              await FirebaseFirestore.instance.collection('minuman_menu').add({
                'name': result['name'],
                'description': result['description'],
                'price': result['price'],
                'image': imageUrl,
                'createdAt': FieldValue.serverTimestamp(),
              });

              _showMessage('Menu berhasil ditambahkan!');
            } catch (e) {
              _showMessage('Gagal menambahkan menu: $e');
            }
          }
        },
        child: const Icon(Icons.add),
      ),

      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: _buildMenuGrid(columns),
      ),
    );
  }

  // Widget untuk membangun grid menu
  Widget _buildMenuGrid(int columns) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            "Our Popular Menu",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.brown[900],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            // Cek jika hasil filter kosong
            child: _filteredMenuItems.isEmpty
                ? Center(
                    child: Text(
                      'Menu tidak ditemukan',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.brown[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.75,
                    ),
                    // Gunakan list yang sudah difilter
                    itemCount: _filteredMenuItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredMenuItems[index];
                      final quantityInCart = _getQuantityInCart(item);

                      Widget imageWidget;
                      if (item['image'] is String && item['image'].startsWith('assets/')) {
                        imageWidget = CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage(item['image']),
                        );
                      } else if (item['image'] is Uint8List) {
                        imageWidget = CircleAvatar(
                          radius: 40,
                          backgroundImage: MemoryImage(item['image']),
                        );
                      } else {
                        imageWidget = const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.fastfood, color: Colors.white),
                        );
                      }

                      return Card(
                        color: quantityInCart > 0
                            ? Colors.brown.shade100
                            : Colors.white.withOpacity(0.9),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: quantityInCart > 0 ? Colors.brown.shade400 : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  imageWidget,
                                  const SizedBox(height: 10),
                                  Text(
                                    item['name'],
                                    textAlign: TextAlign.center,
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
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.brown[700],
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    item['price'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle,
                                          color: Colors.red,
                                        ),
                                        onPressed: quantityInCart > 0 ? () => _updateQuantity(item, -1) : null,
                                      ),
                                      Text(
                                        '$quantityInCart',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle,
                                          color: Colors.green,
                                        ),
                                        onPressed: () => _updateQuantity(item, 1),
                                      ),
                                    ],
                                  ),
                                ],
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
    );
  }
  void _showMessage(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ),
  );
}

}


typedef CartConfirmationCallback = Map<String, dynamic> Function(
    List<OrderItem> confirmedCart, double finalPrice, String customerName);

class CartPage extends StatefulWidget {
  final List<OrderItem> cart;
  final CartConfirmationCallback onConfirm; // Menggunakan typedef baru yang lebih spesifik
  final double totalOrderPrice;

  CartPage({
    Key? key,
    required this.cart,
    required this.onConfirm,
    required this.totalOrderPrice,
  }) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final TextEditingController _customerNameController = TextEditingController();

  @override
  void dispose() {
    _customerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Keranjang Pesanan"), // Gunakan 'const' untuk performa
        backgroundColor: Colors.brown[800],
      ),
      // Cek apakah keranjang kosong
      body: widget.cart.isEmpty // Akses properti dari widget menggunakan 'widget.'
          ? Center(
              child: Text(
                'Keranjang Anda masih kosong.',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            )
          : Column(
              children: [
                // --- BAGIAN INPUT NAMA PEMESAN ---
                Padding(
                  padding: const EdgeInsets.all(16.0), // Gunakan 'const'
                  child: TextField(
                    controller: _customerNameController, // Hubungkan dengan controller
                    decoration: InputDecoration(
                      labelText: 'Nama Pemesan',
                      hintText: 'Masukkan nama pelanggan',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      prefixIcon: const Icon(Icons.person), // Gunakan 'const'
                    ),
                  ),
                ),
                // --- AKHIR BAGIAN INPUT NAMA PEMESAN ---

                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cart.length, // Akses properti 'cart' dari 'widget.'
                    itemBuilder: (context, index) {
                      final item = widget.cart[index]; // Akses item keranjang
                      return ListTile(
                        leading: CircleAvatar(
                          // Cek apakah image adalah asset atau bukan
                          backgroundImage: item.image.startsWith('assets/')
                              ? AssetImage(item.image)
                              : null, // Jika bukan asset, bisa jadi null atau pakai placeholder
                          // Tambahkan child jika backgroundImage null (misal dari Uint8List)
                          child: item.image.startsWith('assets/') ? null : const Icon(Icons.coffee), // Gunakan 'const'
                        ),
                        title: Text(item.name),
                        subtitle: Text('${item.quantity} x ${item.price}'),
                        trailing: Text(
                          'Rp${item.totalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold), // Gunakan 'const'
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 1), // Gunakan 'const'
                Padding(
                  padding: const EdgeInsets.all(16.0), // Gunakan 'const'
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text( // Gunakan 'const'
                            'Total Harga:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Rp${widget.totalOrderPrice.toStringAsFixed(0)}', // Akses 'totalOrderPrice' dari 'widget.'
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20), // Gunakan 'const'
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            padding: const EdgeInsets.symmetric(vertical: 15), // Gunakan 'const'
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            // Ambil nama pemesan dari controller TextField
                            final customerName = _customerNameController.text.trim();

                            // Validasi: Jika nama pemesan kosong, tampilkan snackbar dan jangan lanjutkan
                            if (customerName.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar( // Gunakan 'const'
                                  content: Text('Nama pemesan tidak boleh kosong!'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return; // Hentikan fungsi di sini
                            }
                            final confirmedOrder = widget.onConfirm(
                              widget.cart, // Kirim daftar item di keranjang
                              widget.totalOrderPrice, // Kirim total harga
                              customerName, // Kirim nama pemesan yang diinput
                            );
                            Navigator.pop(context, confirmedOrder);
                          },
                          child: const Text( // Gunakan 'const'
                            "Konfirmasi Pesanan",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10), // Gunakan 'const'
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
