import 'package:flutter/material.dart';
import 'pembayaran_page.dart'; // Pastikan path ini benar

class PesananMasukPage extends StatefulWidget {
  final List<Map<String, dynamic>> currentOrders;
  const PesananMasukPage({Key? key, required this.currentOrders}) : super(key: key);

  @override
  _PesananMasukPageState createState() => _PesananMasukPageState();
}

const String backgroundImagePath = 'assets/images/background.png';

class _PesananMasukPageState extends State<PesananMasukPage> {
  late List<Map<String, dynamic>> _displayOrders;

  @override
  void initState() {
    super.initState();
    // Inisialisasi daftar pesanan saat widget dibuat
    _displayOrders = List<Map<String, dynamic>>.from(widget.currentOrders);
  }

  @override
  void didUpdateWidget(covariant PesananMasukPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Perbarui daftar pesanan jika ada perubahan (misalnya, pesanan baru masuk)
    // atau jika ada perubahan pada detail pesanan yang ada (meskipun hanya ID yang dicek di sini)
    if (widget.currentOrders.length != oldWidget.currentOrders.length ||
        !_areOrderListsEqual(widget.currentOrders, oldWidget.currentOrders)) {
      setState(() {
        _displayOrders = List<Map<String, dynamic>>.from(widget.currentOrders);
      });
    }
  }

  // Helper untuk membandingkan daftar pesanan (untuk deteksi perubahan yang lebih akurat)
  bool _areOrderListsEqual(List<Map<String, dynamic>> list1, List<Map<String, dynamic>> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      // Bandingkan berdasarkan ID atau field unik lainnya
      if (list1[i]['id'] != list2[i]['id']) {
        return false;
      }
      // Opsional: Anda bisa membandingkan status juga untuk memicu rebuild jika hanya status yang berubah
      if (list1[i]['status'] != list2[i]['status']) {
        return false;
      }
    }
    return true;
  }

  // Metode ini dipanggil dari PembayaranPage setelah pembayaran berhasil
  void updateStatus(int id) {
    setState(() {
      final index = _displayOrders.indexWhere((p) => p['id'] == id);
      if (index != -1) {
        // Hanya ubah status jika masih "Baru" atau "Diproses"
        if (_displayOrders[index]['status'] == 'Baru' || _displayOrders[index]['status'] == 'Diproses') {
           _displayOrders[index]['status'] = 'Selesai'; // Ubah status menjadi 'Selesai'
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Masuk'),
        backgroundColor: Colors.brown[800],
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: _displayOrders.isEmpty
            ? Center(
                child: Text(
                  'Belum ada pesanan masuk.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.brown[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: _displayOrders.length,
                itemBuilder: (context, index) {
                  final order = _displayOrders[index];

                  // --- LOGIKA BARU DI SINI ---
                  final bool isOrderCompleted = order['status'] == 'Selesai';
                  // Tombol akan nonaktif jika isOrderCompleted true, aktif jika false
                  final VoidCallback? onPressedCallback = isOrderCompleted ? null : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PembayaranPage(
                          pesanan: order,
                          totalHarga: order['totalHarga'],
                          onPaymentConfirmed: () => updateStatus(order['id']),
                        ),
                      ),
                    );
                  };

                  // Warna latar belakang tombol
                  final Color buttonColor = isOrderCompleted ? Colors.grey[600]! : Colors.green[800]!;


                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  order['nama'],
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
                                  color: order['status'] == 'Baru'
                                      ? Colors.green[600]
                                      : order['status'] == 'Diproses'
                                          ? Colors.orange[600]
                                          : Colors.blue[600],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      order['status'] == 'Baru' ? Icons.fiber_new :
                                      order['status'] == 'Diproses' ? Icons.settings :
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      order['status'],
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
                          const Divider(height: 20, thickness: 1, color: Colors.white30),

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
                            children: (order['pesanan'] as List<dynamic>)
                                .map<Widget>(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Text(
                                      '• $item',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 15),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Waktu Pesanan:',
                                      style: TextStyle(fontSize: 13, color: Colors.white60),
                                    ),
                                    Text(
                                      order['waktu'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Total Pembayaran:',
                                    style: TextStyle(fontSize: 13, color: Colors.white60),
                                  ),
                                  Text(
                                    'Rp${order['totalHarga'].toStringAsFixed(0)}',
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

                          // --- MODIFIKASI HANYA PADA ELEVATEDBUTTON INI ---
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonColor, // Warna tombol dinamis
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 3,
                              ),
                              onPressed: onPressedCallback, // Fungsi onPressed dinamis
                              child: const Text(
                                'Proses Pembayaran', // Teks tetap sama
                                style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}