import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Untuk Firebase Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Untuk Firebase Authentication



const String backgroundImagePath =
    'assets/images/background.png'; // Ganti dengan path lokal jika menggunakan aset lokal

class PetugasPage extends StatefulWidget {
  @override
  _PetugasPageState createState() => _PetugasPageState();
}

class _PetugasPageState extends State<PetugasPage> {
  // Stream untuk mendengarkan perubahan data dari Firestore secara real-time
  Stream<QuerySnapshot>? _pegawaiStream; // Diubah namanya menjadi _pegawaiStream
  String? _userId; // ID pengguna yang terautentikasi (digunakan hanya untuk proses autentikasi Firebase)
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instance Firebase Auth

  // Controllers untuk input form penambahan/pengeditan petugas
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _shiftController = TextEditingController();
  final TextEditingController _jamKerjaController = TextEditingController();

  bool _newPegawaiIsActive = false; // Status default untuk pegawai baru

  @override
  void initState() {
    super.initState();
    // Memulai proses autentikasi dan inisialisasi stream data Firestore
    _initializeFirebaseAndAuth();
  }

  @override
  void dispose() {
    // Membuang controllers saat widget dihapus dari tree
    _namaController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _shiftController.dispose();
    _jamKerjaController.dispose();
    super.dispose();
  }

  // Fungsi untuk menginisialisasi Firebase Auth dan mengatur stream Firestore
  Future<void> _initializeFirebaseAndAuth() async {
    // Dapatkan APP ID dari environment Canvas
    final String appId = const String.fromEnvironment('FLUTTER_APP_ID', defaultValue: 'default-app-id');

    // Mendengarkan perubahan status autentikasi pengguna
    _auth.authStateChanges().listen((User? user) {
      if (mounted) { // Pastikan widget masih ada sebelum memanggil setState
        setState(() {
          _userId = user?.uid ?? 'anonymous_user'; // Set ID pengguna (digunakan oleh Firebase Auth)
          print("ID Pengguna Saat Ini: $_userId");

          // Atur stream Firestore setelah ID pengguna tersedia.
          // Jalur koleksi disesuaikan dengan skema penyimpanan data di Canvas.
          _pegawaiStream = FirebaseFirestore.instance
              .collection('artifacts')
              .doc(appId)
              .collection('public') // Gunakan 'public' untuk data yang bisa diakses multi-user
              .doc('data')
              .collection('pegawai') // Nama koleksi diubah menjadi 'pegawai'
              // --- PERUBAHAN: Mengurutkan berdasarkan 'id' secara ascending (menaik) ---
              // Ini akan menempatkan pegawai baru (dengan ID lebih besar) di bagian bawah daftar.
              .orderBy('id', descending: false)
              .snapshots();
        });
      }
    });
  }

  // Fungsi untuk menambahkan pegawai baru ke Firestore
  Future<void> _addPegawai() async {
    // Ambil nilai dari controllers
    final String nama = _namaController.text.trim();
    final String username = _usernameController.text.trim();
    final String email = _emailController.text.trim();
    final String shift = _shiftController.text.trim();
    final String jamKerja = _jamKerjaController.text.trim();

    // Validasi input
    if (nama.isEmpty || username.isEmpty || email.isEmpty || shift.isEmpty || jamKerja.isEmpty) {
      _showMessage('Semua kolom harus diisi!');
      return;
    }

    try {
      // Dapatkan APP ID untuk jalur koleksi Firestore
      final String appId = const String.fromEnvironment('FLUTTER_APP_ID', defaultValue: 'default-app-id');

      // Tentukan ID baru secara sederhana (misal: berdasarkan ID terbesar yang ada + 1)
      // Ini hanya untuk field 'id' di dokumen, bukan Document ID Firestore itu sendiri.
      // Perhatikan: ini BUKAN metode yang aman untuk aplikasi multi-user tanpa transaksi yang kompleks
      // karena bisa terjadi race condition jika dua user menambah di saat bersamaan
      // dan mencoba menghitung 'id' secara bersamaan.
      // Untuk tujuan demo ini (single user), ini bisa diterima.
      int newId = 0;
      final QuerySnapshot currentDocs = await FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('data')
          .collection('pegawai')
          .get();
      if (currentDocs.docs.isNotEmpty) {
        int maxId = 0;
        for (var doc in currentDocs.docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data.containsKey('id') && data['id'] is int) {
            if (data['id'] > maxId) {
              maxId = data['id'];
            }
          }
        }
        newId = maxId + 1;
      } else {
        newId = 1;
      }

      // Tambahkan data pegawai ke koleksi 'pegawai' di Firestore
      // Hanya menyertakan field yang diminta
      await FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('data')
          .collection('pegawai')
          .add({
            'id': newId,
            'nama': nama,
            'username': username,
            'email': email,
            'shift': shift,
            'jamKerja': jamKerja,
            'foto': 'https://placehold.co/300x300/CCCCCC/000000?text=No+Photo', // Foto placeholder
            'isActive': _newPegawaiIsActive,
          });

      _showMessage('Pegawai berhasil ditambahkan!');
      Navigator.pop(context);
      _clearAddForm();
    } catch (e) {
      print("Error saat menambahkan pegawai: $e");
      _showMessage('Gagal menambahkan pegawai: $e');
    }
  }

  // Fungsi untuk mengkonfirmasi dan menghapus pegawai dari Firestore
  void _confirmDeletePegawai(String docId, String? fotoUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'), // Judul lebih jelas
        content: const Text('Anda yakin ingin menghapus data pegawai ini secara permanen?'), // Pesan lebih jelas
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'), // Teks tombol
          ),
          ElevatedButton( // Menggunakan ElevatedButton untuk penegasan
            onPressed: () {
              _deletePegawai(docId, fotoUrl);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Warna tombol hapus merah
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'), // Teks tombol
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menghapus pegawai dari Firestore
  Future<void> _deletePegawai(String docId, String? fotoUrl) async {
    final String appId = const String.fromEnvironment('FLUTTER_APP_ID', defaultValue: 'default-app-id');
    try {
      await FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('data')
          .collection('pegawai')
          .doc(docId)
          .delete();
      _showMessage('Pegawai berhasil dihapus!');
    } catch (e) {
      print("Error saat menghapus pegawai: $e");
      _showMessage('Gagal menghapus pegawai: $e');
    }
  }

  // Fungsi untuk mengupdate status 'isActive' pegawai di Firestore
  Future<void> _updatePegawaiStatus(String docId, bool newValue) async {
    final String appId = const String.fromEnvironment('FLUTTER_APP_ID', defaultValue: 'default-app-id');
    try {
      await FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('data')
          .collection('pegawai')
          .doc(docId)
          .update({'isActive': newValue});
      _showMessage('Status pegawai berhasil diperbarui!');
    } catch (e) {
      print("Error saat memperbarui status pegawai: $e");
      _showMessage('Gagal memperbarui status: $e');
    }
  }

  // Fungsi pembantu untuk menampilkan pesan singkat (SnackBar)
  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.brown[700], // Warna SnackBar yang lebih cocok
          behavior: SnackBarBehavior.floating, // Efek floating
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Sudut membulat
          margin: const EdgeInsets.all(10), // Margin dari tepi
        ),
      );
    }
  }

  // Membersihkan input form penambahan pegawai
  void _clearAddForm() {
    _namaController.clear();
    _usernameController.clear();
    _emailController.clear();
    _shiftController.clear();
    _jamKerjaController.clear();
    setState(() {
      _newPegawaiIsActive = false;
    });
  }

  // Menampilkan dialog untuk menambahkan pegawai baru
  void _showAddPegawaiDialog() {
    _clearAddForm();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateInternal) {
            return AlertDialog(
              title: const Text('Tambah Pegawai Baru'),
              backgroundColor: Colors.brown[50], // Latar belakang dialog lebih terang
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Sudut lebih membulat
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.brown[100], // Warna avatar lebih cerah
                      child: Icon(Icons.person, size: 50, color: Colors.brown[600]), // Ikon lebih besar dan sesuai tema
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _namaController,
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap', // Label lebih deskriptif
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10), // Sudut input membulat
                        ),
                        filled: true,
                        fillColor: Colors.white, // Latar belakang input putih
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _shiftController,
                      decoration: InputDecoration(
                        labelText: 'Shift (Contoh: Pagi/Malam)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _jamKerjaController,
                      decoration: InputDecoration(
                        labelText: 'Jam Kerja (Contoh: 08:00 - 16:00)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Toggle untuk status isActive
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Status Aktif:', style: TextStyle(fontSize: 16, color: Colors.brown)),
                        Switch(
                          value: _newPegawaiIsActive,
                          onChanged: (bool value) {
                            setStateInternal(() {
                              _newPegawaiIsActive = value;
                            });
                          },
                          activeColor: Colors.green[700], // Warna aktif yang lebih gelap
                          inactiveThumbColor: Colors.red[700], // Warna non-aktif yang lebih gelap
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _clearAddForm();
                    Navigator.pop(context);
                  },
                  child: const Text('Batal', style: TextStyle(color: Colors.brown)),
                ),
                ElevatedButton(
                  onPressed: _addPegawai,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown, // Warna tombol tambah sesuai tema
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Tambah'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Daftar Pegawai')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pegawai'),
        centerTitle: true, // Judul di tengah
        elevation: 0, // Tanpa bayangan
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(backgroundImagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4),
              BlendMode.darken,
            ),
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _pegawaiStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('Belum ada pegawai. Tambahkan yang baru!',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              );
            }

            List<Map<String, dynamic>> pegawai = snapshot.data!.docs.map((doc) {
              return {
                ...doc.data() as Map<String, dynamic>,
                'documentId': doc.id,
              };
            }).toList();

            return ListView.builder(
              itemCount: pegawai.length,
              itemBuilder: (context, index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  elevation: 8, // Tambah elevasi untuk efek bayangan
                  color: Colors.brown[800]?.withOpacity(0.95), // Opasitas sedikit lebih tinggi
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), // Padding merata
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Foto Profil Pegawai
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3), // Border lebih tebal
                            boxShadow: [ // Tambah bayangan pada avatar
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            image: DecorationImage(
                              image: NetworkImage(pegawai[index]['foto'] ?? 'https://placehold.co/300x300/CCCCCC/000000?text=No+Photo'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Detail Data Pegawai
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      pegawai[index]['nama'],
                                      style: const TextStyle(
                                        fontSize: 22, // Ukuran font lebih besar
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1, // Batasi 1 baris
                                      overflow: TextOverflow.ellipsis, // Tambah elipsis jika terlalu panjang
                                    ),
                                  ),
                                  // Tombol hapus pegawai
                                  IconButton(
                                    iconSize: 30, // Ukuran ikon lebih besar
                                    icon: Icon(
                                      Icons.delete_forever, // Ikon hapus yang lebih kuat
                                      color: Colors.red[400], // Warna merah lebih terang
                                    ),
                                    onPressed: () =>
                                        _confirmDeletePegawai(pegawai[index]['documentId'], pegawai[index]['foto']),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5), // Spasi kecil
                              // Tampilkan ID dari data yang disimpan di Firestore
                              _buildInfoRow('ID', pegawai[index]['id']?.toString() ?? 'N/A', Colors.white70), // Warna teks info

                              const SizedBox(height: 10), // Spasi antar blok info

                              // Menampilkan Status Aktif/Tidak Aktif
                              Row(
                                children: [
                                  Icon(
                                    pegawai[index]['isActive']
                                        ? Icons.check_circle
                                        : Icons.cancel, // Ikon yang lebih ekspresif
                                    color: pegawai[index]['isActive']
                                        ? Colors.green[400] // Warna hijau lebih terang
                                        : Colors.red[400], // Warna merah lebih terang
                                    size: 20, // Ukuran ikon
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    pegawai[index]['isActive']
                                        ? 'Aktif'
                                        : 'Tidak Aktif',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500, // Sedikit lebih tebal
                                      color: pegawai[index]['isActive']
                                          ? Colors.green[400]
                                          : Colors.red[400],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10), // Spasi antar blok info

                              // Detail Informasi Lainnya
                              _buildInfoRow('👤', pegawai[index]['username'], Colors.white70),
                              _buildInfoRow('📧', pegawai[index]['email'], Colors.white70),
                              _buildInfoRow(
                                '⏰',
                                'Shift ${pegawai[index]['shift']} (${pegawai[index]['jamKerja']})',
                                Colors.white70,
                              ),
                            ],
                          ),
                        ),
                        // Switch untuk mengubah status aktif pegawai
                        Switch(
                          value: pegawai[index]['isActive'],
                          onChanged: (bool value) {
                            _updatePegawaiStatus(pegawai[index]['documentId'], value);
                          },
                          activeColor: Colors.green[700], // Warna switch aktif lebih gelap
                          inactiveThumbColor: Colors.red[700], // Warna switch non-aktif lebih gelap
                          trackColor: MaterialStateProperty.all(Colors.white.withOpacity(0.3)), // Warna track
                          splashRadius: 20, // Efek riak saat disentuh
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      // Tombol Floating Action untuk menambahkan pegawai baru
      floatingActionButton: FloatingActionButton(
        heroTag: "addPegawaiBtn",
        onPressed: _showAddPegawaiDialog,
        backgroundColor: Colors.brown[600], // Warna FAB lebih gelap
        foregroundColor: Colors.white, // Warna ikon FAB
        elevation: 8, // Elevasi FAB
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Bentuk FAB
        child: const Icon(Icons.person_add), // Ikon FAB yang lebih relevan
      ),
    );
  }

  // Widget pembantu untuk membangun baris informasi (ikon + teks)
  // Menambahkan parameter 'textColor' untuk fleksibilitas
  Widget _buildInfoRow(String icon, String text, [Color? textColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0), // Padding lebih kecil
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align top
        children: [
          Text(icon, style: const TextStyle(fontSize: 18, color: Colors.white)), // Ikon lebih besar
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: textColor ?? Colors.white70), // Warna teks info
              softWrap: true, // Memungkinkan teks wrap ke baris baru
            ),
          ),
        ],
      ),
    );
  }
}
