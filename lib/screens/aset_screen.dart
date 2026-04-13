import 'package:flutter/material.dart';
import '../api_service.dart';
import 'detail_aset_screen.dart';
import 'add_asset_screen.dart';

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

  // Ambil data aset dari API dengan filter kategori
  void _fetchAssets() async {
    setState(() => _isLoading = true);
    final result = await ApiService().getAssets(kategoriId: _selectedKategoriId);
    if (result['status'] == true) {
      setState(() {
        _assets = result['data'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manajemen Aset"), elevation: 2),

      // Tombol Tambah Aset Baru
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? refresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddAssetScreen()),
          );
          if (refresh == true) {
            _fetchAssets();
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),

      body: Column(
        children: [
          // Bagian 1: Filter Dropdown Kategori
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

          // Bagian 2: Daftar Aset dengan Swipe to Delete
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
                  Color statusColor = item['asset_kondisi'] == 'BAIK' ? Colors.green : Colors.red;

                  return Dismissible(
                    key: Key(item['asset_id'].toString()),
                    direction: DismissDirection.endToStart, // Geser dari kanan ke kiri untuk hapus
                    confirmDismiss: (direction) async {
                      // Munculkan dialog konfirmasi sebelum hapus
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Konfirmasi Hapus"),
                            content: Text("Yakin ingin menghapus ${item['asset_nm']}?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text("BATAL"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: Text("HAPUS", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (direction) async {
                      // Proses hapus ke database melalui API
                      final result = await ApiService().deleteAsset(item['asset_id'].toString());

                      if (result['status'] == true) {
                        setState(() {
                          _assets.removeAt(index); // Hapus dari tampilan lokal
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${item['asset_nm']} berhasil dihapus"), backgroundColor: Colors.green),
                        );
                      } else {
                        // Jika gagal, ambil ulang data untuk mengembalikan posisi item
                        _fetchAssets();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Gagal menghapus aset"), backgroundColor: Colors.red),
                        );
                      }
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
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
                          // Navigasi ke Detail Aset
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