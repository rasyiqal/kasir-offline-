import 'package:flutter/material.dart';
import 'package:kasir/auth/database.dart';
import 'dart:io';

class MenuTable extends StatefulWidget {
  final Color bgSurface;
  final Color primaryBlue;
  const MenuTable(
      {Key? key, required this.bgSurface, required this.primaryBlue})
      : super(key: key);

  @override
  State<MenuTable> createState() => _MenuTableState();
}

class _MenuTableState extends State<MenuTable> {
  List<Map<String, dynamic>> menuList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    final list = await AppDatabase.getMenu();
    setState(() {
      menuList = list;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: isLoading
          ? const Center(
              child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ))
          : menuList.isEmpty
              ? const Center(
                  child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Tidak ada data menu',
                      style: TextStyle(color: Colors.grey)),
                ))
              : ListView.builder(
                  itemCount: menuList.length,
                  itemBuilder: (context, i) {
                    final menu = menuList[i];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: Colors.grey.withOpacity(0.05))),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: widget.bgSurface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: menu['gambar'] != null &&
                                    (menu['gambar'] as String).isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(menu['gambar']),
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                              Icons.fastfood_rounded,
                                              color: widget.primaryBlue
                                                  .withOpacity(0.6)),
                                    ),
                                  )
                                : Icon(Icons.fastfood_rounded,
                                    color: widget.primaryBlue.withOpacity(0.6)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(menu['nama'] ?? '-',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(
                                  'Kategori • ${menu['kategori_nama'] ?? '-'}',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text('Rp ${_formatRupiah(menu['harga'])}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w900)),
                          const SizedBox(width: 24),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.redAccent,
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Hapus Menu'),
                                  content: Text(
                                      'Yakin ingin menghapus menu "${menu['nama']}"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Batal'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Hapus'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await AppDatabase.database.then((db) => db
                                    .delete('menu',
                                        where: 'id = ?',
                                        whereArgs: [menu['id']]));
                                _loadMenu();
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  String _formatRupiah(dynamic value) {
    if (value == null) return '-';
    try {
      final intVal = value is int ? value : int.tryParse(value.toString()) ?? 0;
      final str = intVal.toString();
      final buffer = StringBuffer();
      for (int i = 0; i < str.length; i++) {
        if (i != 0 && (str.length - i) % 3 == 0) buffer.write('.');
        buffer.write(str[i]);
      }
      return buffer.toString();
    } catch (_) {
      return value.toString();
    }
  }
}
