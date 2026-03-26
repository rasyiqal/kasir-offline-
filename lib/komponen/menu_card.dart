import 'package:flutter/material.dart';
import 'dart:io';

class MenuCard extends StatelessWidget {
  final int index;
  final Color primaryBlue;
  final Map<String, dynamic> menu;
  final VoidCallback? onAddToCart;

  const MenuCard({
    super.key,
    required this.index,
    required this.primaryBlue,
    required this.menu,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    String nama = menu['nama'] ?? '-';
    int harga = menu['harga'] ?? 0;
    String? gambar = menu['gambar'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onAddToCart,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1.2,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.05),
                    ),
                    child: _buildImage(gambar),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Nama Produk
                        Text(
                          nama,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Color(0xFF2D3142),
                            height: 1.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Harga dan Tombol Tambah
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Rp ${_formatRupiah(harga)}',
                                  style: TextStyle(
                                    color: primaryBlue,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: primaryBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String? gambar) {
    if (gambar == null || gambar.isEmpty) {
      return _buildPlaceholder();
    }

    final file = File(gambar);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.fastfood_rounded,
        color: primaryBlue.withOpacity(0.2),
        size: 40,
      ),
    );
  }

  String _formatRupiah(dynamic value) {
    if (value == null) return '0';
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
      return '0';
    }
  }
}
