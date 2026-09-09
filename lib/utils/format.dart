// File ini berisi fungsi bantuan untuk mengubah angka menjadi teks rupiah.
// Sengaja dipisah supaya semua halaman memakai aturan format yang SAMA.
// Kalau aturannya berubah, cukup diubah di satu tempat ini saja.

/// Mengubah angka (double) menjadi teks rupiah, contoh: 15000 -> "Rp 15.000".
///
/// Ditulis manual tanpa package intl supaya tidak menambah dependensi
/// dan supaya setiap langkahnya bisa dijelaskan satu per satu.
String formatRupiah(double nilai) {
  // LANGKAH 1: jaga-jaga untuk nilai aneh.
  // Perhitungan ekstrem (misalnya angka raksasa) bisa menghasilkan
  // Infinity atau NaN. Kalau tidak dicek, layar akan menampilkan
  // tulisan "Infinity" yang membingungkan kasir.
  if (nilai.isNaN || nilai.isInfinite) {
    return 'Rp -';
  }

  // LANGKAH 2: pisahkan tanda minus dulu.
  // Pemisah ribuan lebih mudah dihitung kalau angkanya positif,
  // jadi tandanya disimpan sebentar dan dipasang lagi di akhir.
  final bool negatif = nilai < 0;
  final double angka = nilai.abs();

  // LANGKAH 3: batasi nominal yang terlalu besar.
  // Di atas 1.000 triliun, Dart menuliskan angka dalam notasi ilmiah
  // (contoh "1e+21") sehingga tidak bisa diberi pemisah ribuan.
  // Dibatasi di sini supaya aplikasi tidak error.
  if (angka >= 1000000000000000) {
    return 'Rp (nominal terlalu besar)';
  }

  // LANGKAH 4: bulatkan ke 2 angka di belakang koma.
  // toStringAsFixed(2) selalu menghasilkan bentuk "15833.33",
  // jadi posisi titiknya pasti ada dan mudah dipisah.
  final String teks = angka.toStringAsFixed(2);

  // LANGKAH 5: potong menjadi bagian bulat dan bagian desimal.
  // indexOf mencari posisi titik, substring memotong teksnya.
  final int posisiTitik = teks.indexOf('.');
  final String bagianBulat = teks.substring(0, posisiTitik);
  final String bagianDesimal = teks.substring(posisiTitik + 1);

  // LANGKAH 6: sisipkan titik sebagai pemisah ribuan.
  // Dihitung dari KANAN ke kiri (i dikurangi terus), karena aturan
  // ribuan memang dihitung dari digit paling belakang.
  // Setiap 3 digit ditambahkan titik, kecuali kalau sudah di digit paling depan
  // (syarat i > 0), supaya hasilnya tidak menjadi ".150.000".
  String hasilBulat = '';
  int hitungDigit = 0;
  for (int i = bagianBulat.length - 1; i >= 0; i--) {
    hasilBulat = '${bagianBulat[i]}$hasilBulat';
    hitungDigit++;
    if (hitungDigit % 3 == 0 && i > 0) {
      hasilBulat = '.$hasilBulat';
    }
  }

  // LANGKAH 7: pasang bagian desimal hanya kalau memang ada isinya.
  // Uang Rp 15.000 tidak perlu ditulis "Rp 15.000,00",
  // tetapi Rp 15.833,33 tetap butuh koma dan 2 digit di belakangnya.
  String hasil = hasilBulat;
  if (bagianDesimal != '00') {
    hasil = '$hasilBulat,$bagianDesimal';
  }

  // LANGKAH 8: kembalikan tanda minus (kalau tadi angkanya negatif)
  // lalu tambahkan awalan "Rp ".
  if (negatif) {
    hasil = '-$hasil';
  }
  return 'Rp $hasil';
}
