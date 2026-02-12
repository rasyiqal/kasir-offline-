import 'package:flutter/material.dart';
import 'package:kasir/auth/database.dart';

class CategoryList extends StatefulWidget { 
  final Function(Map<String, dynamic>)? onEdit;
  final Function(int)? onDelete;

  const CategoryList({
    super.key,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<CategoryList> createState() => CategoryListState();
}

class CategoryListState extends State<CategoryList> {
  Key _refreshKey = UniqueKey();

  void _refreshData() {
    setState(() {
      _refreshKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF007AFF);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        key: _refreshKey, 
        future: AppDatabase.getKategori(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final kategoriList = snapshot.data ?? [];

          if (kategoriList.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('Tidak ada data kategori',
                    style: TextStyle(color: Colors.grey)),
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            itemCount: kategoriList.length,
            separatorBuilder: (context, index) => Divider(
              color: Colors.grey.withOpacity(0.05),
              height: 1,
            ),
            itemBuilder: (context, i) {
              final kategori = kategoriList[i];
              
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.layers_rounded, color: primaryBlue, size: 22),
                ),
                title: Text(
                  kategori['nama'] ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.orange, size: 22),
                      onPressed: () => widget.onEdit?.call(kategori),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                      onPressed: () => _confirmDelete(context, kategori),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> kategori) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Yakin ingin menghapus kategori "${kategori['nama']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              if (widget.onDelete != null) {
                await widget.onDelete!(kategori['id']);
              }
              Navigator.pop(context);
              _refreshData(); 
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void refreshCategories() {
    _refreshData();
  }
}