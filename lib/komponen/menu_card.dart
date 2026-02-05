import 'package:flutter/material.dart';
import 'dart:io';

class MenuCard extends StatelessWidget {
  final int index;
  final Color primaryBlue;
  final Map<String, dynamic> menu;

  const MenuCard({
    Key? key,
    required this.index,
    required this.primaryBlue,
    required this.menu,
  }) : super(key: key);

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
            onTap: () {/* Logika tambah ke keranjang */},
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

                // --- BAGIAN INFO ---
                // Remove Expanded here so the Column can just take what it needs
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nama,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF2D3142),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Rp${_formatRupiah(harga)}',
                              style: TextStyle(
                                color: primaryBlue,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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
                    ],
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
    if (gambar != null && gambar.isNotEmpty && File(gambar).existsSync()) {
      return Image.file(
        File(gambar),
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
