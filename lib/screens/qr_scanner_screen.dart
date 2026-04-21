import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../api_service.dart';
import 'detail_aset_screen.dart';

class QrScannerScreen extends StatefulWidget {
  @override
  _QrScannerScreenState createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _isScanning = true;

  void _onDetect(BarcodeCapture capture) async {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        setState(() => _isScanning = false); // Berhenti scan sementara

        // Cari aset berdasarkan SKU hasil scan
        final result = await ApiService().getAssetBySku(code);

        if (result['status'] == true) {
          // Jika ditemukan, langsung buka detail
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DetailAsetScreen(
                assetId: result['data']['asset_id'].toString(),
                assetName: result['data']['asset_nm'],
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result['message'] ?? "Data tidak ditemukan"))
          );
          setState(() => _isScanning = true); // Mulai scan lagi
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan QR Aset")),
      body: MobileScanner(
        controller: MobileScannerController(facing: CameraFacing.back),
        onDetect: _onDetect,
      ),
    );
  }
}

/*
beberapa fitur yang ingin ditambahkan :
1. qr masal
2. export to pdf
 */