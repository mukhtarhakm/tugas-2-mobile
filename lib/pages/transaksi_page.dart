import 'package:flutter/material.dart';

import '../utils/format.dart';

// Halaman ini menangani PENJUMLAHAN (tambah item) dan
// PENGURANGAN (uang dibayar - total belanja = kembalian).
class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _bayarController = TextEditingController();

  // Satu variabel untuk teks yang ditampilkan, dua bool sebagai status.
  // Status inilah yang menentukan warna teks: merah, oranye, atau hitam.
  String _hasil = '';
  bool _adaError = false;
  bool _adaPeringatan = false;

  @override
  void dispose() {
    // Setiap controller wajib dibuang agar tidak membebani memori.
    _totalController.dispose();
    _bayarController.dispose();
    super.dispose();
  }

  // Fungsi bantu untuk mengubah teks menjadi double.
  // Mengembalikan null kalau teksnya bukan angka yang valid.
  double? _bacaNominal(String teks) {
    // Kasir sering mengetik koma sebagai pemisah desimal, padahal Dart
    // hanya mengerti titik. Jadi koma diubah dulu menjadi titik.
    // trim() membuang spasi di awal/akhir agar " 15000 " tetap terbaca.
    final String bersih = teks.trim().replaceAll(',', '.');

    // tryParse dipakai (bukan parse) karena tryParse mengembalikan null
    // saat gagal, sedangkan parse melempar error dan aplikasi berhenti.
    // Teks seperti "abc", "12a", atau "1.2.3" otomatis menghasilkan null.
    return double.tryParse(bersih);
  }

  // Pengecekan yang sama dipakai oleh kedua tombol, jadi dikumpulkan
  // di satu fungsi supaya tidak ditulis dua kali.
  // Mengembalikan true kalau kedua input sudah aman untuk dihitung.
  bool _inputValid(double? total, double? bayar, bool adaYangKosong) {
    if (adaYangKosong) {
      _tampilkanPesan('Total belanja dan uang dibayar harus diisi', true, false);
      return false;
    }
    if (total == null || bayar == null) {
      _tampilkanPesan('Nominal harus berupa angka yang valid', true, false);
      return false;
    }
    if (total < 0 || bayar < 0) {
      _tampilkanPesan('Nominal tidak boleh bernilai negatif', true, false);
      return false;
    }
    // Nominal raksasa (misalnya 1e400) dibaca Dart sebagai Infinity.
    // Dicek di sini supaya hasilnya tidak berupa tulisan "Infinity".
    if (!total.isFinite || !bayar.isFinite) {
      _tampilkanPesan('Nominal terlalu besar untuk dihitung', true, false);
      return false;
    }
    return true;
  }

  // TOMBOL 1: kembalian = uang dibayar - total belanja (PENGURANGAN).
  void _hitungKembalian() {
    final String teksTotal = _totalController.text.trim();
    final String teksBayar = _bayarController.text.trim();

    final double? total = _bacaNominal(teksTotal);
    final double? bayar = _bacaNominal(teksBayar);

    if (!_inputValid(total, bayar, teksTotal.isEmpty || teksBayar.isEmpty)) {
      return;
    }

    // Setelah _inputValid bernilai true, kedua angka pasti tidak null.
    // Tanda "!" memberi tahu Dart hal itu agar aturan null-safety terpenuhi.
    final double totalBelanja = total!;
    final double uangDibayar = bayar!;

    // Menghitung kembalian dari total nol tidak masuk akal bagi kasir,
    // karena artinya belum ada barang yang dibeli.
    if (totalBelanja == 0) {
      _tampilkanPesan('Total belanja tidak boleh nol', true, false);
      return;
    }

    // Uang kurang bukan kesalahan input, melainkan kondisi transaksi.
    // Selisihnya dihitung terbalik (total - bayar) agar tampil positif.
    if (uangDibayar < totalBelanja) {
      final double kurang = totalBelanja - uangDibayar;
      _tampilkanPesan(
        'Uang tidak cukup, kurang ${formatRupiah(kurang)}',
        true,
        false,
      );
      return;
    }

    final double kembalian = uangDibayar - totalBelanja;
    _tampilkanPesan('Kembalian: ${formatRupiah(kembalian)}', false, false);
  }

  // TOMBOL 2: total belanja + nominal item baru (PENJUMLAHAN).
  void _tambahItem() {
    final String teksTotal = _totalController.text.trim();
    final String teksItem = _bayarController.text.trim();

    final double? total = _bacaNominal(teksTotal);
    final double? item = _bacaNominal(teksItem);

    if (!_inputValid(total, item, teksTotal.isEmpty || teksItem.isEmpty)) {
      return;
    }

    // Di sini total nol TIDAK dilarang, karena kasir yang baru mulai
    // mencatat nota memang berangkat dari total 0 lalu menambah item.
    final double totalBaru = total! + item!;

    if (!totalBaru.isFinite) {
      _tampilkanPesan('Nominal terlalu besar untuk dihitung', true, false);
      return;
    }

    // Hasil penjumlahan langsung ditulis kembali ke kolom Total Belanja
    // supaya kasir bisa menambah item berikutnya tanpa mengetik ulang.
    // Kolom kedua dikosongkan agar siap diisi nominal item selanjutnya.
    if (totalBaru == totalBaru.roundToDouble()) {
      // Kalau hasilnya bilangan bulat, ".0" dibuang supaya kolom input
      // tidak menampilkan "50000.0" yang membingungkan kasir.
      _totalController.text = totalBaru.toStringAsFixed(0);
    } else {
      _totalController.text = totalBaru.toString();
    }
    _bayarController.text = '';

    _tampilkanPesan(
      'Item ditambahkan. Total belanja: ${formatRupiah(totalBaru)}',
      false,
      false,
    );
  }

  // Tombol Reset: mengosongkan semua kolom dan teks hasil.
  void _reset() {
    _totalController.text = '';
    _bayarController.text = '';
    _tampilkanPesan('', false, false);
  }

  // Semua perubahan tampilan dikumpulkan di satu fungsi supaya setState
  // hanya ditulis sekali dan tidak ada status yang lupa diperbarui.
  void _tampilkanPesan(String pesan, bool error, bool peringatan) {
    setState(() {
      _hasil = pesan;
      _adaError = error;
      _adaPeringatan = peringatan;
    });
  }

  // Warna teks ditentukan dari status: merah untuk error,
  // oranye untuk peringatan, hitam untuk hasil normal.
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
      appBar: AppBar(title: const Text('Transaksi & Kembalian')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _totalController,
              // signed: true agar tanda minus bisa diketik (untuk diuji),
              // decimal: true agar titik/koma desimal muncul di keyboard.
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Total Belanja (Rp)',
                hintText: 'contoh: 35000',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bayarController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Uang Dibayar (Rp)',
                hintText: 'dipakai juga sebagai nominal item baru',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _hitungKembalian,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Hitung Kembalian'),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _tambahItem,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Tambah Item'),
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
