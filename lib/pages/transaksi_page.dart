import 'package:flutter/material.dart';

import '../utils/format.dart';

// Halaman ini menangani menu PENJUMLAHAN (+) dan PENGURANGAN (-) angka,
// yang dapat difungsikan sebagai kalkulator umum maupun simulasi transaksi kasir.
class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  final TextEditingController _angka1Controller = TextEditingController();
  final TextEditingController _angka2Controller = TextEditingController();

  String _hasil = '';
  bool _adaError = false;

  @override
  void dispose() {
    _angka1Controller.dispose();
    _angka2Controller.dispose();
    super.dispose();
  }

  // Fungsi bantu untuk mengubah teks menjadi double.
  // Mengembalikan null kalau teksnya bukan angka yang valid.
  double? _bacaNominal(String teks) {
    final String bersih = teks.trim().replaceAll(',', '.');
    return double.tryParse(bersih);
  }

  // Helper untuk format teks angka biasa tanpa notasi ilmiah 'e'
  String _formatAngka(double nilai) {
    if (!nilai.isFinite) return nilai.toString();

    final String s = nilai.toString();

    // Jika tidak ada notasi ilmiah 'e', cukup buang akhiran '.0'
    if (!s.toLowerCase().contains('e')) {
      if (s.endsWith('.0')) {
        return s.substring(0, s.length - 2);
      }
      return s;
    }

    // Jika ada notasi ilmiah 'e', ubah menjadi angka biasa (tanpa 'e')
    final List<String> parts = s.toLowerCase().split('e');
    final String basis = parts[0];
    final int eksponen = int.tryParse(parts[1]) ?? 0;

    if (eksponen > 0) {
      final int dotIndex = basis.indexOf('.');
      if (dotIndex == -1) {
        return basis + ('0' * eksponen);
      } else {
        final String depan = basis.substring(0, dotIndex);
        final String belakang = basis.substring(dotIndex + 1);
        if (eksponen >= belakang.length) {
          return depan + belakang + ('0' * (eksponen - belakang.length));
        } else {
          return '$depan${belakang.substring(0, eksponen)}.${belakang.substring(eksponen)}';
        }
      }
    }

    return s;
  }

  bool _inputValid(double? angka1, double? angka2, bool adaYangKosong) {
    if (adaYangKosong) {
      _tampilkanPesan('Angka pertama dan angka kedua harus diisi', true);
      return false;
    }
    if (angka1 == null || angka2 == null) {
      _tampilkanPesan('Input harus berupa angka yang valid', true);
      return false;
    }
    if (!angka1.isFinite || !angka2.isFinite) {
      _tampilkanPesan('Nominal terlalu besar untuk dihitung', true);
      return false;
    }
    return true;
  }

  // OPERASI PENJUMLAHAN: Angka 1 + Angka 2
  void _hitungPenjumlahan() {
    final String teks1 = _angka1Controller.text.trim();
    final String teks2 = _angka2Controller.text.trim();

    final double? a1 = _bacaNominal(teks1);
    final double? a2 = _bacaNominal(teks2);

    if (!_inputValid(a1, a2, teks1.isEmpty || teks2.isEmpty)) {
      return;
    }

    final double angka1 = a1!;
    final double angka2 = a2!;
    final double total = angka1 + angka2;

    if (!total.isFinite) {
      _tampilkanPesan('Hasil terlalu besar untuk dihitung', true);
      return;
    }

    // Hasil penjumlahan otomatis di-update ke Field 1, dan Field 2 dikosongkan
    // agar pengguna bisa langsung menambah angka berikutnya (akumulator).
    _angka1Controller.text = _formatAngka(total);
    _angka2Controller.clear();

    _tampilkanPesan(
      'Hasil Penjumlahan (+):\n'
      '${_formatAngka(angka1)} + ${_formatAngka(angka2)} = ${_formatAngka(total)}\n'
      '(${formatRupiah(total)})\n'
      '✓ Total otomatis masuk ke Angka Pertama',
      false,
    );
  }

  // OPERASI PENGURANGAN: Angka 1 - Angka 2
  void _hitungPengurangan() {
    final String teks1 = _angka1Controller.text.trim();
    final String teks2 = _angka2Controller.text.trim();

    final double? a1 = _bacaNominal(teks1);
    final double? a2 = _bacaNominal(teks2);

    if (!_inputValid(a1, a2, teks1.isEmpty || teks2.isEmpty)) {
      return;
    }

    final double angka1 = a1!;
    final double angka2 = a2!;
    final double selisih = angka1 - angka2;

    if (!selisih.isFinite) {
      _tampilkanPesan('Hasil terlalu besar untuk dihitung', true);
      return;
    }

    String catatanKasir = '';
    if (selisih >= 0) {
      catatanKasir = 'Kembalian: ${formatRupiah(selisih)}';
    } else {
      catatanKasir = 'Catatan Kasir: Kurang ${formatRupiah(selisih.abs())}';
    }

    _tampilkanPesan(
      'Hasil Pengurangan (−):\n'
      '${_formatAngka(angka1)} − ${_formatAngka(angka2)} = ${_formatAngka(selisih)}\n'
      '($catatanKasir)',
      false,
    );
  }

  void _reset() {
    _angka1Controller.clear();
    _angka2Controller.clear();
    _tampilkanPesan('', false);
  }

  void _tampilkanPesan(String pesan, bool error) {
    setState(() {
      _hasil = pesan;
      _adaError = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Penjumlahan & Pengurangan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Card(
              color: Colors.brown.shade50,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  '💡 Masukkan dua angka untuk melakukan operasi matematika '
                  'penjumlahan (+) atau pengurangan (−). '
                  'Dapat difungsikan juga untuk simulasi transaksi kasir (Belanja & Bayar).',
                  style: TextStyle(fontSize: 13, color: Colors.brown),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _angka1Controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Angka Pertama (contoh: 50000)',
                hintText: 'Masukkan angka pertama / total belanja',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.looks_one_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _angka2Controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Angka Kedua (contoh: 20000)',
                hintText: 'Masukkan angka kedua / nominal item',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.looks_two_outlined),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _hitungPenjumlahan,
                    icon: const Icon(Icons.add),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Penjumlahan (+)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _hitungPengurangan,
                    icon: const Icon(Icons.remove),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Pengurangan (−)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset'),
            ),
            const SizedBox(height: 24),
            if (_hasil.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _adaError ? Colors.red.shade50 : Colors.brown.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _adaError ? Colors.red.shade200 : Colors.brown.shade300,
                  ),
                ),
                child: Text(
                  _hasil,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _adaError ? Colors.red.shade800 : Colors.black87,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
