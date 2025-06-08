import 'package:flutter/material.dart';
import 'petugas_page.dart';
import 'profil_page.dart';
import 'pesanan_masuk_page.dart';
import 'warehouse_menu_page.dart';
import 'minuman_menu.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

const String backgroundImagePath =
    'assets/images/background.png';
const Color coffeeGreen = Colors.green;

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    PetugasPage(),
    ProfilPage(),
    PesananMasukPage(),
    WarehouseMenuPage(),
    MinumanMenuPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(backgroundImagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Petugas',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          BottomNavigationBarItem(icon: Icon(Icons.notes), label: 'Pesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Warehouse'),
          BottomNavigationBarItem( // Tambahkan item menu makanan
            icon: Icon(Icons.restaurant_menu),
            label: 'Makanan',
          )
        ],
      ),
    );
  }
}
