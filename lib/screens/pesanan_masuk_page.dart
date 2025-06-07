import 'pembayaran_page.dart';
import 'package:flutter/material.dart';

class PesananMasukPage extends StatefulWidget {
  @override
  _PesananMasukPageState createState() => _PesananMasukPageState();
}

const String backgroundImagePath =
    'https://images.unsplash.com/photo-1650292386081-fed5cb55d588?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
const Color coffeeGreen = Colors.green;

class _PesananMasukPageState extends State<PesananMasukPage> {
  List<Map<String, dynamic>> pesanan = [
    {
      'id': 1,
      'nama': 'Rian',
      'pesanan': ['Coffee Latte', 'Matcha'],
      'waktu': '10:30 AM',
      'status': 'Baru',
    },
    {
      'id': 2,
      'nama': 'Sinta',
      'pesanan': ['Espresso', 'Cappuccino'],
      'waktu': '11:00 AM',
      'status': 'Diproses',
    },
  ];

  void updateStatus(int id) {
    setState(() {
      final index = pesanan.indexWhere((p) => p['id'] == id);
      if (index != -1) {
        pesanan[index]['status'] = 'Diproses';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pesanan Masuk')),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(backgroundImagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView.builder(
          itemCount: pesanan.length,
          itemBuilder: (context, index) => Container(
            margin: EdgeInsets.all(12),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.brown[800]?.withOpacity(0.8),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          pesanan[index]['nama'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: pesanan[index]['status'] == 'Baru'
                                ? Colors.green[800]
                                : Colors.orange[800],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.fiber_new,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 5),
                              Text(
                                pesanan[index]['status'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Pesanan:',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    Column(
                      children: pesanan[index]['pesanan']
                          .map<Widget>(
                            (item) => Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                '• $item',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Waktu: ${pesanan[index]['waktu']}',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[800],
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PembayaranPage(
                                pesanan: pesanan[index],
                                totalHarga: 50000,
                                onPaymentConfirmed: () =>
                                    updateStatus(pesanan[index]['id']),
                              ),
                            ),
                          ),
                          child: Text(
                            'Bayar',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
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
