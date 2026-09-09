import 'package:flutter/material.dart';

import '../utils/format.dart';

// Halaman ini merekap satu nota: kasir mengetik semua harga item
// sekaligus, lalu aplikasi menghitung jumlah item, total, dan rata-rata.
class RekapNotaPage extends StatefulWidget {
  const RekapNotaPage({super.key});

  @override
  State<RekapNotaPage> createState() => _RekapNotaPageState();
}

class _RekapNotaPageState extends State<RekapNotaPage> {
  final TextEditingController _daftarController = TextEditingController();

  // Satu variabel teks hasil, dua bool sebagai status
  // (merah untuk error, oranye untuk peringatan, hitam untuk hasil normal).
  String _hasil = '';
  bool _adaError = false;
  bool _adaPeringatan = false;

  @override
  void dispose() {
    _daftarController.dispose();
    super.dispose();
  }

  void _hitungRekap() {
    final String teks = _daftarController.text.trim();

    if (teks.isEmpty) {
      _tampilkanPesan('Masukkan minimal satu harga item', true, false);
      return;
    }

    // split(',') memecah teks menjadi potongan berdasarkan koma.
    // Di halaman ini koma berperan sebagai PEMISAH ITEM, jadi desimal
    // harus ditulis memakai titik (contoh: 12500.5).
    final List<String> potongan = teks.split(',');

    // Tiga daftar disiapkan: harga yang sah, item yang bukan angka,
    // dan item yang harganya negatif. Item bermasalah tidak membatalkan
    // perhitungan, hanya dilaporkan sebagai peringatan.
    final List<double> hargaValid = <double>[];
    final List<String> bukanAngka = <String>[];
    final List<String> hargaNegatif = <String>[];

    for (int i = 0; i < potongan.length; i++) {
      final String item = potongan[i].trim();

      // Bagian kosong muncul kalau kasir mengetik "1,2,," atau "1,,2".
      // Bagian seperti ini dilewati saja, bukan dianggap error.
      if (item.isEmpty) {
        continue;
      }

      final double? harga = double.tryParse(item);

      // Nilai null berarti bukan angka. Nilai tak hingga muncul kalau
      // angkanya terlalu besar, dan itu juga tidak layak dihitung.
      if (harga == null || !harga.isFinite) {
        bukanAngka.add(item);
      } else if (harga < 0) {
        // Harga barang tidak mungkin negatif, jadi item ini dibuang
        // tetapi tetap dilaporkan supaya kasir sadar ada salah ketik.
        hargaNegatif.add(item);
      } else {
        hargaValid.add(harga);
      }
    }

    // Kalau tidak ada satu pun harga yang sah, rata-rata tidak bisa dihitung
    // karena pembaginya nol. Karena itu prosesnya dihentikan di sini.
    // Inilah yang mencegah terjadinya pembagian dengan nol di bawah.
    if (hargaValid.isEmpty) {
      _tampilkanPesan('Tidak ada harga item yang valid', true, false);
      return;
    }

    // Total dijumlahkan satu per satu dengan perulangan biasa.
    double total = 0;
    for (int i = 0; i < hargaValid.length; i++) {
      total = total + hargaValid[i];
    }

    // Pembagian di bawah ini aman karena panjang daftar sudah dipastikan
    // lebih dari nol pada pengecekan sebelumnya.
    final double rataRata = total / hargaValid.length;

    // Hasil disusun menjadi tiga baris dalam satu variabel teks.
    String pesan =
        'Jumlah Item : ${hargaValid.length}\n'
        'Total Nota  : ${formatRupiah(total)}\n'
        'Rata-rata   : ${formatRupiah(rataRata)}';

    // Peringatan hanya ditambahkan kalau memang ada item yang dibuang.
    // join(', ') menggabungkan daftar teks menjadi satu kalimat.
    bool adaPeringatan = false;
    if (bukanAngka.isNotEmpty) {
      adaPeringatan = true;
      pesan =
          '${hargaValid.length} item dihitung, '
          '${bukanAngka.length} item diabaikan karena bukan angka: '
          '${bukanAngka.join(', ')}\n\n$pesan';
    }
    if (hargaNegatif.isNotEmpty) {
      adaPeringatan = true;
      pesan =
          '${hargaNegatif.length} item diabaikan karena harga negatif: '
          '${hargaNegatif.join(', ')}\n\n$pesan';
    }

    _tampilkanPesan(pesan, false, adaPeringatan);
  }

  // Tombol Reset: mengosongkan kolom dan teks hasil.
  void _reset() {
    _daftarController.text = '';
    _tampilkanPesan('', false, false);
  }

  void _tampilkanPesan(String pesan, bool error, bool peringatan) {
    setState(() {
      _hasil = pesan;
      _adaError = error;
      _adaPeringatan = peringatan;
    });
  }

  Color _warnaHasil() {
    if (_adaError) {
      return Colors.red;
    }
    if (_adaPeringatan) {
      return Colors.orange;
    }
    return Colors.black87;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rekap Nota Harian')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Ketik semua harga item dalam satu nota, pisahkan dengan koma.\n'
              'Gunakan titik untuk desimal, contoh: 12500.5',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _daftarController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Daftar Harga Item (pisahkan dengan koma)',
                hintText: 'contoh: 15000, 20000, 12500',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _hitungRekap,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Hitung Rekap'),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _reset, child: const Text('Reset')),
            const SizedBox(height: 24),
            Text(
              _hasil,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _warnaHasil(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
