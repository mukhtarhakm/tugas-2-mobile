import 'package:flutter/material.dart';

// Halaman ini isinya tetap (tidak pernah berubah saat aplikasi berjalan),
// jadi memakai StatelessWidget dan tidak butuh setState sama sekali.
class TimPage extends StatelessWidget {
  const TimPage({super.key});

  // Data anggota disimpan sebagai List<Map<String, String>> langsung di file
  // ini supaya mudah diganti: cukup edit nama dan NIM di bawah ini.
  // GANTI placeholder berikut dengan data anggota kelompok yang sebenarnya.
  static const List<Map<String, String>> _anggota = <Map<String, String>>[
    <String, String>{'nama': 'M. Eufrat Ayyash', 'nim': '124240092'},
    <String, String>{'nama': 'Rais Mukhtar Hakim', 'nim': '124240107'},
    <String, String>{'nama': 'Novaldo Putra Nugraha', 'nim': '124240110'},
    <String, String>{'nama': 'Loddy Luvian Nugraha', 'nim': '124240120'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Tim Pengembang')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          // Card paling atas berisi deskripsi aplikasi, sehingga halaman ini
          // sekaligus berfungsi sebagai halaman "About".
          const Card(
            color: Color(0xFFF3E5D8),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'KasirKu - Aplikasi Kasir Mini UMKM',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Banyak kafe dan UMKM kecil masih menghitung total belanja, '
                    'kembalian, dan rekap harian secara manual di kertas '
                    'sehingga rawan salah hitung. KasirKu membantu kasir '
                    'menghitung semuanya dengan cepat dan menampilkan rekap '
                    'nota yang rapi tanpa perlu alat tambahan.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Anggota Kelompok:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          // Daftar anggota dibuat dengan perulangan for biasa supaya
          // jumlah Card otomatis mengikuti jumlah data di atas.
          for (int i = 0; i < _anggota.length; i++)
            Card(
              child: ListTile(
                // i + 1 supaya nomor urut mulai dari 1, bukan 0.
                leading: CircleAvatar(child: Text('${i + 1}')),
                // Map bisa mengembalikan null kalau key-nya tidak ada,
                // karena itu dipakai '??' sebagai nilai cadangan (null-safety).
                title: Text(
                  _anggota[i]['nama'] ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('NIM: ${_anggota[i]['nim'] ?? '-'}'),
              ),
            ),
        ],
      ),
    );
  }
}
