import 'package:flutter/material.dart';

class ListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Daftar Aset")),
      body: Center(
        child: Text("Halaman List Aset (Cari & Filter Barang)"),
      ),
    );
  }
}