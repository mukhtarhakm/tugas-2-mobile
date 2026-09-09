// Tes sederhana untuk memastikan aplikasi bisa dijalankan dan
// halaman pertama yang muncul adalah halaman Login Kasir.

import 'package:flutter_test/flutter_test.dart';

import 'package:tugas_2_mobile/main.dart';

void main() {
  testWidgets('Aplikasi dimulai dari halaman Login Kasir', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Login Kasir'), findsOneWidget);
    expect(find.text('Username Kasir'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}

