import 'package:flutter/material.dart';
import 'login.dart'; // Import login.dart di sini

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginPage(), // Set LoginPage sebagai home page
    );
  }
}
