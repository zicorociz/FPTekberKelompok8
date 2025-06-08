import 'package:flutter/material.dart';

class ProfilPage extends StatefulWidget {
  @override
  _ProfilPageState createState() => _ProfilPageState();
}

const String backgroundImagePath =
    'https://images.unsplash.com/photo-1650292386081-fed5cb55d588?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
const Color coffeeGreen = Colors.green;

class _ProfilPageState extends State<ProfilPage> {
  String nama = 'Lisa Anindya';
  String alamat = 'Purwokerto';
  String email = 'lisa321@gmail.com';

  void _editProfil() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Profil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: nama,
                onChanged: (value) => nama = value,
                decoration: InputDecoration(labelText: 'Nama'),
              ),
              TextFormField(
                initialValue: alamat,
                onChanged: (value) => alamat = value,
                decoration: InputDecoration(labelText: 'Alamat'),
              ),
              TextFormField(
                initialValue: email,
                onChanged: (value) => email = value,
                decoration: InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: Text('Profil')),
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
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 30,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.brown[900],
                      backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/150?img=24',
                      ), // Ganti ID sesuai keinginan
                    ),
                    SizedBox(height: 80),
                    Text(
                      'Nama: $nama',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    Text(
                      'Alamat: $alamat',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    Text(
                      'Email: $email',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    SizedBox(height: 80),
                    ElevatedButton(
                      onPressed: _editProfil,
                      child: Text('Edit Profil'),
                    ),
                    SizedBox(height: 12), // beri jarak
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Warna merah untuk logout
                      ),
                      child: Text('Sign Out'),
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
