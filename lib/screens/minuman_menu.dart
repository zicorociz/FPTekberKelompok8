import 'dart:typed_data'; // Untuk Uint8List
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'add_menu_page.dart';

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
class MinumanMenuPage extends StatefulWidget {
  @override
  State<MinumanMenuPage> createState() => _MinumanMenuPageState();
}

class _MinumanMenuPageState extends State<MinumanMenuPage> {
  final String backgroundImagePath = 'assets/images/background.png';

  // Katalog produk asli (tidak diubah-ubah)
  final List<Map<String, dynamic>> _allMenuItems = [
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

    // DefaultTabController sudah dihapus. Langsung menggunakan Scaffold.
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
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              // Tambahkan tombol untuk menghapus teks pencarian
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey[600]),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
            ),
          ),
        ),
        actions: [
          // Tombol keranjang tetap ada
          IconButton(
            icon: Badge(
              label: Text('$totalCartItems'),
              isLabelVisible: totalCartItems > 0,
              child: Icon(Icons.shopping_cart),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CartPage(
                    cart: _cart,
                    totalOrderPrice: totalOrderPrice,
                    onConfirm: () {
                      setState(() {
                        _cart.clear();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Pesanan berhasil dikonfirmasi!'),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
        // Properti 'bottom' (untuk TabBar) sudah dihapus
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown[900],
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddMenuPage()));

          if (result != null && result is Map<String, dynamic>) {
            setState(() {
              // Tambahkan menu baru ke list utama, lalu filter ulang
              _allMenuItems.add(result);
              _onSearchChanged(); // Panggil fungsi ini agar list ter-update
            });
          }
        },
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImagePath),
            fit: BoxFit.cover,
          ),
        ),
        // TabBarView sudah dihapus, langsung panggil widget grid
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
                      if (item['image'] is String &&
                          item['image'].startsWith('assets/')) {
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
                            color: quantityInCart > 0
                                ? Colors.brown.shade400
                                : Colors.transparent,
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
                                        icon: Icon(
                                          Icons.remove_circle,
                                          color: Colors.red,
                                        ),
                                        onPressed: quantityInCart > 0
                                            ? () => _updateQuantity(item, -1)
                                            : null,
                                      ),
                                      Text(
                                        '$quantityInCart',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.add_circle,
                                          color: Colors.green,
                                        ),
                                        onPressed: () =>
                                            _updateQuantity(item, 1),
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
}

// --- HALAMAN KERANJANG (Tidak ada perubahan) ---
class CartPage extends StatelessWidget {
  final List<OrderItem> cart;
  final Function onConfirm;
  final double totalOrderPrice;

  CartPage({
    required this.cart,
    required this.onConfirm,
    required this.totalOrderPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Keranjang Pesanan"),
        backgroundColor: Colors.brown[800],
      ),
      body: cart.isEmpty
          ? Center(
              child: Text(
                'Keranjang Anda masih kosong.',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage(item.image),
                        ),
                        title: Text(item.name),
                        subtitle: Text('${item.quantity} x ${item.price}'),
                        trailing: Text(
                          'Rp${item.totalPrice.toStringAsFixed(0)}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
                Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Harga:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Rp${totalOrderPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            onConfirm();
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Konfirmasi Pesanan",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
