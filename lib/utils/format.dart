// File ini berisi fungsi bantuan untuk mengubah angka menjadi teks rupiah.
// Sengaja dipisah supaya semua halaman memakai aturan format yang SAMA.
// Kalau aturannya berubah, cukup diubah di satu tempat ini saja.

/// Kelas untuk menangani bilangan desimal dengan presisi tak terbatas (BigInt).
/// Menghindari keterbatasan double (yang mentok dan memunculkan notasi ilmiah 'e').
class AngkaDesimal {
  final BigInt nilai;
  final int desimal; // Jumlah angka di belakang koma

  const AngkaDesimal(this.nilai, [this.desimal = 0]);

  static final AngkaDesimal zero = AngkaDesimal(BigInt.zero, 0);

  /// Membaca string teks (bisa pakai koma atau titik) menjadi AngkaDesimal.
  /// Mengembalikan null jika format tidak valid.
  static AngkaDesimal? tryParse(String teks) {
    final String bersih = teks.trim().replaceAll(',', '.');
    if (bersih.isEmpty) return null;

    final bool negatif = bersih.startsWith('-');
    final String tanpaTanda = (negatif || bersih.startsWith('+'))
        ? bersih.substring(1)
        : bersih;

    if (tanpaTanda.isEmpty) return null;

    final List<String> bagian = tanpaTanda.split('.');
    if (bagian.length > 2) return null;

    String bulat = bagian[0];
    String pecahan = bagian.length == 2 ? bagian[1] : '';

    if (bulat.isEmpty && pecahan.isEmpty) return null;

    final RegExp regexDigit = RegExp(r'^[0-9]+$');
    if (bulat.isNotEmpty && !regexDigit.hasMatch(bulat)) return null;
    if (pecahan.isNotEmpty && !regexDigit.hasMatch(pecahan)) return null;

    if (bulat.isEmpty) bulat = '0';

    final int jmlDesimal = pecahan.length;
    final String gabungan = '$bulat$pecahan';
    final BigInt? nilaiParsed = BigInt.tryParse(gabungan);
    if (nilaiParsed == null) return null;

    return AngkaDesimal(negatif ? -nilaiParsed : nilaiParsed, jmlDesimal);
  }

  bool get isNegatif => nilai < BigInt.zero;
  bool get isZero => nilai == BigInt.zero;
  bool get isPositif => nilai > BigInt.zero;

  /// Perkalian presisi tak terbatas: nilai dikalikan, jumlah desimal dijumlahkan.
  AngkaDesimal operator *(AngkaDesimal other) {
    return AngkaDesimal(nilai * other.nilai, desimal + other.desimal);
  }

  /// Pembagian dengan bilangan bulat (misal jumlah orang split bill).
  /// Menggunakan fixed-point BigInt dengan pembulatan half-up ke 2 desimal.
  AngkaDesimal bagiBulat(BigInt pembagi, {int presisi = 2}) {
    if (pembagi == BigInt.zero) {
      throw ArgumentError('Pembagi tidak boleh nol');
    }

    final bool negatifHasil = (nilai < BigInt.zero) ^ (pembagi < BigInt.zero);
    final BigInt absNilai = nilai.abs();
    final BigInt absPembagi = pembagi.abs();

    final int extraPresisi = presisi + 1;
    BigInt pembilang = absNilai;
    BigInt penyebut = absPembagi;

    if (extraPresisi >= desimal) {
      pembilang = pembilang * BigInt.from(10).pow(extraPresisi - desimal);
    } else {
      penyebut = penyebut * BigInt.from(10).pow(desimal - extraPresisi);
    }

    final BigInt hasilBagi = pembilang ~/ penyebut;
    final BigInt dibulatkan = (hasilBagi + BigInt.from(5)) ~/ BigInt.from(10);

    return AngkaDesimal(
      negatifHasil ? -dibulatkan : dibulatkan,
      presisi,
    );
  }

  /// Membulatkan ke 2 angka di belakang koma (half-up)
  AngkaDesimal bulatkanKe2Desimal() {
    if (desimal <= 2) return this;

    final bool negatif = nilai < BigInt.zero;
    final BigInt absNilai = nilai.abs();
    final int diff = desimal - 2;
    final BigInt faktor = BigInt.from(10).pow(diff - 1);
    final BigInt temp = absNilai ~/ faktor;
    final BigInt dibulatkan = (temp + BigInt.from(5)) ~/ BigInt.from(10);
    return AngkaDesimal(negatif ? -dibulatkan : dibulatkan, 2);
  }
}

/// Format teks rupiah untuk AngkaDesimal dengan panjang digit tak terbatas.
/// Menghilangkan simbol notasi ilmiah 'e' dan tidak memiliki batasan nominal.
String formatRupiahDesimal(AngkaDesimal angka) {
  final AngkaDesimal dibulatkan = angka.bulatkanKe2Desimal();
  final bool negatif = dibulatkan.isNegatif;
  final BigInt absNilai = dibulatkan.nilai.abs();

  String bagianBulat;
  String bagianDesimal;

  if (dibulatkan.desimal == 0) {
    bagianBulat = absNilai.toString();
    bagianDesimal = '00';
  } else {
    String str = absNilai.toString();
    if (str.length <= dibulatkan.desimal) {
      str = str.padLeft(dibulatkan.desimal + 1, '0');
    }
    bagianBulat = str.substring(0, str.length - dibulatkan.desimal);
    bagianDesimal = str.substring(str.length - dibulatkan.desimal);
    if (bagianDesimal.length == 1) {
      bagianDesimal = '${bagianDesimal}0';
    }
  }

  // Sisipkan titik sebagai pemisah ribuan dari kanan ke kiri
  String hasilBulat = '';
  int hitungDigit = 0;
  for (int i = bagianBulat.length - 1; i >= 0; i--) {
    hasilBulat = '${bagianBulat[i]}$hasilBulat';
    hitungDigit++;
    if (hitungDigit % 3 == 0 && i > 0) {
      hasilBulat = '.$hasilBulat';
    }
  }

  String hasil = hasilBulat;
  if (bagianDesimal != '00' && bagianDesimal.isNotEmpty) {
    hasil = '$hasilBulat,$bagianDesimal';
  }

  if (negatif) {
    hasil = '-$hasil';
  }

  return 'Rp $hasil';
}

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
