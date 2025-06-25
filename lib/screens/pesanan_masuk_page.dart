import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pembayaran_page.dart';

class PesananMasukPage extends StatefulWidget {
  final List<Map<String, dynamic>> currentOrders;
  const PesananMasukPage({Key? key, required this.currentOrders})
    : super(key: key);

  @override
  _PesananMasukPageState createState() => _PesananMasukPageState();
}

const String backgroundImagePath = 'assets/images/background.png';

class _PesananMasukPageState extends State<PesananMasukPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Masuk'),
        backgroundColor: Colors.brown[800],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pesanan')
            .orderBy(
              'tanggalPesan',
              descending: true,
            ) // Urutkan berdasarkan tanggal pesan terbaru
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada pesanan masuk.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.brown,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final doc = orders[index];
              final data = doc.data() as Map<String, dynamic>;

              final nama = data['namaPemesan']?.toString() ?? 'Tanpa Nama';
              final tanggalStr = data['tanggalPesan']?.toString() ?? '';
              final items = (data['items'] as List?) ?? [];
              final totalHarga = data['totalHarga'] ?? 0;
              final status =
                  data['status'] ??
                  'Baru'; // fallback jika tidak ada field status
              final isOrderCompleted = status == 'Selesai';

              // Format tanggal
              String formatTanggal(String input) {
                try {
                  final date = DateTime.parse(input);
                  return '${date.day}-${date.month}-${date.year} ${date.hour}:${date.minute}';
                } catch (e) {
                  return '-';
                }
              }

              final buttonColor = isOrderCompleted
                  ? Colors.grey[600]!
                  : Colors.green[800]!;

              final onPressedCallback = isOrderCompleted
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PembayaranPage(
                            docId: doc.id,
                            totalHarga: totalHarga,
                            onPaymentConfirmed: () async {
                              await FirebaseFirestore.instance
                                  .collection('pesanan')
                                  .doc(doc.id)
                                  .update({'status': 'Selesai'});
                            },
                          ),
                        ),
                      );
                    };

              return Card(
                margin: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 4.0,
                ),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.brown[700]?.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama dan status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              nama,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: status == 'Baru'
                                  ? Colors.green[600]
                                  : status == 'Diproses'
                                  ? Colors.orange[600]
                                  : Colors.blue[600],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  status == 'Baru'
                                      ? Icons.fiber_new
                                      : status == 'Diproses'
                                      ? Icons.settings
                                      : Icons.check_circle,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Divider(
                        height: 20,
                        thickness: 1,
                        color: Colors.white30,
                      ),

                      const Text(
                        'Detail Pesanan:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: items.map<Widget>((item) {
                          final namaItem = item['nama'] ?? 'Item';
                          final jumlah = item['jumlah'] ?? 1;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              '• $namaItem (x$jumlah)',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 15),

                      // Waktu dan total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Waktu Pesanan:',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white60,
                                ),
                              ),
                              Text(
                                formatTanggal(tanggalStr),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Total Pembayaran:',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white60,
                                ),
                              ),
                              Text(
                                'Rp${totalHarga.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[300],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 3,
                          ),
                          onPressed: onPressedCallback,
                          child: const Text(
                            'Proses Pembayaran',
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
