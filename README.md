# FPTekberKelompok8
NgopiPay: Aplikasi POS Sederhana sebagai Solusi Kasir Digital 

# 📌 Anggota Kelompok 8
- Talitha Firyal Ghina Nuha - 5026221031
- Nida Aulia Amartika - 5026221095
- Zikrul Khalis - 5026221132
- Edward - 5026221091

## Fitur Utama

- **Manajemen Transaksi**: Catat penjualan dengan mudah dan cepat.
- **Manajemen Produk**: Tambah, ubah, dan hapus produk sesuai kebutuhan toko.
- **Riwayat Transaksi**: Lihat riwayat transaksi untuk memudahkan pelaporan.
- **User Friendly**: Antarmuka sederhana dan mudah digunakan oleh kasir.
- **Multi Platform**: Dikembangkan menggunakan Flutter (Dart), dengan dukungan pada berbagai platform.

## Teknologi yang Digunakan

- **Dart / Flutter**: Untuk pengembangan aplikasi inti (74.1%)
- **Firebase/Firestore**: Untuk backend dan penyimpanan data secara real-time
- **HTML**: Untuk tampilan web sederhana
- **Lainnya**: Berbagai dependensi minor

## Instalasi & Menjalankan Aplikasi

### Prasyarat

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Git](https://git-scm.com/)
- **[Android Emulator](https://developer.android.com/studio/run/emulator) (opsional untuk testing Android)**
- **[Android Emulator Extension for Chrome](https://chrome.google.com/webstore/detail/android-emulator/jjndjgheafjngoipoacpjgeicjeomjli) (opsional, untuk menjalankan emulator Android langsung di Chrome)**
    - Extension ini memungkinkan Anda menjalankan dan menguji aplikasi Android langsung di browser Chrome, tanpa perlu Android Studio.

### Langkah Instalasi

1. **Clone repository ini:**
    ```bash
    git clone https://github.com/zicorociz/FPTekberKelompok8.git
    cd FPTekberKelompok8
    ```
    
2. **Install dependencies:**
    ```bash
    flutter pub get
    ```

3. **Jalankan aplikasi:**
    ```bash
    flutter run
    ```

    **Catatan Mendetail:**
    - Jika Anda ingin menjalankan aplikasi di Chrome (web), pastikan ekstensi [Android Emulator Extension for Chrome](https://chrome.google.com/webstore/detail/android-emulator/jjndjgheafjngoipoacpjgeicjeomjli) sudah terpasang (jika ingin testing Android di browser).
    - Setelah menjalankan `flutter run`, akan muncul daftar device yang tersedia. Misalnya:
      ```
      1. Chrome (web)
      2. Edge (web)
      3. Android emulator
      4. iOS simulator
      q. Quit (terminate the app)
      ```
    - **Pilih angka sesuai device yang diinginkan**, misalnya `1` untuk Chrome, atau `3` untuk Android Emulator.
        - Untuk memilih Chrome, ketik `1` lalu tekan `Enter`.
        - Untuk menjalankan di Android Emulator Extension (Chrome), pastikan sudah mengaktifkan extension, lalu pilih device Android Emulator yang muncul pada daftar.
    - Jika ingin menjalankan di perangkat fisik, pastikan perangkat sudah terhubung via USB dan USB debugging sudah aktif.
    - Untuk menjalankan di Android Emulator Extension, pastikan:
        - Chrome sudah terpasang extension Android Emulator.
        - Pilih device Android Emulator yang tersedia pada daftar device setelah `flutter run`.

Aplikasi dapat dijalankan pada emulator Android/iOS, browser (Chrome/Edge), atau langsung pada perangkat fisik.

## Kontribusi

Kontribusi sangat terbuka! Silakan buat _pull request_ atau _issue_ jika menemukan bug atau ingin menambah fitur baru.

---

NgopiPay – Solusi kasir digital, mudah dan efisien untuk bisnis Anda!
