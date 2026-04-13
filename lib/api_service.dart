import 'dart:convert';
import 'package:http/http.dart' as http;

// Future<Map<String, dynamic>> getCategories() async {
//   try {
//     final response = await http.get(Uri.parse('$baseUrl/get_categories'));
//     return json.decode(response.body);
//   } catch (e) {
//     return {'status': false, 'message': 'Gagal muat kategori: $e'};
//   }
// }

class ApiService {
  // Pastikan IP ini sesuai dengan IP Laptop Anda saat ini
  static const String baseUrl = "http://192.168.1.2/Project_Magang/index.php/app/api";

  Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/ping'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'status': false, 'message': 'Gagal terhubung: ${response.statusCode}'};
      }
    } catch (e) {
      return {'status': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        body: {'u': username, 'p': password},
      );
      return json.decode(response.body);
    } catch (e) {
      return {'status': false, 'message': 'Gagal menghubungi server: $e'};
    }
  }

  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_dashboard'));
      return json.decode(response.body);
    } catch (e) {
      return {'status': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

  Future<Map<String, dynamic>> getAssets({String? kategoriId}) async {
    try {
      String url = '$baseUrl/get_assets';
      if (kategoriId != null && kategoriId.isNotEmpty) {
        // PEMBETULAN: Menggunakan parameter kategoriId yang benar
        url += '?kategori_id=$kategoriId';
      }
      final response = await http.get(Uri.parse(url));
      return json.decode(response.body);
    } catch (e) {
      return {'status': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

  Future<Map<String, dynamic>> getAssetDetail(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_asset_detail/$id'));
      return json.decode(response.body);
    } catch (e) {
      return {'status': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

  Future<Map<String, dynamic>> getAssetMetadata() async {
    final response = await http.get(Uri.parse('$baseUrl/get_asset_metadata'));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> saveAsset(Map<String, dynamic> assetData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/save_asset'),
      body: assetData, // Data dikirim sebagai form-data
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_categories'));
      if (response.statusCode == 200) {
        return json.decode(response.body); // Mengembalikan data kategori dari DB
      } else {
        return {'status': false, 'message': 'Gagal memuat kategori'};
      }
    } catch (e) {
      return {'status': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

  Future<Map<String, dynamic>> getExistingSkuCodes(String kategoriId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_existing_sku_codes?kategori_id=$kategoriId'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'status': false, 'message': 'Gagal memuat saran SKU'};
      }
    } catch (e) {
      return {'status': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteAsset(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete_asset'),
        body: {'asset_id': id},
      );
      return json.decode(response.body);
    } catch (e) {
      return {'status': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

  Future<Map<String, dynamic>> getAssetBySku(String sku) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_asset_by_sku?sku=$sku'));
      return json.decode(response.body);
    } catch (e) {
      return {'status': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

}
