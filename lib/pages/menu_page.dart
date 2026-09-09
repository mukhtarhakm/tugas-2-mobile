import 'package:flutter/material.dart';

// Halaman menu hanya menampilkan tombol navigasi dan tidak menyimpan
// data apa pun, jadi cukup StatelessWidget (tidak butuh setState).
class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  // Fungsi kecil ini dibuat supaya bentuk tombol menu tidak ditulis
  // berulang-ulang sebanyak lima kali.
  Widget _tombolMenu(
    BuildContext context,
    IconData ikon,
    String judul,
    String keterangan,
    String route,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(ikon, color: Colors.brown),
        title: Text(judul, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(keterangan),
        trailing: const Icon(Icons.chevron_right),
        // pushNamed (bukan pushReplacementNamed) supaya kasir bisa
        // kembali ke menu dengan tombol back.
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KasirKu - Menu Utama'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            // pushReplacementNamed dipakai agar halaman menu dibuang.
            // Kalau memakai pushNamed, kasir yang sudah logout masih bisa
            // menekan back dan kembali masuk ke menu.
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Selamat bertugas, Kasir!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text('Pilih menu yang ingin digunakan:'),
            const SizedBox(height: 16),
            _tombolMenu(
              context,
              Icons.calculate,
              'Penjumlahan & Pengurangan',
              'Operasi hitung tambah (+) dan kurang (−) angka',
              '/transaksi',
            ),
            _tombolMenu(
              context,
              Icons.receipt_long,
              'Hitung Pesanan & Split Bill',
              'Subtotal pesanan dan bagi bayar per orang',
              '/pesanan',
            ),
            _tombolMenu(
              context,
              Icons.table_restaurant,
              'Cek Zona Meja',
              'Bagi meja ke Zona A / Zona B',
              '/zonameja',
            ),
            _tombolMenu(
              context,
              Icons.summarize,
              'Rekap Nota Harian',
              'Total dan rata-rata harga item dalam satu nota',
              '/rekap',
            ),
            _tombolMenu(
              context,
              Icons.groups,
              'Tentang Tim Pengembang',
              'Profil aplikasi dan anggota kelompok',
              '/tim',
            ),
          ],
        ),
      ),
    );
  }
}
