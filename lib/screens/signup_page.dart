import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import '../global.dart'; // sesuaikan path jika perlu


const String backgroundImagePath = 'assets/images/background.png';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    final emailValid = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(email);

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showError('Semua field wajib diisi.');
    } else if (!emailValid) {
      _showError('Format email tidak valid.');
    } else if (password.length < 8) {
      _showError('Password minimal 8 karakter.');
    } else if (password != confirmPassword) {
      _showError('Password dan Ulangi Password tidak cocok.');
    } else {
      try {
        await FirebaseFirestore.instance
            .collection('signup')
            .doc(email)
            .set({
              'nama': name,
              'email': email,
              'password': password,
              'shift': '',
              'jamKerja': '',
              'isActive': false,
            });

            currentUserEmail = email;
        

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
      } catch (e) {
        print('Error saving to Firestore: $e');
        _showError('Gagal menyimpan data. Coba lagi.');
      }
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sign Up Gagal'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(backgroundImagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            width: screenWidth * 0.85,
            child: Card(
              color: Colors.brown[800]?.withOpacity(0.85),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_add, size: 80, color: Colors.white),
                    SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white54),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white54),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white54),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Ulangi Password',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white54),
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _signUp,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        child: Text('Sign Up'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: StadiumBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => LoginPage()),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.white70),
                          children: [
                            TextSpan(text: 'Sudah punya akun? '),
                            TextSpan(
                              text: 'Login',
                              style: TextStyle(
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
