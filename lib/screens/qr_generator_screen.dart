import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../api_service.dart';

class QrGeneratorScreen extends StatefulWidget {
  @override
  _QrGeneratorScreenState createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  List<dynamic> _assets = [];
  Map<String, dynamic>? _selectedAsset;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAssets();
  }

  void _fetchAssets() async {
    final result = await ApiService().getAssets();
    if (result['status'] == true) {
      setState(() {
        _assets = result['data'];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Generate QR Aset"), elevation: 2),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // PERBAIKAN: Penambahan tipe data eksplisit pada DropdownMenuItem
            DropdownButtonFormField<Map<String, dynamic>>(
              decoration: InputDecoration(
                  labelText: "Pilih Aset",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory)
              ),
              value: _selectedAsset,
              items: _assets.map((asset) {
                // Pastikan item dikonversi menjadi Map<String, dynamic> secara eksplisit
                final Map<String, dynamic> item = asset as Map<String, dynamic>;
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: item,
                  child: Text(item['asset_nm']),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedAsset = val),
            ),

            SizedBox(height: 40),

            if (_selectedAsset != null) ...[
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                          "SKU: ${_selectedAsset!['asset_kd']}",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                      ),
                      SizedBox(height: 20),
                      QrImageView(
                        data: _selectedAsset!['asset_kd'],
                        version: QrVersions.auto,
                        size: 250.0,
                        backgroundColor: Colors.white,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Gunakan QR ini untuk ditempel pada barang",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}