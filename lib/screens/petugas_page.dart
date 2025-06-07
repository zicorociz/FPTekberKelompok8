import 'package:flutter/material.dart';

class PetugasPage extends StatefulWidget {
  @override
  _PetugasPageState createState() => _PetugasPageState();
}

const String backgroundImagePath =
    'https://images.unsplash.com/photo-1650292386081-fed5cb55d588?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
const Color coffeeGreen = Colors.green;

class _PetugasPageState extends State<PetugasPage> {
  List<Map<String, dynamic>> petugas = [
    {
      'id': 1,
      'nama': 'Rian',
      'username': 'rian123',
      'email': 'rian123@gmail.com',
      'shift': 'Pagi',
      'jamKerja': '08:00 - 16:00',
      'foto': 'https://i.pravatar.cc/300?img=1',
    },
    {
      'id': 2,
      'nama': 'Lisa',
      'username': 'lisa321',
      'email': 'lisa321@gmail.com',
      'shift': 'Malam',
      'jamKerja': '16:00 - 00:00',
      'foto': 'https://i.pravatar.cc/300?img=5',
    },
    {
      'id': 3,
      'nama': 'Jannie',
      'username': 'Jannieee',
      'email': 'Jannie12@gmail.com',
      'shift': 'Malam',
      'jamKerja': '16:00 - 00:00',
      'foto': 'https://i.pravatar.cc/300?img=45',
    },
    {
      'id': 4,
      'nama': 'Yuyun',
      'username': 'yuuuuyun',
      'email': 'Yuyun@gmail.com',
      'shift': 'Pagi',
      'jamKerja': '08:00 - 16:00',
      'foto': 'https://i.pravatar.cc/300?img=44',
    },
  ];

  void _confirmDeletePetugas(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi'),
        content: Text('Anda yakin ingin menghapus data petugas ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tidak'),
          ),
          TextButton(
            onPressed: () {
              _deletePetugas(id);
              Navigator.pop(context);
            },
            child: Text('Ya'),
          ),
        ],
      ),
    );
  }

  void _deletePetugas(int id) {
    setState(() {
      petugas.removeWhere((petugas) => petugas['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Petugas')),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(backgroundImagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView.builder(
          itemCount: petugas.length,
          itemBuilder: (context, index) => Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              elevation: 5,
              color: Colors.brown[800]?.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Foto Profil
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        image: DecorationImage(
                          image: NetworkImage(petugas[index]['foto']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),

                    // Data Petugas
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  petugas[index]['nama'],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              IconButton(
                                iconSize: 28,
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red[300],
                                ),
                                onPressed: () =>
                                    _confirmDeletePetugas(petugas[index]['id']),
                              ),
                            ],
                          ),

                          // Detail Informasi
                          _buildInfoRow('👤', petugas[index]['username']),
                          _buildInfoRow('📧', petugas[index]['email']),
                          _buildInfoRow(
                            '⏰',
                            'Shift ${petugas[index]['shift']} (${petugas[index]['jamKerja']})',
                          ),
                        ],
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

  Widget _buildInfoRow(String icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(icon, style: TextStyle(fontSize: 16)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
