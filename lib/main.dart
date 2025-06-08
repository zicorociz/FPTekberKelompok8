import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(MyApp());

const String backgroundImagePath =
    'assets/images/background.png';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Admin',
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.brown,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.brown[900],
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.brown[900],
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey[400],
        ),
      ),
      home: HomeScreen(),
    );
  }
}
