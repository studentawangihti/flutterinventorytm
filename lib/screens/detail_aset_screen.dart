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
  final _apiService = ApiService();
  bool _isLoading = true;
  bool _isEditing = false; // Status mode edit

  Map<String, dynamic>? _rawDetail;
  List<dynamic> _attributes = [];

  // Controller untuk input
  late TextEditingController _nameController;
  late TextEditingController _hargaController;
  late TextEditingController _masaPakaiController;
  String? _selectedKondisi;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  void _fetchDetail() async {
    final result = await _apiService.getAssetDetail(widget.assetId);
    if (result['status'] == true) {
      setState(() {
        _rawDetail = result['data'];
        _attributes = result['attributes'];

        // Inisialisasi controller dengan data dari database
        _nameController = TextEditingController(text: _rawDetail?['asset_nm']);
        _hargaController = TextEditingController(text: _rawDetail?['beli_nominal'].toString());
        _masaPakaiController = TextEditingController(text: _rawDetail?['pakai_masa_bln'].toString());
        _selectedKondisi = _rawDetail?['asset_kondisi'];

        _isLoading = false;
      });
    }
  }

  // Dialog Konfirmasi (Yes/Discard)
  Future<bool> _showConfirmDialog(String title, String content) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("DISCARD")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text("YES")),
        ],
      ),
    ) ?? false;
  }

  void _handleSave() async {
    if (await _showConfirmDialog("Simpan Perubahan?", "Data aset akan diperbarui di server.")) {
      setState(() => _isLoading = true);
      Map<String, dynamic> updateData = {
        'asset_nm': _nameController.text,
        'asset_kondisi': _selectedKondisi,
        'beli_nominal': _hargaController.text,
        'pakai_masa_bln': _masaPakaiController.text,
      };

      final res = await _apiService.updateAsset(widget.assetId, updateData);
      if (res['status'] == true) {
        setState(() => _isEditing = false);
        _fetchDetail(); // Muat ulang data terbaru
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Aset" : widget.assetName),
        actions: [
          if (!_isLoading)
            _isEditing
                ? Row(
              children: [
                IconButton(icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () async {
                      if (await _showConfirmDialog("Batalkan Edit?", "Perubahan yang belum disimpan akan hilang.")) {
                        setState(() => _isEditing = false);
                      }
                    }
                ),
                IconButton(icon: Icon(Icons.check, color: Colors.green), onPressed: _handleSave),
              ],
            )
                : IconButton(icon: Icon(Icons.edit), onPressed: () => setState(() => _isEditing = true)),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField("Nama Aset", _nameController, Icons.inventory),
            SizedBox(height: 15),

            // Kondisi menggunakan Dropdown hanya jika sedang editing
            Text("Kondisi", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            _isEditing
                ? DropdownButtonFormField<String>(
              value: _selectedKondisi,
              items: ["BAIK", "RUSAK RINGAN", "RUSAK BERAT"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _selectedKondisi = val),
            )
                : Text(_selectedKondisi ?? "-", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

            Divider(height: 30),
            _buildField("Harga Beli", _hargaController, Icons.payments, isNum: true),
            SizedBox(height: 15),
            _buildField("Masa Pakai (Bulan)", _masaPakaiController, Icons.timer, isNum: true),

            SizedBox(height: 30),
            Text("Spesifikasi Tambahan (Read-only)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            ..._attributes.map((attr) => ListTile(
              title: Text(attr['atribut_label']),
              subtitle: Text(attr['value_isi']),
              dense: true,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {bool isNum = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        _isEditing
            ? TextFormField(
          controller: controller,
          keyboardType: isNum ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(prefixIcon: Icon(icon, size: 20)),
        )
            : Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(controller.text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}