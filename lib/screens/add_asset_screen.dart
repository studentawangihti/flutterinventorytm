import 'dart:convert';
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

  // Controller Utama
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _kdSingkatController = TextEditingController();
  final TextEditingController _fullSkuController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _masaPakaiController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  // Variabel Penampung Data
  List<dynamic> _categories = [];
  List<dynamic> _units = [];
  List<String> _suggestedSkuCodes = [];

  // Variabel Atribut Dinamis
  List<dynamic> _dynamicAttributes = [];
  Map<String, TextEditingController> _dynamicControllers = {};

  String? _selectedKategori;
  String? _selectedSatuan;
  String _selectedKondisi = "BAIK";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMetadata();
  }

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

  // REVISI: Logika reset total saat kategori diubah
  void _onCategoryChanged(String? value) async {
    setState(() {
      _selectedKategori = value;
      _kdSingkatController.clear();
      _fullSkuController.clear();
      _suggestedSkuCodes = []; // Langsung kosongkan saran lama agar tidak nyangkut
      _dynamicAttributes = [];
      _dynamicControllers.forEach((key, controller) => controller.dispose());
      _dynamicControllers.clear();
    });

    if (value != null) {
      _fetchSkuSuggestions(value);
      _fetchDynamicAttributes(value);
    }
  }

  void _fetchSkuSuggestions(String kategoriId) async {
    final result = await _apiService.getExistingSkuCodes(kategoriId);
    if (result['status'] == true) {
      setState(() {
        _suggestedSkuCodes = List<String>.from(result['data']);
      });
    }
  }

  void _fetchDynamicAttributes(String kategoriId) async {
    final result = await _apiService.getAttributesByCategory(kategoriId);
    if (result['status'] == true) {
      setState(() {
        _dynamicAttributes = result['data'];
        for (var attr in _dynamicAttributes) {
          _dynamicControllers[attr['atribut_id'].toString()] = TextEditingController();
        }
      });
    }
  }

  void _generateAutoSku() async {
    if (_selectedKategori != null && _kdSingkatController.text.isNotEmpty) {
      final tglString = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final result = await _apiService.getAutoSku(
          _selectedKategori!,
          _kdSingkatController.text.toUpperCase(),
          tglString
      );

      if (result['status'] == true) {
        setState(() {
          _fullSkuController.text = result['new_sku'];
        });
      }
    }
  }

  Widget _buildDynamicFields() {
    if (_dynamicAttributes.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text("Atribut Spesifikasi", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        ),
        ..._dynamicAttributes.map((attr) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextFormField(
              controller: _dynamicControllers[attr['atribut_id'].toString()],
              maxLines: attr['atribut_tipe'] == 'textarea' ? 3 : 1,
              keyboardType: attr['atribut_tipe'] == 'angka' ? TextInputType.number : TextInputType.text,
              decoration: InputDecoration(
                labelText: attr['atribut_label'],
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "${attr['atribut_label']} wajib diisi" : null,
            ),
          );
        }).toList(),
        Divider(height: 30),
      ],
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  void _saveData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      Map<String, String> attributeData = {};
      _dynamicControllers.forEach((id, controller) {
        attributeData[id] = controller.text;
      });

      Map<String, dynamic> data = {
        'asset_nm': _nameController.text,
        'kategori_id': _selectedKategori,
        'satuan_id': _selectedSatuan,
        'asset_kd': _fullSkuController.text,
        'asset_kd_singkat': _kdSingkatController.text.toUpperCase(),
        'asset_kondisi': _selectedKondisi,
        'beli_nominal': _hargaController.text,
        'beli_tgl': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'pakai_masa_bln': _masaPakaiController.text,
        'attributes': jsonEncode(attributeData),
      };

      final result = await _apiService.saveAsset(data);
      setState(() => _isLoading = false);

      if (result['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Aset Berhasil Disimpan"), backgroundColor: Colors.green));
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
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Nama Aset", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Nama aset wajib diisi" : null,
              ),
              SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Pilih Kategori", border: OutlineInputBorder(), prefixIcon: Icon(Icons.category)),
                value: _selectedKategori,
                items: _categories.map((cat) => DropdownMenuItem(value: cat['kategori_id'].toString(), child: Text(cat['kategori_nm']))).toList(),
                onChanged: _onCategoryChanged,
                validator: (v) => v == null ? "Kategori wajib dipilih" : null,
              ),

              _buildDynamicFields(),

              SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Autocomplete<String>(
                      // POIN NOMOR 2: Tambahkan Key unik agar widget refresh total saat kategori ganti
                      key: ValueKey(_selectedKategori),

                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text == '') return _suggestedSkuCodes;
                        return _suggestedSkuCodes.where((String option) => option.contains(textEditingValue.text.toUpperCase()));
                      },
                      onSelected: (String selection) {
                        _kdSingkatController.text = selection;
                        _generateAutoSku();
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        // Pastikan controller sinkron dengan data utama
                        if (controller.text != _kdSingkatController.text) {
                          controller.text = _kdSingkatController.text;
                        }

                        controller.addListener(() {
                          _kdSingkatController.text = controller.text;
                          _generateAutoSku();
                        });

                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                              labelText: "Kode Singkat",
                              hintText: "CTH: PC",
                              border: OutlineInputBorder(),
                              helperText: "Ketik baru jika tidak ada"
                          ),
                          validator: (v) => v!.isEmpty ? "Wajib" : null,
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: "Satuan", border: OutlineInputBorder()),
                      items: _units.map((u) => DropdownMenuItem(value: u['satuan_id'].toString(), child: Text(u['satuan_nm']))).toList(),
                      onChanged: (v) => setState(() => _selectedSatuan = v),
                      validator: (v) => v == null ? "Pilih satuan" : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _fullSkuController,
                readOnly: true,
                decoration: InputDecoration(
                    labelText: "Hasil Kode Aset (SKU Otomatis)",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[100],
                    prefixIcon: Icon(Icons.qr_code)
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _hargaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Harga Beli", border: OutlineInputBorder(), prefixText: "Rp "),
                validator: (v) => v!.isEmpty ? "Masukkan harga" : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _masaPakaiController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Masa Pakai", border: OutlineInputBorder(), suffixText: "Bulan"),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              SizedBox(height: 15),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("Tanggal Beli: ${DateFormat('dd MMMM yyyy').format(_selectedDate)}"),
                trailing: Icon(Icons.calendar_today, color: Colors.blue),
                shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(5)),
                onTap: () async {
                  DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2000), lastDate: DateTime.now());
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                    _generateAutoSku();
                  }
                },
              ),
              SizedBox(height: 30),
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