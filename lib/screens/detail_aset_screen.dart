import 'package:flutter/material.dart';
import '../api_service.dart';

class DetailAsetScreen extends StatefulWidget {
  final String assetId;
  final String assetName;

  DetailAsetScreen({required this.assetId, required this.assetName});

  @override
  _DetailAsetScreenState createState() => _DetailAsetScreenState();
}

class _DetailAsetScreenState extends State<DetailAsetScreen> {
  Map<String, dynamic>? _mainData;
  List<dynamic> _attributes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  void _fetchDetail() async {
    final result = await ApiService().getAssetDetail(widget.assetId);
    if (result['status'] == true) {
      setState(() {
        _mainData = result['data'];
        _attributes = result['attributes'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      // Tampilkan error jika perlu
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.assetName)),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian 1: Info Utama
            _buildSectionTitle("Informasi Utama"),
            _buildDetailRow("Kode Aset", _mainData?['asset_kd']),
            _buildDetailRow("Nama Aset", _mainData?['asset_nm']),
            _buildDetailRow("Kategori", _mainData?['kategori_nm']),
            _buildDetailRow("Kondisi", _mainData?['asset_kondisi']),
            _buildDetailRow("Satuan", _mainData?['satuan_nm']),

            SizedBox(height: 24),

            // Bagian 2: Atribut Khusus (EAV)
            _buildSectionTitle("Spesifikasi Detail"),
            _attributes.isEmpty
                ? Text("Tidak ada spesifikasi tambahan", style: TextStyle(fontStyle: FontStyle.italic))
                : Column(
              children: _attributes.map((attr) {
                return _buildDetailRow(attr['atribut_label'], attr['value_isi']);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text("$label:", style: TextStyle(fontWeight: FontWeight.w500))),
          Expanded(flex: 3, child: Text(value ?? "-", style: TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }
}