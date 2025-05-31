import 'package:flutter/material.dart';

class LayananPage extends StatelessWidget {
  const LayananPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        // Membuat body bisa scroll vertikal
        child: Column(
          children: <Widget>[
            // Gambar header dan tombol layanan
            Column(
              children: [
                // Gambar header
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/car_wash_image.jpg',
                      ), // Pastikan kamu menambahkan gambar ke dalam folder assets
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Layanan buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Tombol Home Service
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue, // Warna teks putih
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                            ), // Peningkatan padding vertikal
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                8,
                              ), // Mengurangi radius lengkungan
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/home_service_icon.png', // Gambar icon Home Service
                                width: 40,
                                height: 40,
                              ),
                              const SizedBox(height: 8),
                              const Text('Home Service'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10), // Spasi antara tombol
                      // Tombol Wireless
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            backgroundColor: Colors.white, // Warna teks biru
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                            ), // Peningkatan padding vertikal
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                8,
                              ), // Mengurangi radius lengkungan
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets//images/Icon_blue.png', // Gambar icon Wireless
                                width: 40,
                                height: 40,
                              ),
                              const SizedBox(height: 8),
                              const Text('Wireless'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Pilihan mobil dan harga
            ListView(
              shrinkWrap:
                  true, // Membuat ListView bisa di-scroll tanpa mempengaruhi ukuran parent
              children: [
                // Motor Beat
                ListTile(
                  leading: Radio(
                    value: 'Motor Beat',
                    groupValue: 'selected',
                    onChanged: (value) {},
                  ),
                  title: const Text('Motor Beat'),
                  subtitle: const Text('Small'),
                  trailing: const Text('Rp 55.000'),
                ),
                const Divider(),

                // Mobil Avanza
                ListTile(
                  leading: Radio(
                    value: 'Mobil Avanza',
                    groupValue: 'selected',
                    onChanged: (value) {},
                  ),
                  title: const Text('Mobil Avanza'),
                  subtitle: const Text('Medium'),
                  trailing: const Text('Rp 89.000'),
                ),
                const Divider(),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aksi saat tombol ditekan (misalnya menambah kendaraan)
        },
        child: const Icon(Icons.add), // Tanda plus di dalam button
        backgroundColor: const Color.fromARGB(
          255,
          255,
          255,
          255,
        ), // Warna button
      ),
    );
  }
}
