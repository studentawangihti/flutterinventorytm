import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api_service.dart';

class AddAssetScreen extends StatefulWidget {
  @override
  _AddAssetScreenState createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends State<AddAssetScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  // Controller untuk menangkap input teks
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _kdSingkatController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _masaPakaiController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  // Variabel penampung data dari API
  List<dynamic> _categories = [];
  List<dynamic> _units = [];
  List<String> _suggestedSkuCodes = []; // Menampung saran SKU dari database

  String? _selectedKategori;
  String? _selectedSatuan;
  String _selectedKondisi = "BAIK";

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMetadata();
  }

  // Mengambil data kategori & satuan awal
  void _loadMetadata() async {
    try {
      final result = await _apiService.getAssetMetadata();
      if (result['status'] == true) {
        setState(() {
          _categories = result['categories'];
          _units = result['units'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        _showErrorSnackBar(result['message'] ?? "Gagal mengambil data metadata");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar("Kesalahan Jaringan: Pastikan server aktif");
    }
  }

  // Fungsi untuk mengambil saran kode SKU berdasarkan kategori yang dipilih
  void _fetchSkuSuggestions(String kategoriId) async {
    // Pastikan fungsi getExistingSkuCodes sudah Anda tambahkan di api_service.dart
    final result = await _apiService.getExistingSkuCodes(kategoriId);
    if (result['status'] == true) {
      setState(() {
        _suggestedSkuCodes = List<String>.from(result['data']);
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Fungsi Simpan Data ke backend CI3
  void _saveData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      Map<String, dynamic> data = {
        'asset_nm': _nameController.text,
        'kategori_id': _selectedKategori,
        'satuan_id': _selectedSatuan,
        'asset_kd_singkat': _kdSingkatController.text.toUpperCase(),
        'asset_kondisi': _selectedKondisi,
        'beli_nominal': _hargaController.text,
        'beli_tgl': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'pakai_masa_bln': _masaPakaiController.text,
      };

      final result = await _apiService.saveAsset(data);
      setState(() => _isLoading = false);

      if (result['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Aset Berhasil Ditambahkan"), backgroundColor: Colors.green)
        );
        Navigator.pop(context, true);
      } else {
        _showErrorSnackBar(result['message'] ?? "Gagal menyimpan aset");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah Aset Baru"), elevation: 2),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Input Nama Aset
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Nama Aset", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Nama aset wajib diisi" : null,
              ),
              SizedBox(height: 15),

              // Dropdown Kategori
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Pilih Kategori",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                value: _selectedKategori,
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat['kategori_id'].toString(),
                    child: Text(cat['kategori_nm']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedKategori = value;
                    _kdSingkatController.clear(); // Bersihkan SKU saat kategori ganti
                  });
                  if (value != null) {
                    _fetchSkuSuggestions(value); // Ambil saran SKU untuk kategori ini
                  }
                },
                validator: (v) => v == null ? "Kategori wajib dipilih" : null,
              ),
              SizedBox(height: 15),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Input SKU / Kode Singkat dengan Autocomplete
                  Expanded(
                    flex: 2,
                    child: Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text == '') {
                          return _suggestedSkuCodes;
                        }
                        return _suggestedSkuCodes.where((String option) {
                          return option.contains(textEditingValue.text.toUpperCase());
                        });
                      },
                      onSelected: (String selection) {
                        _kdSingkatController.text = selection;
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        // Sinkronisasi controller autocomplete dengan _kdSingkatController
                        if (controller.text != _kdSingkatController.text) {
                          controller.text = _kdSingkatController.text;
                        }
                        controller.addListener(() {
                          _kdSingkatController.text = controller.text;
                        });

                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                              labelText: "Kode SKU",
                              hintText: "Contoh: LP",
                              border: OutlineInputBorder(),
                              helperText: "Saran muncul jika kategori dipilih"
                          ),
                          validator: (v) => v!.isEmpty ? "Wajib" : null,
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  // Dropdown Satuan
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: "Satuan", border: OutlineInputBorder()),
                      items: _units.map((u) => DropdownMenuItem(
                          value: u['satuan_id'].toString(),
                          child: Text(u['satuan_nm'])
                      )).toList(),
                      onChanged: (v) => setState(() => _selectedSatuan = v),
                      validator: (v) => v == null ? "Pilih satuan" : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),

              // Input Harga Beli
              TextFormField(
                controller: _hargaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: "Harga Beli",
                    border: OutlineInputBorder(),
                    prefixText: "Rp "
                ),
                validator: (v) => v!.isEmpty ? "Masukkan harga" : null,
              ),
              SizedBox(height: 15),

              // Input Masa Pakai
              TextFormField(
                controller: _masaPakaiController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: "Masa Pakai",
                    border: OutlineInputBorder(),
                    suffixText: "Bulan"
                ),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              SizedBox(height: 15),

              // Date Picker Tanggal Beli
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("Tanggal Beli: ${DateFormat('dd MMMM yyyy').format(_selectedDate)}"),
                trailing: Icon(Icons.calendar_today, color: Colors.blue),
                shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(5)),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now()
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
              SizedBox(height: 30),

              // Tombol Simpan
              ElevatedButton(
                onPressed: _saveData,
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                child: Text("SIMPAN ASET", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }
}