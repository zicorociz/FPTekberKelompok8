import 'package:flutter/material.dart';
//import 'login.dart'; // Import login.dart di sini
import 'layanan.dart'; // Import layanan.dart di sini

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LayananPage(), // Set LayananPage sebagai home page
    );
  }
}
