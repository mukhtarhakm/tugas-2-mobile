# KasirKu — Aplikasi Kasir Mini UMKM

Tugas mata kuliah Pemrograman Aplikasi Mobile. KasirKu membantu kasir UMKM/kafe kecil
menghitung total belanja, kembalian, subtotal pesanan, split bill, dan rekap nota harian
tanpa mengandalkan hitungan manual di kertas.

Dibangun murni dengan **Flutter/Dart bawaan** — tanpa package eksternal, tanpa database,
tanpa API, state hanya memakai `setState()`.

## Fitur

- **Login Kasir** — autentikasi sederhana (username `admin`, password `12345`)
- **Transaksi & Kembalian** — hitung kembalian, tambah item belanja
- **Pesanan & Split Bill** — subtotal pesanan, bagi tagihan per orang
- **Cek Zona Meja** — bagi meja ke Zona A (ganjil) / Zona B (genap)
- **Rekap Nota Harian** — total dan rata-rata harga banyak item sekaligus
- **Tentang Tim Pengembang** — profil aplikasi dan anggota kelompok

## Cara Menjalankan

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

Login dengan username `admin` dan password `12345`.

Dokumentasi lengkap (tabel pemetaan kriteria tugas, skenario pengujian, dan penjelasan
alur logika tiap halaman) ada di [DOKUMENTASI.md](DOKUMENTASI.md).
Pembagian tugas commit antar anggota kelompok ada di [PEMBAGIAN_TUGAS.md](PEMBAGIAN_TUGAS.md).
