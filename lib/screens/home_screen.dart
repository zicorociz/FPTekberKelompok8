import 'package:flutter/material.dart';
import 'petugas_page.dart';
import 'profil_page.dart';
import 'pesanan_masuk_page.dart'; // Pastikan ini mengimpor file yang benar untuk PesananMasukPage
import 'warehouse_menu_page.dart';
import 'minuman_menu.dart'; // Pastikan ini mengimpor file yang benar untuk MinumanMenuPage

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

const String backgroundImagePath = 'assets/images/background.png';
const Color coffeeGreen = Colors.green; // Ini sebenarnya tidak digunakan, bisa dihapus jika mau

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Ini adalah daftar utama untuk menyimpan semua pesanan yang telah dikonfirmasi.
  // HomeScreen akan menjadi 'sumber kebenaran' untuk data pesanan.
  final List<Map<String, dynamic>> _confirmedOrders = [];

  // Fungsi callback ini akan dipanggil oleh MinumanMenuPage (melalui CartPage)
  // ketika ada pesanan baru yang dikonfirmasi.
  void _addConfirmedOrder(Map<String, dynamic> newOrder) {
    setState(() {
      _confirmedOrders.add(newOrder); // Tambahkan pesanan baru ke daftar
      _currentIndex = 0; // Pindah otomatis ke tab 'Pesanan' (indeks 0)
    });
  }

  // Gunakan getter untuk _screens agar daftar widget selalu dibuat ulang
  // dengan data _confirmedOrders yang paling baru setiap kali setState dipanggil.
  List<Widget> get _screens {
    return [
      PesananMasukPage(
        key: ValueKey('PesananMasukPage-${_confirmedOrders.length}'),
        currentOrders: _confirmedOrders, // Teruskan daftar pesanan ke PesananMasukPage
      ),
      MinumanMenuPage(onOrderConfirmed: _addConfirmedOrder), // Teruskan callback
      PetugasPage(),
      WarehouseMenuPage(),
      ProfilPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            // PERBAIKAN PENTING: Gunakan AssetImage untuk gambar lokal
            image: AssetImage(backgroundImagePath),
            fit: BoxFit.cover,
          ),
        ),
        // Tampilkan halaman yang sesuai dengan _currentIndex
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed, // Menjaga item agar tidak bergeser saat dipilih
        items: const [ // Gunakan const untuk BottomNavigationBarItem agar lebih efisien
          BottomNavigationBarItem(icon: Icon(Icons.notes), label: 'Pesanan'),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Makanan', // Sesuaikan label jika MinumanMenuPage juga menjual makanan
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Petugas',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Warehouse'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}