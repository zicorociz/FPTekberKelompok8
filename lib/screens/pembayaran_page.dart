import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'nota_page.dart';

const String backgroundImagePath = 'assets/images/background.png';

class PembayaranPage extends StatelessWidget {
  final String docId;
  final int totalHarga;
  final VoidCallback onPaymentConfirmed;

  PembayaranPage({
    required this.docId,
    required this.totalHarga,
    required this.onPaymentConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('pesanan').doc(docId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(body: Center(child: Text("Pesanan tidak ditemukan")));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final pesananList =
            (data['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];

        return Scaffold(
          appBar: AppBar(title: Text('Pembayaran'), centerTitle: true),
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(backgroundImagePath),
                fit: BoxFit.cover,
              ),
            ),
            padding: EdgeInsets.all(20),
            child: Card(
              color: Colors.brown[800]?.withOpacity(0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Metode Pembayaran:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    ListTile(
                      leading: Icon(Icons.account_balance, color: Colors.white),
                      title: Text(
                        'Transfer Bank',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: Icon(Icons.wallet, color: Colors.white),
                      title: Text(
                        'E-Wallet',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {},
                    ),
                    Divider(color: Colors.brown[400]),
                    SizedBox(height: 10),
                    Text(
                      'Pesanan:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Column(
                      children: List<Widget>.from(
                        pesananList.map<Widget>((menu) {
                          return ListTile(
                            leading: Icon(Icons.coffee, color: Colors.white),
                            title: Text(
                              '${menu['nama']} x${menu['jumlah']} - ${menu['harga']}',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }),
                      ),
                    ),
                    Divider(color: Colors.brown[400]),
                    SizedBox(height: 10),
                    Text(
                      'Total Harga: Rp$totalHarga',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[800],
                          padding: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                        ),
                        onPressed: () {
                          onPaymentConfirmed();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotaPage(
                                pesanan: data,
                                totalHarga: totalHarga,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Konfirmasi Pembayaran',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
