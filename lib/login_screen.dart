import 'package:flutter/material.dart';
import 'api_service.dart'; // Perbaikan: Sesuaikan jalur import
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller untuk menangkap input teks
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Key untuk validasi form
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  // Fungsi untuk memproses login
  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Memanggil fungsi login di ApiService dengan parameter 'u' dan 'p'
        // sesuai dengan Api.php di backend CI3
        final result = await ApiService().login(
            _usernameController.text,
            _passwordController.text
        );

        if (result['status'] == true) {
          // Jika login sukses, arahkan ke Dashboard dan bawa data user
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardScreen(userData: result['data']),
            ),
          );
        } else {
          // Menampilkan pesan error dari server (contoh: "Kata sandi salah")
          _showSnackBar(result['message'], isError: true);
        }
      } catch (e) {
        _showSnackBar("Gagal terhubung ke server. Pastikan URL API benar.", isError: true);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  // Fungsi untuk mengetes koneksi ke endpoint ping di Api.php
  void _handleTestConnection() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    final result = await ApiService().testConnection();
    Navigator.pop(context); // Tutup loading dialog

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(result['status'] ? "Koneksi Sukses" : "Koneksi Gagal"),
        content: Text(result['message']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo atau Icon Aplikasi
                Icon(Icons.inventory_2_rounded, size: 80, color: Colors.blue),
                SizedBox(height: 16),
                Text(
                  "Inventory System",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
                ),
                SizedBox(height: 32),

                // Input Username
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: "Username",
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) => value!.isEmpty ? "Username tidak boleh kosong" : null,
                ),
                SizedBox(height: 16),

                // Input Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) => value!.isEmpty ? "Password tidak boleh kosong" : null,
                ),
                SizedBox(height: 24),

                // Tombol Login
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading
                      ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text("LOGIN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),

                SizedBox(height: 12),

                // Tombol Tes Koneksi
                TextButton.icon(
                  onPressed: _handleTestConnection,
                  icon: Icon(Icons.settings_ethernet, size: 18),
                  label: Text("Cek Koneksi ke Server"),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}