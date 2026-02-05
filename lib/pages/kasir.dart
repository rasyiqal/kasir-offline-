import 'package:flutter/material.dart';
import 'package:kasir/komponen/menu_card.dart';
import 'package:kasir/komponen/cart.dart';
import 'package:kasir/auth/database.dart';

class KasirPage extends StatefulWidget {
  const KasirPage({super.key});

  @override
  State<KasirPage> createState() => _KasirPageState();
}

class _KasirPageState extends State<KasirPage> {
  bool _sidebarVisible = true;
  bool _cartVisible = true;
  int? _selectedCategoryId;
  String _selectedCategoryName = '';
  List<Map<String, dynamic>> _kategoriList = [];
  List<Map<String, dynamic>> _menuList = [];
  bool _loadingKategori = true;
  bool _loadingMenu = true;

  // Palette Warna yang Lebih Modern
  final Color primaryBlue =
      const Color(0xFF0D47A1); // Deep Blue lebih profesional
  final Color accentBlue = const Color(0xFFE3F2FD);
  final Color bgWhite = Colors.white;
  final Color lightGrey = const Color(0xFFF8FAFC); // Grey kebiruan yang bersih

  @override
  void initState() {
    super.initState();
    _loadKategori();
  }

  // ... (Fungsi _loadKategori dan _loadMenu tetap sama seperti sebelumnya) ...
  Future<void> _loadKategori() async {
    setState(() => _loadingKategori = true);
    final kategori = await AppDatabase.getKategori();
    setState(() {
      _kategoriList = kategori;
      _loadingKategori = false;
      if (_kategoriList.isNotEmpty) {
        _selectedCategoryId = _kategoriList[0]['id'];
        _selectedCategoryName = _kategoriList[0]['nama'];
        _loadMenu();
      }
    });
  }

  Future<void> _loadMenu() async {
    setState(() => _loadingMenu = true);
    if (_selectedCategoryId == null) return;
    final db = await AppDatabase.database;
    final menu = await db.rawQuery('''
      SELECT menu.*, kategori.nama AS kategori_nama
      FROM menu
      LEFT JOIN kategori ON menu.kategori_id = kategori.id
      WHERE menu.kategori_id = ?
      ORDER BY menu.nama
    ''', [_selectedCategoryId]);
    setState(() {
      _menuList = menu;
      _loadingMenu = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgWhite,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: bgWhite,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: accentBlue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.storefront_rounded,
                              color: primaryBlue, size: 28),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          'SKY POS',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: primaryBlue,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 350,
                    height: 40,
                    decoration: BoxDecoration(
                      color: lightGrey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Cari produk...",
                        prefixIcon: Icon(Icons.search, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Selasa, 3 Feb 2026",
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  _buildSidebar(),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: lightGrey,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30)),
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedCategoryName.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              Text("${_menuList.length} Produk ditemukan",
                                  style: TextStyle(
                                      color: Colors.grey[500], fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: _loadingMenu
                                ? Center(
                                    child: CircularProgressIndicator(
                                        color: primaryBlue))
                                : _menuList.isEmpty
                                    ? _buildEmptyState()
                                    : LayoutBuilder(
                                        builder: (context, constraints) {
                                          double targetCardWidth = 135;
                                          int crossAxisCount =
                                              (constraints.maxWidth /
                                                      targetCardWidth)
                                                  .floor();
                                          if (crossAxisCount < 2)
                                            crossAxisCount = 2;
                                          return GridView.builder(
                                            padding: const EdgeInsets.only(
                                                bottom: 20),
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: crossAxisCount,
                                              childAspectRatio: 0.75,
                                              crossAxisSpacing: 16,
                                              mainAxisSpacing: 16,
                                            ),
                                            itemCount: _menuList.length,
                                            itemBuilder: (context, index) =>
                                                MenuCard(
                                              index: index,
                                              primaryBlue: primaryBlue,
                                              menu: _menuList[index],
                                            ),
                                          );
                                        },
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Cart(
                    cartVisible: _cartVisible,
                    onShow: () => setState(() => _cartVisible = true),
                    onHide: () => setState(() => _cartVisible = false),
                    primaryBlue: primaryBlue,
                    bgWhite: bgWhite,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _sidebarVisible ? 240 : 70,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: bgWhite,
        border: Border(right: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Row(
              mainAxisAlignment: _sidebarVisible
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.center,
              children: [
                if (_sidebarVisible)
                  const Expanded(
                    child: Text(
                      'KATEGORI',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                  ),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  icon: Icon(
                      _sidebarVisible
                          ? Icons.arrow_back_ios_new
                          : Icons.menu_open,
                      size: 20),
                  onPressed: () =>
                      setState(() => _sidebarVisible = !_sidebarVisible),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loadingKategori
                ? Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: primaryBlue))
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _kategoriList.length,
                    itemBuilder: (context, index) =>
                        _categoryItem(_kategoriList[index]),
                  ),
          ),
          const Divider(height: 1),
          // Tombol Kelola Menu
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                // Gunakan AnimatedContainer agar padding ikut transisi
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal:
                      _sidebarVisible ? 16 : 0, // Kurangi padding saat tertutup
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: Row(
                  mainAxisAlignment: _sidebarVisible
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    Icon(Icons.settings_suggest, color: primaryBlue, size: 20),
                    if (_sidebarVisible) ...[
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Text(
                          'Kelola Menu',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow
                              .ellipsis, 
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryItem(Map<String, dynamic> kategori) {
    bool isSelected = _selectedCategoryId == kategori['id'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCategoryId = kategori['id'];
            _selectedCategoryName = kategori['nama'];
          });
          _loadMenu();
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: _sidebarVisible
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Icon(
                Icons.circle,
                size: 8,
                color: isSelected ? Colors.white : primaryBlue.withOpacity(0.5),
              ),
              if (_sidebarVisible) ...[
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    kategori['nama'],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("Menu belum tersedia",
              style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }
}
