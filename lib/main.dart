// import 'package:flutter/material.dart';
// import 'login_screen.dart'; // Import halaman login Anda
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Inventory App',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         // Perbaikan: Tambahkan 'ColorScheme' sebelum '.fromSeed'
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
//         useMaterial3: true,
//       ),
//       // Perbaikan: Ubah home agar mengarah ke LoginScreen
//       home: LoginScreen(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart'; // Import Dashboard

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // VARIABEL BYPASS: Ubah ke true jika ingin melewati login
    bool bypassLogin = true;

    // Data dummy agar Dashboard tidak error saat bypass
    Map<String, dynamic> dummyUser = {
      "user_id": "P001",
      "nama_lengkap": "Developer Mode",
      "role_tp": "01",
      "jabatan": "SUPER ADMIN"
    };

    return MaterialApp(
      title: 'Inventory App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Jika bypass true, langsung ke Dashboard. Jika false, ke Login.
      home: bypassLogin ? DashboardScreen(userData: dummyUser) : LoginScreen(),
    );
  }
}
