import 'package:flutter/material.dart';
import '../api_service.dart';
import 'detail_aset_screen.dart';

class AsetScreen extends StatefulWidget {
  @override
  _AsetScreenState createState() => _AsetScreenState();
}

class _AsetScreenState extends State<AsetScreen> {
  List<dynamic> _assets = [];
  List<dynamic> _categories = [];
  String? _selectedKategoriId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // Muat kategori dan data aset awal
  void _loadInitialData() async {
    final catResult = await ApiService().getCategories();
    if (catResult['status'] == true) {
      setState(() => _categories = catResult['data']);
    }
    _fetchAssets();
  }

  // Ambil data aset dari API
  void _fetchAssets() async {
    setState(() => _isLoading = true);
    final result = await ApiService().getAssets(kategoriId: _selectedKategoriId);
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
      appBar: AppBar(title: Text("Manajemen Aset"), elevation: 2),
      body: Column(
        children: [
          // Filter Dropdown Kategori
          Padding(
            padding: EdgeInsets.all(12),
            child: DropdownButtonFormField<String>(
              value: _selectedKategoriId,
              decoration: InputDecoration(
                labelText: "Filter Kategori",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: Icon(Icons.category),
              ),
              items: [
                DropdownMenuItem(value: null, child: Text("Semua Kategori")),
                ..._categories.map((cat) => DropdownMenuItem(
                  value: cat['kategori_id'].toString(),
                  child: Text(cat['kategori_nm']),
                )),
              ],
              onChanged: (val) {
                setState(() => _selectedKategoriId = val);
                _fetchAssets();
              },
            ),
          ),

          // Daftar Aset dengan Kartu Lengkap
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
              onRefresh: () async => _fetchAssets(),
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10),
                itemCount: _assets.length,
                itemBuilder: (context, index) {
                  final item = _assets[index];
                  // Indikator Warna Kondisi
                  Color statusColor = item['asset_kondisi'] == 'BAIK' ? Colors.green : Colors.red;

                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(12),
                      leading: CircleAvatar(
                        backgroundColor: statusColor.withOpacity(0.2),
                        child: Icon(Icons.inventory_2, color: statusColor),
                      ),
                      title: Text(item['asset_nm'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text("Kode: ${item['asset_kd']}"),
                          Text("Kategori: ${item['kategori_nm']}"),
                          SizedBox(height: 6),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              item['asset_kondisi'] ?? 'BAIK',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Navigasi ke Detail Aset bisa ditambahkan di sini
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailAsetScreen(
                              assetId: item['asset_id'].toString(),
                              assetName: item['asset_nm'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}