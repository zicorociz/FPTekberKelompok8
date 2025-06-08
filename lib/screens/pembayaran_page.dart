import 'package:flutter/material.dart';
import 'nota_page.dart';

class PembayaranPage extends StatelessWidget {
  final Map<String, dynamic> pesanan;
  final int totalHarga;
  final VoidCallback onPaymentConfirmed;

  PembayaranPage({
    required this.pesanan,
    required this.totalHarga,
    required this.onPaymentConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pembayaran')),
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
                  children: pesanan['pesanan']
                      .map<Widget>(
                        (item) => ListTile(
                          leading: Icon(Icons.coffee, color: Colors.white),
                          title: Text(
                            item,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                      .toList(),
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
                            pesanan: pesanan,
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
  }
}

const String backgroundImagePath =
    'assets/images/background.png';
