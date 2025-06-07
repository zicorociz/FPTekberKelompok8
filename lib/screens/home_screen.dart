import 'package:flutter/material.dart';
import 'petugas_page.dart';
import 'profil_page.dart';
import 'pesanan_masuk_page.dart';
import 'warehouse_menu_page.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

const String backgroundImagePath =
    'https://images.unsplash.com/photo-1650292386081-fed5cb55d588?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
const Color coffeeGreen = Colors.green;

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    PetugasPage(),
    ProfilPage(),
    PesananMasukPage(),
    WarehouseMenuPage(),
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
        ],
      ),
    );
  }
}
