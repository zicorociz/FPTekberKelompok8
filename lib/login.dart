import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Image.asset(
              'assets/images/sikilap.png',
            ), // Ganti dengan logo aplikasi kamu
            const SizedBox(height: 40),
            TextField(
              decoration: InputDecoration(
                labelText: 'Nama Pengguna atau Email atau No. Telp',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Kata Sandi',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 35),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Warna button biru
              ),
              child: const Text('Masuk', style: TextStyle(color: Colors.white)),
            ),
            TextButton(onPressed: () {}, child: const Text('Lupa Kata Sandi')),
            TextButton(
              onPressed: () {},
              child: const Text('Login Sebagai Mitra'),
            ),
            const SizedBox(height: 20),
            Container(
              color: Colors.blue, // Background biru untuk bagian bawah
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Belum memiliki akun? ',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Buat Baru',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
