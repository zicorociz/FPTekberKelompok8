import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_page.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://jmnqcyxvjsutbnddabue.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImptbnFjeXh2anN1dGJuZGRhYnVlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk5Njg5MzEsImV4cCI6MjA2NTU0NDkzMX0.hsHx-3n6RKRhuv-VHJiyRc5aUWgrazr5M3aMrDjr9vk';


// void main() => runApp(MyApp());

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

const String backgroundImagePath = 'assets/images/background.png';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Admin',
      debugShowCheckedModeBanner: false,
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
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
