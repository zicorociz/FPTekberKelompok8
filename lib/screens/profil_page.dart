import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../global.dart'; // Import global email user login

const String backgroundImagePath = 'assets/images/background.png';

class ProfilPage extends StatefulWidget {
  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String nama = '';
  String alamat = '';
  String email = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    print("Email user login: $currentUserEmail"); // Tambahkan ini
  if (currentUserEmail == null) {
    print("Email NULL, keluar dari loadProfile");
    return;
  }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('signup')
          .doc(currentUserEmail)
          .get();

        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            nama = data['nama'] ?? '';
            alamat = data['alamat'] ?? '';
            email = data['email'] ?? currentUserEmail!;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          _showMessage('Data profil tidak ditemukan');
        }
      } catch (e) {
        print('Gagal mengambil data profil: $e');
        _showMessage('Terjadi kesalahan saat memuat profil.');

        setState(() {
          isLoading = false; // Tambahkan ini agar loading berhenti
        });
      }
    }

  Future<void> _updateProfile() async {
    if (currentUserEmail == null) return;

    try {
      // Update ke signup
      final signupRef = FirebaseFirestore.instance
          .collection('signup')
          .doc(currentUserEmail);

      await signupRef.update({
        'nama': nama,
        'alamat': alamat,
      });

      // Ambil ulang data lengkap dari signup
      final snapshot = await signupRef.get();
      final data = snapshot.data()!;

      // Siapkan data untuk pegawai
      final pegawaiRef = FirebaseFirestore.instance
          .collection('pegawai')
          .doc(currentUserEmail);

      final pegawaiSnapshot = await pegawaiRef.get();

      final newPegawaiData = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'nama': nama,
        'username': currentUserEmail!.split('@').first,
        'email': currentUserEmail,
        'shift': data['shift'] ?? '',
        'jamKerja': data['jamKerja'] ?? '',
        'foto': 'https://placehold.co/300x300/CCCCCC/000000?text=No+Photo',
        'isActive': data['isActive'] ?? false,
      };

      if (pegawaiSnapshot.exists) {
        await pegawaiRef.update(newPegawaiData);
      } else {
        await pegawaiRef.set(newPegawaiData);
      }

      _showMessage('Profil berhasil diperbarui!');
    } catch (e) {
      print('Gagal update profil dan pegawai: $e');
      _showMessage('Gagal menyimpan perubahan profil.');
    }
  }

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
                readOnly: true,
                decoration: InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _updateProfile();
              setState(() {}); // refresh UI
              Navigator.pop(context);
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: Text('Profil')),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: isLoading
              ? CircularProgressIndicator()
              : Container(
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
                            ),
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
                          SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
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
