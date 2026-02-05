import 'package:flutter/material.dart';
import 'package:kasir/auth/database.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF007AFF);
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: AppDatabase.getKategori(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final kategoriList = snapshot.data ?? [];
        if (kategoriList.isEmpty) {
          return const Center(
            child: Text('Tidak ada data kategori',
                style: TextStyle(color: Colors.grey)),
          );
        }
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.5,
          ),
          itemCount: kategoriList.length,
          itemBuilder: (context, i) {
            final kategori = kategoriList[i];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open_rounded, color: primaryBlue, size: 32),
                  const SizedBox(height: 12),
                  Text(kategori['nama'] ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
