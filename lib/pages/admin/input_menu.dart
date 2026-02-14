import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:kasir/auth/database.dart';

class InputMenuDialog extends StatefulWidget {
  final Map<String, dynamic>? menuData;

  const InputMenuDialog({super.key, this.menuData});

  @override
  State<InputMenuDialog> createState() => _InputMenuDialogState();
}

class _InputMenuDialogState extends State<InputMenuDialog> {
  String namaMenu = '';
  String hargaMenu = '';
  int? kategoriTerpilihId;
  String? kategoriTerpilihNama;
  XFile? gambarMenu;
  String? gambarLama;

  List<Map<String, dynamic>> kategoriList = [];

  final Color primaryBlue = const Color(0xFF007AFF);
  final Color fieldBg = const Color(0xFFF8F9FA);
  final Color borderColor = const Color(0xFFEEEEEE);

  @override
  void initState() {
    super.initState();
    if (widget.menuData != null) {
      namaMenu = widget.menuData!['nama'] as String;
      hargaMenu = widget.menuData!['harga'].toString();
      kategoriTerpilihId = widget.menuData!['kategori_id'] as int;
      kategoriTerpilihNama = widget.menuData!['kategori_nama'] as String;
      final gambarPath = widget.menuData!['gambar'] as String?;
      if (gambarPath != null && gambarPath.isNotEmpty) {
        gambarMenu = XFile(gambarPath);
        gambarLama = gambarPath;
      }
    }
    _loadKategori();
  }

  Future<void> _loadKategori() async {
    final list = await AppDatabase.getKategori();
    setState(() {
      kategoriList = list;
      if (kategoriList.isNotEmpty && kategoriTerpilihId == null) {
        kategoriTerpilihId = kategoriList[0]['id'] as int;
        kategoriTerpilihNama = kategoriList[0]['nama'] as String;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.menuData == null ? 'Tambah Menu Baru' : 'Edit Menu',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildLabel('Foto Menu'),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    color: fieldBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: gambarMenu == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_outlined,
                                color: primaryBlue, size: 36),
                            const SizedBox(height: 8),
                            Text('Klik untuk unggah foto menu',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey[600])),
                            const SizedBox(height: 8),
                            // Tombol hapus hanya muncul jika gambarLama ada (edit mode)
                            if (gambarLama != null && gambarLama!.isNotEmpty)
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    gambarMenu = null;
                                    gambarLama = null;
                                  });
                                },
                                icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                label: const Text('Hapus Foto', style: TextStyle(color: Colors.red)),
                              ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.file(File(gambarMenu!.path),
                                    fit: BoxFit.cover),
                              ),
                              Positioned(
                                right: 12,
                                top: 12,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.black54,
                                      child: IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.white, size: 20),
                                        onPressed: _pickImage,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    CircleAvatar(
                                      backgroundColor: Colors.black54,
                                      child: IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.white, size: 20),
                                        onPressed: () {
                                          setState(() {
                                            gambarMenu = null;
                                            gambarLama = null;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              _buildLabel('Nama Menu'),
              _buildTextField(
                hint: 'Contoh: Nasi Goreng Spesial',
                onChanged: (v) => setState(() => namaMenu = v),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Harga (Rp)'),
                        _buildTextField(
                          hint: '0',
                          keyboardType: TextInputType.number,
                          onChanged: (v) => setState(() => hargaMenu = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Kategori'),
                        _buildDropdown(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Batal',
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (namaMenu.trim().isEmpty ||
                            hargaMenu.trim().isEmpty ||
                            kategoriTerpilihId == null) {
                          return;
                        }
                        
                        try {
                          if (widget.menuData == null) {
                            // Insert menu baru
                            await AppDatabase.insertMenu(
                              nama: namaMenu.trim(),
                              harga: int.tryParse(hargaMenu.trim()) ?? 0,
                              gambar: gambarMenu?.path,
                              kategoriId: kategoriTerpilihId!,
                            );
                          } else {
                            if (gambarMenu == null && gambarLama != null && gambarLama!.isNotEmpty) {
                              await _deleteImageFile(gambarLama!);
                            }
                            if (gambarMenu != null && gambarLama != null && gambarMenu!.path != gambarLama!) {
                              await _deleteImageFile(gambarLama!);
                            }
                            await AppDatabase.updateMenu(
                              id: widget.menuData!['id'] as int,
                              nama: namaMenu.trim(),
                              harga: int.tryParse(hargaMenu.trim()) ?? 0,
                              gambar: gambarMenu?.path,
                              kategoriId: kategoriTerpilihId!,
                            );
                          }
                          Navigator.pop(context, true);
                        } catch (e) {
                          print('Error saving menu: $e');
                          Navigator.pop(context, false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(widget.menuData == null ? 'Simpan Menu' : 'Simpan Perubahan',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(text,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }

  Widget _buildTextField(
      {required String hint,
      required Function(String) onChanged,
      TextInputType? keyboardType}) {
    return TextField(
      onChanged: onChanged,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: fieldBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryBlue.withOpacity(0.5)),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: kategoriTerpilihId,
          isExpanded: true,
          hint: Text('Pilih',
              style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          items: kategoriList.map((k) {
            return DropdownMenuItem<int>(
              value: k['id'] as int,
              child: Text(k['nama'] as String,
                  style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (v) {
            final nama =
                kategoriList.firstWhere((k) => k['id'] == v)['nama'] as String;
            setState(() {
              kategoriTerpilihId = v;
              kategoriTerpilihNama = nama;
            });
          },
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => gambarMenu = img);
  }

  Future<void> _deleteImageFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
  }
}
