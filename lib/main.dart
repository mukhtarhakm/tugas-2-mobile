import 'package:flutter/material.dart';

// Setiap halaman ditulis di file terpisah supaya mudah dicari,
// dan supaya file ini isinya hanya pengaturan aplikasi + daftar route.
import 'pages/login_page.dart';
import 'pages/pesanan_page.dart';
import 'pages/rekap_nota_page.dart';
import 'pages/tim_page.dart';
import 'pages/transaksi_page.dart';
import 'pages/zona_meja_page.dart';

// main() adalah titik awal program Dart.
// runApp() memasang widget paling atas (MyApp) ke layar.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KasirKu - Aplikasi Kasir Mini UMKM',
      // Banner "DEBUG" dimatikan supaya tampilan bersih saat demo di kelas.
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Warna coklat dipilih karena aplikasi ini untuk kafe/UMKM kopi.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
        // AppBar diberi warna tetap supaya judul halaman terlihat jelas
        // dan seragam di semua halaman.
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.brown,
          foregroundColor: Colors.white,
        ),
      ),
      // Aplikasi selalu dimulai dari halaman login kasir.
      initialRoute: '/login',
      // Named routes: perpindahan halaman cukup menyebut nama route-nya,
      // tidak perlu menulis ulang widget tujuan di setiap tombol.
      routes: <String, WidgetBuilder>{
        '/login': (BuildContext context) => const LoginPage(),
        '/transaksi': (BuildContext context) => const TransaksiPage(),
        '/pesanan': (BuildContext context) => const PesananPage(),
        '/zonameja': (BuildContext context) => const ZonaMejaPage(),
        '/rekap': (BuildContext context) => const RekapNotaPage(),
        '/tim': (BuildContext context) => const TimPage(),
      },
    );
  }
}
