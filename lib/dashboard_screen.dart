import 'package:flutter/material.dart';
import 'api_service.dart';

import 'screens/aset_screen.dart';
import 'screens/list_screen.dart';
import 'screens/transaksi_screen.dart';
import 'screens/layanan_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/qr_generator_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  DashboardScreen({required this.userData});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _summary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // Mengambil data ringkasan dari M_dashboard di backend
  void _loadDashboardData() async {
    final result = await ApiService().getDashboard();
    if (result['status'] == true) {
      setState(() {
        _summary = result['summary'];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'), // Skenario logout sederhana
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian 1: Header Selamat Datang
            Text(
              "Halo, ${widget.userData['nama_lengkap']}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text("Role: ${widget.userData['jabatan']}", style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 24),

            // Bagian 2: Statistik (Stat Cards)
            Text("Ringkasan Statistik", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Row(
              children: [
                _buildStatCard("Total Aset", _summary?['total_asset_types'].toString() ?? "0", Colors.blue),
                // _buildStatCard("Total Unit", _summary?['total_assets'].toString() ?? "0", Colors.green),
                // _buildStatCard("Terpakai", _summary?['total_in_use'].toString() ?? "0", Colors.orange),
              ],
            ),
            SizedBox(height: 32),

            // Bagian 3: Menu Utama (Grid Menu)
            Text("Menu Utama", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildMenuButton(context, "Aset", Icons.inventory_2, Colors.indigo, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AsetScreen()));
                }),
                _buildMenuButton(context, "List", Icons.format_list_bulleted, Colors.teal, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ListScreen()));
                }),
                _buildMenuButton(context, "Transaksi", Icons.swap_horizontal_circle, Colors.amber[800]!, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => TransaksiScreen()));
                }),
                _buildMenuButton(context, "Layanan Aset", Icons.build_circle, Colors.redAccent, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LayananScreen()));
                }),
                _buildMenuButton(context, "Scan QR", Icons.qr_code_scanner, Colors.purple, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => QrScannerScreen()));
                }),
                _buildMenuButton(context, "Buat QR", Icons.qr_code, Colors.deepOrange, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => QrGeneratorScreen()));
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk Kartu Statistik
  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              SizedBox(height: 4),
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk Tombol Menu Utama
  Widget _buildMenuButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}