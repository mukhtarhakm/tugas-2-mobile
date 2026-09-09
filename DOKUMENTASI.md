# Dokumentasi Presentasi & Skenario Pengujian Aplikasi KasirKu

Dokumen ini berisi panduan skenario pengujian (test scenario) dan bahan penjelasan teknis untuk kebutuhan demo/presentasi tugas mata kuliah Mobile Programming.

---

## 1. Ikhtisar Aplikasi

**KasirKu** adalah aplikasi kasir mini berbasi Flutter yang dirancang untuk UMKM / Kafe. Aplikasi ini mencakup 5 fitur utama:
1. **Transaksi & Kembalian** — Menghitung total belanja dan kembalian pembayaran.
2. **Hitung Pesanan & Split Bill** — Menghitung subtotal item dan pembagian tagihan per orang.
3. **Cek Zona Meja** — Membagi lokasi meja pelanggan ke Zona A (Genap) atau Zona B (Ganjil).
4. **Rekap Nota Harian** — Mengolah daftar harga item satu nota dengan penanganan error & peringatan.
5. **Tentang Tim Pengembang** — Informasi aplikasi dan anggota kelompok pengembang.

---

## 2. Fitur & Penjelasan Kode per Anggota

### Anggota 1: Autentikasi & Navigasi Utama (`login_page.dart`, `main.dart`, `tim_page.dart`)
- **`MaterialApp` & Named Routes**: Rute aplikasi terdaftar secara terpusat di `main.dart` dengan `initialRoute: '/login'`.
- **Validasi Login**: Input dites menggunakan `trim()` untuk mengabaikan spasi tak sengaja. Jika username/password salah, pesan error ditampilkan.
- **Pemberihan State**: Penggunaan `dispose()` pada `TextEditingController` untuk mencegah memory leak.

### Anggota 2: Utilities Format & Transaksi Pembayaran (`format.dart`, `transaksi_page.dart`)
- **`formatRupiah()`**: Konversi nilai `double` atau `int` menjadi format mata uang Rupiah (`Rp 15.000`).
- **Penanganan Uang Kurang**: Membandingkan uang yang dibayarkan dengan total transaksi, memberikan peringatan jika uang kurang.
- **Pemeriksaan `isFinite`**: Mencegah nilai tak terhingga (infinity) merusak UI.

### Anggota 3: Logika Aritmatika & Zona (`pesanan_page.dart`, `zona_meja_page.dart`, `widget_test.dart`)
- **Split Bill & Pembagian**: Perkalian (subtotal) dan pembagian tagihan per orang dengan proteksi pembagian dengan nol.
- **Modulus Meja**: Penentuan zona meja menggunakan operator modulus `% 2 == 0` (Genap = Zona A, Ganjil = Zona B).
- **Pengujian Widget**: Pengujian terotomatisasi pada `test/widget_test.dart` untuk menguji render awal halaman login.

### Anggota 4: Pengolahan Daftar, Perulangan & Navigasi (`rekap_nota_page.dart`, `menu_page.dart`)
- **`split(',')` & Perulangan `for`**: Menguraikan teks harga item yang dipisahkan koma menjadi daftar angka.
- **Pengabaian Item Invalid (`continue`)**: Elemen kosong atau bernilai negatif diabaikan dari kalkulasi utama tanpa menghentikan aplikasi.
- **Indikator Warna Status**:
  - 🔴 **Merah**: Error total jika tidak ada input valid.
  - 🟠 **Oranye**: Peringatan jika ada item non-angka / negatif yang diabaikan.
  - ⬛ **Hitam**: Hasil kalkulasi sukses.

---

## 3. Skenario Pengujian (Test Scenarios)

| No | Fitur / Halaman | Input Pengujian | Ekspektasi Hasil |
|---|---|---|---|
| 1 | **Login** | Username: `admin`, Password: `12345` | Berhasil login & berpindah ke Halaman Menu Utama (`/menu`). |
| 2 | **Login Fail** | Username: `user`, Password: `wrong` | Menampilkan pesan error validasi login gagal. |
| 3 | **Transaksi** | Total: `50000`, Uang Bayar: `100000` | Kembalian: `Rp 50.000`. |
| 4 | **Transaksi Kurang** | Total: `50000`, Uang Bayar: `20000` | Menampilkan pesan error: Uang pembayaran kurang. |
| 5 | **Split Bill** | Total: `120000`, Jumlah Orang: `4` | Bayar per orang: `Rp 30.000`. |
| 6 | **Split Bill Nol** | Total: `120000`, Jumlah Orang: `0` | Menampilkan pesan peringatan: Jumlah orang tidak boleh 0. |
| 7 | **Cek Zona Meja** | Nomor Meja: `12` | Meja 12 masuk ke **Zona A** (Genap). |
| 8 | **Cek Zona Meja** | Nomor Meja: `7` | Meja 7 masuk ke **Zona B** (Ganjil). |
| 9 | **Rekap Nota** | Input: `15000, 20000, 12500` | Total: `Rp 47.500`, Rata-rata: `Rp 15.833`. Warna teks Hitam. |
| 10 | **Rekap Nota (Peringatan)**| Input: `15000, abc, -5000, 20000` | 2 item dihitung, item `abc` & `-5000` diabaikan. Teks Oranye. |

---

## 4. Cara Menjalankan Aplikasi

1. Unduh dependensi:
   ```bash
   flutter pub get
   ```
2. Jalankan pemeriksaan kode:
   ```bash
   flutter analyze
   ```
3. Jalankan pengujian widget:
   ```bash
   flutter test
   ```
4. Jalankan aplikasi di browser (Chrome) atau emulator:
   ```bash
   flutter run -d chrome
   ```
