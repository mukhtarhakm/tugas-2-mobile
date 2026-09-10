# Dokumentasi Teknis & Skenario Pengujian Aplikasi KasirKu

Dokumen ini berisi panduan teknis, pemetaan kriteria tugas, dan skenario pengujian (*test scenario*) untuk kebutuhan demo dan presentasi tugas mata kuliah Pemrograman Aplikasi Mobile.

---

## 1. Ikhtisar Aplikasi & Pemetaan Kriteria Tugas

**KasirKu** adalah aplikasi kasir mini berbasis Flutter/Dart yang dirancang untuk UMKM / kedai kopi. Seluruh operasi matematika dan fungsionalitas dibungkus ke dalam skenario kasir nyata:

| No | Kriteria Tugas Dosen | Implementasi Fitur KasirKu | Rute Halaman |
|---|---|---|---|
| 1 | **Menu Login (Username & Password)** | Autentikasi kasir (`admin` / `12345`), sanitasi `trim()`, proteksi `dispose()`. | `/login` |
| 2 | **Data Kelompok (3–4 Orang)** | Menampilkan profil 4 anggota kelompok (Nama & NIM) menggunakan `ListView`. | `/tim` |
| 3 | **Penjumlahan & Pengurangan Angka** | Akumulasi total belanja (+), perhitungan kembalian dan selisih (−). | `/transaksi` |
| 4 | **Perkalian & Pembagian Angka** | Subtotal pesanan (`harga × jumlah`), split bill (`subtotal ÷ orang`), proteksi bagi nol. | `/pesanan` |
| 5 | **Menu Input Bilangan = Ganjil/Genap** | Cek nomor meja restoran: **Ganjil $\rightarrow$ Zona A**, **Genap $\rightarrow$ Zona B**. | `/zonameja` |
| 6 | **Total Angka (Satu Field Input)** | Rekap nota harian: deretan harga dipisah koma `split(',')` dihitung total & rata-rata. | `/rekap` |

---

## 2. Penjelasan Arsitektur & Logika Teknis

### A. Autentikasi & Navigasi Terpusat (`login_page.dart`, `main.dart`, `tim_page.dart`)
- **`MaterialApp` & Named Routes**: Rute halaman didaftarkan secara terpusat di `main.dart` dengan `initialRoute: '/login'`.
- **Validasi Login**: Input dibersihkan dengan `trim()` untuk mengabaikan spasi tidak sengaja.
- **Pembersihan Memori**: Menggunakan `dispose()` pada setiap `TextEditingController` untuk mencegah *memory leak*.

### B. Format Rupiah & Operasi Hitung (+ / −) (`format.dart`, `transaksi_page.dart`)
- **`formatRupiah()`**: Mengonversi nilai `double` menjadi format mata uang Rupiah (`Rp 15.000`) dengan penanganan angka desimal dan batas aman hingga $10^{15}$.
- **Penjumlahan Akumulatif (+)**: Menjumlahkan Angka 1 + Angka 2, total otomatis masuk ke Angka 1 dan Angka 2 dikosongkan agar siap menerima angka berikutnya.
- **Pengurangan (−)**: Menghitung selisih $Angka_1 - Angka_2$ untuk kalkulasi kembalian belanja pelanggan.
- **Proteksi Angka Ekstrem**: Angka raksasa diproteksi agar tidak terpotong batas 64-bit integer.

### C. Logika Aritmatika (× / ÷) & Modulus (`pesanan_page.dart`, `zona_meja_page.dart`, `widget_test.dart`)
- **Perkalian (×)**: Menghitung subtotal pesanan pelanggan (`harga satuan × kuantitas`).
- **Pembagian (÷) & Proteksi Bagi Nol**: Pembagian tagihan *split bill* dengan proteksi `orang < 1` dan validasi wajib bilangan bulat.
- **Logika Modulus Meja**: Operator `% 2 != 0` membagi meja: **Ganjil $\rightarrow$ Zona A** dan **Genap $\rightarrow$ Zona B**.
- **Widget Testing**: Pengujian terotomatisasi pada `test/widget_test.dart` untuk memastikan halaman login tampil dengan benar.

### D. Pengolahan Data List & Perulangan (`rekap_nota_page.dart`, `menu_page.dart`)
- **Parsing String `split(',')`**: Memecah input harga belanja dalam satu field menjadi deretan angka.
- **Perulangan `for` & Filter `continue`**: Mengabaikan elemen kosong atau data invalid tanpa menghentikan kalkulasi.
- **Indikator Status Warna**:
  - ⬛ **Hitam**: Hasil kalkulasi sukses dan normal.
  - 🟠 **Oranye**: Peringatan jika ada item non-angka atau bernilai negatif yang diabaikan.
  - 🔴 **Merah**: Pesan error jika tidak ada angka valid sama sekali atau total melampaui batas (*overflow*).

---

## 3. Skenario Pengujian (Test Scenarios)

| No | Fitur / Halaman | Input Pengujian | Ekspektasi Hasil |
|---|---|---|---|
| 1 | **Login Sukses** | Username: `admin`, Password: `12345` | Berhasil login & masuk ke Menu Utama (`/menu`). |
| 2 | **Login Gagal** | Username: `kasir`, Password: `wrong` | Menampilkan pesan error validasi login merah. |
| 3 | **Penjumlahan (+)** | Angka 1: `50000`, Angka 2: `20000` | Hasil: `70.000 (Rp 70.000)`. Angka 1 otomatis ter-update jadi 70000. |
| 4 | **Pengurangan (−)** | Angka 1: `50000`, Angka 2: `20000` | Hasil: `30000 (Kembalian: Rp 30.000)`. |
| 5 | **Subtotal Pesanan (×)** | Harga: `15000`, Jumlah: `3` | Subtotal: `Rp 45.000`. |
| 6 | **Split Bill (÷)** | Subtotal: `45000`, Orang: `3` | Bayar per orang: `Rp 15.000`. |
| 7 | **Split Bill Nol / Pecahan** | Orang: `0` atau `0.5` | Muncul pesan error proteksi pembagian nol / wajib bilangan bulat. |
| 8 | **Zona Meja Ganjil** | Nomor Meja: `7` | Output: **Meja 7 (Ganjil) $\rightarrow$ Zona A**. |
| 9 | **Zona Meja Genap** | Nomor Meja: `12` | Output: **Meja 12 (Genap) $\rightarrow$ Zona B**. |
| 10 | **Rekap Nota Normal** | Input: `15000, 20000, 12500` | Total: `Rp 47.500`, Rata-rata: `Rp 15.833` (Teks Hitam). |
| 11 | **Rekap Nota Peringatan** | Input: `15000, abc, -5000, 20000` | 2 item dihitung, 2 item diabaikan (Teks Oranye). |

---

## 4. Cara Menjalankan Aplikasi

```bash
# 1. Unduh dependensi
flutter pub get

# 2. Periksa kualitas kode (wajib 0 issues)
flutter analyze

# 3. Jalankan pengujian widget
flutter test

# 4. Jalankan aplikasi di browser (Chrome) atau emulator
flutter run -d chrome
```
