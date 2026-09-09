import 'package:flutter/material.dart';

// Halaman ini memakai logika GANJIL/GENAP untuk membagi meja:
// nomor meja ganjil masuk Zona A, nomor genap masuk Zona B.
// Tujuannya agar beban pelayan terbagi merata di dua zona.
//
// Halaman ini TIDAK memakai formatRupiah karena nomor meja
// bukan nominal uang, jadi ditampilkan sebagai angka biasa.
class ZonaMejaPage extends StatefulWidget {
  const ZonaMejaPage({super.key});

  @override
  State<ZonaMejaPage> createState() => _ZonaMejaPageState();
}

class _ZonaMejaPageState extends State<ZonaMejaPage> {
  final TextEditingController _mejaController = TextEditingController();

  String _hasil = '';
  bool _adaError = false;
  bool _adaPeringatan = false;

  @override
  void dispose() {
    _mejaController.dispose();
    super.dispose();
  }

  void _cekZona() {
    // Spasi dibuang, dan koma diubah jadi titik supaya input "4,5"
    // tetap terbaca sebagai bilangan desimal (lalu ditolak di bawah).
    final String teks = _mejaController.text.trim().replaceAll(',', '.');

    if (teks.isEmpty) {
      _tampilkanPesan('Masukkan nomor meja terlebih dahulu', true, false);
      return;
    }

    // Urutan pengecekan sengaja bertahap agar pesan errornya tepat sasaran:
    // 1) bukan angka, 2) angka tapi desimal, 3) di luar jangkauan int,
    // 4) nol atau negatif.
    final double? sebagaiDesimal = double.tryParse(teks);
    if (sebagaiDesimal == null) {
      _tampilkanPesan('Nomor meja harus berupa bilangan bulat', true, false);
      return;
    }

    // Kalau mengandung titik berarti kasir mengetik angka desimal,
    // padahal nomor meja tidak mungkin 4.5.
    if (teks.contains('.')) {
      _tampilkanPesan('Nomor meja tidak boleh berupa angka desimal', true, false);
      return;
    }

    // int.tryParse mengembalikan null kalau angkanya di luar jangkauan int
    // (misalnya 30 digit), sehingga aplikasi tidak crash.
    final int? nomor = int.tryParse(teks);
    if (nomor == null) {
      _tampilkanPesan('Nomor meja tidak valid', true, false);
      return;
    }

    // Nomor meja di kafe selalu dimulai dari 1, jadi nol dan bilangan
    // negatif ditolak di sini.
    if (nomor <= 0) {
      _tampilkanPesan('Nomor meja harus lebih besar dari 0', true, false);
      return;
    }

    // Dipakai "% 2 != 0" untuk ganjil, BUKAN "% 2 == 1".
    // Alasannya: sisa bagi bilangan negatif tidak selalu bernilai 1,
    // sehingga "== 1" bisa salah membaca. Bentuk "!= 0" selalu aman.
    if (nomor % 2 != 0) {
      _tampilkanPesan('Meja $nomor (Ganjil) -> Zona A', false, false);
    } else {
      _tampilkanPesan('Meja $nomor (Genap) -> Zona B', false, false);
    }
  }

  // Tombol Reset: mengosongkan kolom dan teks hasil.
  void _reset() {
    _mejaController.text = '';
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
      appBar: AppBar(title: const Text('Bilangan Ganjil / Genap')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Nomor meja ganjil dilayani di Zona A, '
              'nomor meja genap dilayani di Zona B.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _mejaController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Nomor Meja',
                hintText: 'contoh: 7',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _cekZona,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Cek Zona'),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _reset, child: const Text('Reset')),
            const SizedBox(height: 24),
            Text(
              _hasil,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
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
