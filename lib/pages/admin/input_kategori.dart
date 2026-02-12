import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kasir/auth/database.dart';

class InputKategoriDialog extends StatefulWidget {
  final Map<String, dynamic>? kategoriData; // Untuk edit mode
  const InputKategoriDialog({super.key, this.kategoriData});

  @override
  State<InputKategoriDialog> createState() => _InputKategoriDialogState();
}

class _InputKategoriDialogState extends State<InputKategoriDialog> {
  late String namaKategori;
  XFile? gambarKategori;
  final Color primaryBlue = const Color(0xFF007AFF);

  @override
  void initState() {
    super.initState();
    namaKategori = widget.kategoriData?['nama'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 420,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.kategoriData != null ? 'Edit Kategori' : 'Tambah Kategori',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.kategoriData != null
                    ? 'Ubah nama kategori'
                    : 'Input nama dan foto untuk kategori baru',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
              const SizedBox(height: 32),

              // --- INPUT NAMA ---
              const Text(
                'Nama Kategori',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (v) => setState(() => namaKategori = v),
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Contoh: Makanan Berat',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryBlue.withOpacity(0.5)),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // --- ACTIONS ---
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        side: const BorderSide(color: Color(0xFFEEEEEE)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (namaKategori.trim().isEmpty) return;
                        if (widget.kategoriData != null) {
                          // Edit mode
                          await AppDatabase.updateKategori(
                            widget.kategoriData!['id'],
                            namaKategori.trim(),
                          );
                        } else {
                          // Insert mode
                          await AppDatabase.insertKategori(namaKategori.trim());
                        }
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.kategoriData != null ? 'Update Kategori' : 'Simpan Kategori',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
