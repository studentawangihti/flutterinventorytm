import 'package:flutter/material.dart';

class TransaksiScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Transaksi Aset")),
      body: Center(
        child: Text("Halaman Transaksi (Pinjam, Kembali, Mutasi)"),
      ),
    );
  }
}