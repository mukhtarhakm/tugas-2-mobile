import 'package:flutter/material.dart';

import '../utils/format.dart';

// Halaman ini menangani PERKALIAN (harga satuan x jumlah pesanan)
// dan PEMBAGIAN (subtotal dibagi jumlah orang / split bill).
class PesananPage extends StatefulWidget {
  const PesananPage({super.key});

  @override
  State<PesananPage> createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _orangController = TextEditingController();

  // Subtotal disimpan di state karena tombol split bill membutuhkan
  // hasil dari tombol sebelumnya. Nilainya null selama subtotal
  // belum pernah dihitung, dan itulah yang dipakai untuk pengecekan.
  double? _subtotal;

  // Satu variabel untuk teks hasil, dua bool sebagai penanda status.
  String _hasil = '';
  bool _adaError = false;
  bool _adaPeringatan = false;

  @override
  void dispose() {
    // Ketiga controller wajib dibuang saat halaman ditutup.
    _hargaController.dispose();
    _jumlahController.dispose();
    _orangController.dispose();
    super.dispose();
  }

  // Fungsi bantu mengubah teks menjadi double, null kalau tidak valid.
  double? _bacaNominal(String teks) {
    // Koma diubah jadi titik karena Dart hanya mengenal titik sebagai
    // pemisah desimal, dan trim() membuang spasi di awal/akhir.
    final String bersih = teks.trim().replaceAll(',', '.');

    // tryParse mengembalikan null saat gagal, sehingga aplikasi tidak
    // crash ketika kasir mengetik "abc", "12a", atau "1.2.3".
    return double.tryParse(bersih);
  }

  // TOMBOL 1: subtotal = harga satuan x jumlah pesanan (PERKALIAN).
  void _hitungSubtotal() {
    final String teksHarga = _hargaController.text.trim();
    final String teksJumlah = _jumlahController.text.trim();

    if (teksHarga.isEmpty || teksJumlah.isEmpty) {
      _tampilkanPesan('Harga satuan dan jumlah pesanan harus diisi', true, false);
      return;
    }

    final double? harga = _bacaNominal(teksHarga);
    final double? jumlah = _bacaNominal(teksJumlah);

    if (harga == null || jumlah == null) {
      _tampilkanPesan('Input harus berupa angka yang valid', true, false);
      return;
    }

    if (harga < 0) {
      _tampilkanPesan('Harga tidak boleh negatif', true, false);
      return;
    }

    // Pesanan nol atau negatif tidak mungkin terjadi di kasir,
    // jadi ditolak sebelum dikalikan.
    if (jumlah <= 0) {
      _tampilkanPesan('Jumlah pesanan minimal 1', true, false);
      return;
    }

    final double subtotal = harga * jumlah;

    // Perkalian dua angka raksasa bisa menghasilkan Infinity.
    // Dicek supaya layar tidak menampilkan tulisan "Infinity".
    if (!subtotal.isFinite) {
      _tampilkanPesan('Nominal terlalu besar untuk dihitung', true, false);
      return;
    }

    // Subtotal disimpan ke state agar bisa dipakai tombol split bill.
    setState(() {
      _subtotal = subtotal;
    });
    _tampilkanPesan('Subtotal: ${formatRupiah(subtotal)}', false, false);
  }

  // TOMBOL 2: split bill = subtotal / jumlah orang (PEMBAGIAN).
  void _hitungSplitBill() {
    // Split bill hanya masuk akal kalau subtotalnya sudah ada,
    // jadi urutan kerjanya dipaksa: hitung subtotal dulu.
    final double? subtotal = _subtotal;
    if (subtotal == null) {
      _tampilkanPesan('Hitung subtotal terlebih dahulu', true, false);
      return;
    }

    final String teksOrang = _orangController.text.trim();

    // Kolom kosong disamakan dengan nol, karena keduanya membuat
    // pembagian tidak bisa dilakukan.
    if (teksOrang.isEmpty) {
      _tampilkanPesan(
        'Jumlah orang untuk split bill tidak boleh nol',
        true,
        false,
      );
      return;
    }

    final double? orang = _bacaNominal(teksOrang);
    if (orang == null) {
      _tampilkanPesan('Input harus berupa angka yang valid', true, false);
      return;
    }

    // PEMBAGIAN DENGAN NOL dicek SEBELUM dibagi. Kalau tidak dicek,
    // Dart menghasilkan Infinity yang tidak berarti apa-apa bagi kasir.
    if (orang == 0) {
      _tampilkanPesan(
        'Jumlah orang untuk split bill tidak boleh nol',
        true,
        false,
      );
      return;
    }

    if (orang < 0) {
      _tampilkanPesan('Jumlah orang minimal 1', true, false);
      return;
    }

    final double perOrang = subtotal / orang;

    if (!perOrang.isFinite) {
      _tampilkanPesan('Nominal terlalu besar untuk dihitung', true, false);
      return;
    }

    _tampilkanPesan(
      'Subtotal: ${formatRupiah(subtotal)}\n'
      'Bayar per orang: ${formatRupiah(perOrang)}',
      false,
      false,
    );
  }

  // Tombol Reset: mengosongkan semua kolom, hasil, dan subtotal tersimpan.
  void _reset() {
    _hargaController.text = '';
    _jumlahController.text = '';
    _orangController.text = '';
    // Subtotal ikut dihapus supaya split bill tidak memakai
    // sisa hitungan transaksi sebelumnya.
    setState(() {
      _subtotal = null;
    });
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
      appBar: AppBar(title: const Text('Perkalian & Pembagian')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _hargaController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Harga Satuan (Rp)',
                hintText: 'contoh: 15000',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _jumlahController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Jumlah Pesanan',
                hintText: 'contoh: 3',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _hitungSubtotal,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Hitung Subtotal'),
              ),
            ),
            const Divider(height: 32),
            TextField(
              controller: _orangController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Jumlah Orang (Split Bill)',
                hintText: 'contoh: 2',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _hitungSplitBill,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Hitung Split Bill'),
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
