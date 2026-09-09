import 'package:flutter/material.dart';

// Halaman login memakai StatefulWidget karena isinya bisa berubah:
// pesan error muncul dan hilang tergantung apa yang diketik kasir.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controller dipakai untuk membaca isi TextField.
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Username dan password sengaja ditulis langsung di kode (hardcoded)
  // karena aplikasi ini belum memakai database atau server.
  static const String _usernameBenar = 'admin';
  static const String _passwordBenar = '12345';

  // Di halaman ini pesan yang muncul selalu berupa error,
  // jadi cukup satu variabel teks tanpa penanda status.
  String _pesan = '';

  @override
  void dispose() {
    // Controller wajib dibuang saat halaman ditutup supaya tidak
    // terus memakai memori (memory leak).
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _prosesLogin() {
    // trim() membuang spasi di awal dan akhir. Tanpa ini, "admin " akan
    // dianggap berbeda dari "admin" sehingga login selalu gagal.
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    // Pengecekan kosong didahulukan supaya kasir tahu persis
    // bagian mana yang belum diisi.
    if (username.isEmpty && password.isEmpty) {
      setState(() {
        _pesan = 'Username kasir dan password tidak boleh kosong';
      });
      return;
    }
    if (username.isEmpty) {
      setState(() {
        _pesan = 'Username kasir tidak boleh kosong';
      });
      return;
    }
    if (password.isEmpty) {
      setState(() {
        _pesan = 'Password tidak boleh kosong';
      });
      return;
    }

    if (username == _usernameBenar && password == _passwordBenar) {
      // pushReplacementNamed dipakai (bukan pushNamed) supaya halaman login
      // dihapus dari tumpukan. Kasir yang sudah masuk tidak boleh bisa
      // menekan tombol back dan kembali ke layar login.
      Navigator.pushReplacementNamed(context, '/menu');
      return;
    }

    setState(() {
      _pesan = 'Username atau password kasir salah';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Kasir')),
      // SingleChildScrollView mencegah error "RenderFlex overflowed"
      // saat keyboard muncul dan ruang layar menjadi sempit.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 24),
            const Icon(Icons.local_cafe, size: 72, color: Colors.brown),
            const SizedBox(height: 16),
            const Text(
              'KasirKu',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Aplikasi Kasir Mini UMKM',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username Kasir',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              // obscureText menyembunyikan karakter password.
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _prosesLogin,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Masuk'),
              ),
            ),
            const SizedBox(height: 16),
            // Pesan error tampil merah. Kalau _pesan masih kosong,
            // Text ini otomatis tidak terlihat karena tidak ada isinya.
            Text(
              _pesan,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
