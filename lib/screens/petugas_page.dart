// petugas_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'dart:io'; 
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:firebase_storage/firebase_storage.dart'; 
import 'package:image_picker/image_picker.dart'; 

const String backgroundImagePath =
    'assets/images/background.png'; 

class PetugasPage extends StatefulWidget {
  @override
  _PetugasPageState createState() => _PetugasPageState();
}

class _PetugasPageState extends State<PetugasPage> {
  // Stream untuk mendengarkan perubahan data dari Firestore secara real-time
  Stream<QuerySnapshot>? _pegawaiStream;
  String? _userId; // ID pengguna yang terautentikasi (digunakan hanya untuk proses autentikasi Firebase)
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instance Firebase Auth

  // Controllers untuk input form penambahan/pengeditan petugas
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _shiftController = TextEditingController();
  final TextEditingController _jamKerjaController = TextEditingController();

  bool _newPegawaiIsActive = false; // Status default untuk pegawai baru
  XFile? _selectedXFile; // File gambar yang dipilih oleh image_picker
  Uint8List? _selectedImageBytes; // Bytes gambar untuk pratinjau di web
  final ImagePicker _picker = ImagePicker(); // Instance ImagePicker
  bool _isUploading = false; // Status untuk menunjukkan apakah unggahan sedang berlangsung

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

    _auth.authStateChanges().listen((User? user) {
      if (mounted) { 
        setState(() {
          _userId = user?.uid ?? 'anonymous_user'; 
          print("ID Pengguna Saat Ini: $_userId");

          _pegawaiStream = FirebaseFirestore.instance
              .collection('pegawai') 
              .orderBy('id', descending: false)
              .snapshots();
        });
      }
    });
  }

  // Fungsi untuk memilih gambar dari galeri perangkat dan memperbarui pratinjau
  Future<void> _pickImageAndSetStateForPreview() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _selectedXFile = pickedFile;
        // Untuk web, baca bytes langsung untuk pratinjau. Untuk non-web, cukup path.
        if (kIsWeb) {
          _selectedImageBytes = await pickedFile.readAsBytes();
        } else {
          _selectedImageBytes = null;
        }
        setState(() {}); 
      }
    } catch (e) {
      print("Error memilih gambar: $e");
      _showMessage('Gagal memilih gambar.');
    }
  }
  Future<String?> _uploadImageToFirebaseStorage(XFile? imageXFile) async {
    if (imageXFile == null) return null;

    try {
      final String fileName = 'pegawai_photo_${DateTime.now().millisecondsSinceEpoch}_${imageXFile.name}';
      final storageRef = FirebaseStorage.instance.ref().child('pegawai_photos').child(fileName);

      print('Memulai unggah foto ke Firebase Storage...');
      UploadTask uploadTask;

      if (kIsWeb) {
        final Uint8List bytes = await imageXFile.readAsBytes();
        uploadTask = storageRef.putData(bytes);
      } else {
        final File file = File(imageXFile.path);
        uploadTask = storageRef.putFile(file);
      }
      
      // Pantau status unggahan
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('Upload progress: ${ (progress * 100).toStringAsFixed(2) }%');
      });

      final TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      print('Foto berhasil diunggah!');
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error mengunggah gambar ke Firebase Storage: $e");
      throw Exception('Gagal mengunggah foto.');
    }
  }

  Future<void> _addPegawai() async {
    final String nama = _namaController.text.trim();
    final String username = _usernameController.text.trim();
    final String email = _emailController.text.trim();
    final String shift = _shiftController.text.trim();
    final String jamKerja = _jamKerjaController.text.trim();

    if (nama.isEmpty || username.isEmpty || email.isEmpty || shift.isEmpty || jamKerja.isEmpty) {
      _showMessage('Semua kolom harus diisi!');
      return;
    }

    setState(() {
      _isUploading = true; // Aktifkan indikator loading
    });

    try {
      final String appId = const String.fromEnvironment('FLUTTER_APP_ID', defaultValue: 'default-app-id');

      int newId = 0;
      final QuerySnapshot currentDocs = await FirebaseFirestore.instance
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

      String fotoUrl = 'https://placehold.co/300x300/CCCCCC/000000?text=No+Photo'; // Default placeholder

      // Unggah foto jika ada yang dipilih
      if (_selectedXFile != null) {
        fotoUrl = await _uploadImageToFirebaseStorage(_selectedXFile) ?? fotoUrl;
      }

      // Tambahkan data pegawai ke koleksi 'pegawai' di Firestore
      await FirebaseFirestore.instance
          .collection('pegawai')
          .doc(username)
          .set({
            'id': newId,
            'nama': nama,
            'username': username,
            'email': email,
            'shift': shift,
            'jamKerja': jamKerja,
            'foto': fotoUrl, // Menggunakan URL foto yang diunggah atau placeholder
            'isActive': _newPegawaiIsActive,
          });

      _showMessage('Pegawai berhasil ditambahkan!');
      Navigator.pop(context);
      _clearAddForm();
    } catch (e) {
      print("Error saat menambahkan pegawai: $e");
      _showMessage('Gagal menambahkan pegawai: $e');
    } finally {
      setState(() {
        _isUploading = false; // Nonaktifkan indikator loading
      });
    }
  }

  // Fungsi untuk mengkonfirmasi dan menghapus pegawai dari Firestore
  void _confirmDeletePegawai(String docId, String? fotoUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Anda yakin ingin menghapus data pegawai ini secara permanen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              _deletePegawai(docId, fotoUrl);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menghapus pegawai dari Firestore dan Storage
  Future<void> _deletePegawai(String docId, String? fotoUrl) async {
    final String appId = const String.fromEnvironment('FLUTTER_APP_ID', defaultValue: 'default-app-id');
    try {
      await FirebaseFirestore.instance
          .collection('pegawai')
          .doc(docId)
          .delete();

      // Menghapus foto dari Firebase Storage jika ada dan berasal dari Storage
      if (fotoUrl != null && fotoUrl.isNotEmpty && fotoUrl.contains('firebasestorage.googleapis.com')) {
        try {
          final storageRef = FirebaseStorage.instance.refFromURL(fotoUrl);
          await storageRef.delete();
          print("Foto berhasil dihapus dari Storage!");
        } catch (e) {
          print("Peringatan: Gagal menghapus foto dari Storage (mungkin sudah tidak ada atau URL salah): $e");
        }
      }
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
          backgroundColor: Colors.brown[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(10),
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
      _selectedXFile = null; // Reset file yang dipilih
      _selectedImageBytes = null; // Reset bytes gambar
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
              backgroundColor: Colors.brown[50],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Area untuk memilih foto
                    GestureDetector(
                      onTap: () async {
                        await _pickImageAndSetStateForPreview();
                        setStateInternal(() {}); // Perbarui UI dialog setelah memilih gambar
                      },
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.brown[100],
                        backgroundImage: _selectedXFile != null
                            ? (kIsWeb && _selectedImageBytes != null
                                ? MemoryImage(_selectedImageBytes!)
                                : FileImage(File(_selectedXFile!.path))) as ImageProvider<Object>?
                            : null,
                        child: _selectedXFile == null
                            ? Icon(Icons.camera_alt, size: 50, color: Colors.brown[600])
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _namaController,
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
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
                          activeColor: Colors.green[700],
                          inactiveThumbColor: Colors.red[700],
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
                  onPressed: _isUploading ? null : _addPegawai, // Tombol dinonaktifkan saat mengunggah
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isUploading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Tambah'),
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
        centerTitle: true,
        elevation: 0,
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
                  elevation: 8,
                  color: Colors.brown[800]?.withOpacity(0.95),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Foto Profil Pegawai
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
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
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Tombol hapus pegawai
                                  IconButton(
                                    iconSize: 30,
                                    icon: Icon(
                                      Icons.delete_forever,
                                      color: Colors.red[400],
                                    ),
                                    onPressed: () =>
                                        _confirmDeletePegawai(pegawai[index]['documentId'], pegawai[index]['foto']),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              // Tampilkan ID dari data yang disimpan di Firestore
                              _buildInfoRow('ID', pegawai[index]['id']?.toString() ?? 'N/A', Colors.white70),

                              const SizedBox(height: 10),

                              // Menampilkan Status Aktif/Tidak Aktif
                              Row(
                                children: [
                                  Icon(
                                    pegawai[index]['isActive']
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: pegawai[index]['isActive']
                                        ? Colors.green[400]
                                        : Colors.red[400],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    pegawai[index]['isActive']
                                        ? 'Aktif'
                                        : 'Tidak Aktif',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: pegawai[index]['isActive']
                                          ? Colors.green[400]
                                          : Colors.red[400],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

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
                          activeColor: Colors.green[700],
                          inactiveThumbColor: Colors.red[700],
                          trackColor: MaterialStateProperty.all(Colors.white.withOpacity(0.3)),
                          splashRadius: 20,
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
        backgroundColor: Colors.brown[600],
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  // Widget pembantu untuk membangun baris informasi (ikon + teks)
  // Menambahkan parameter 'textColor' untuk fleksibilitas
  Widget _buildInfoRow(String icon, String text, [Color? textColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18, color: Colors.white)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: textColor ?? Colors.white70),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
