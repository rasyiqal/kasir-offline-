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
  List<Map<String, dynamic>> _cartItems = [];
  bool _loadingKategori = true;
  bool _loadingMenu = true;

  final Color primaryBlue =
      const Color(0xFF0D47A1);
  final Color accentBlue = const Color(0xFFE3F2FD);
  final Color bgWhite = Colors.white;
  final Color lightGrey = const Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _loadKategori();
  }

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
      } else {
        Future.delayed(Duration.zero, () => _showEmptyWarningDialog());
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

  void _addToCart(Map<String, dynamic> menu) {
    setState(() {
      final existingItemIndex = _cartItems.indexWhere(
          (item) => item['menu_id'] == menu['id']);
      
      if (existingItemIndex >= 0) {
        // Item sudah ada, tambah quantity
        _cartItems[existingItemIndex]['qty'] += 1;
      } else {
        // Item baru, tambahkan ke cart
        _cartItems.add({
          'menu_id': menu['id'],
          'nama': menu['nama'],
          'harga': menu['harga'],
          'gambar': menu['gambar'],
          'kategori_id': menu['kategori_id'],
          'qty': 1,
        });
      }
    });
  }

  void _showEmptyWarningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User wajib menekan tombol
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text('Data Kosong'),
          ],
        ),
        content: const Text(
          'Menu dan kategori belum diatur. Silahkan login ke akun pengelola untuk menambahkan data.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.login, size: 18),
                SizedBox(width: 8),
                Text('Kelola Menu'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getTotalPrice() {
    int total = 0;
    for (var item in _cartItems) {
      total += (item['harga'] as int) * (item['qty'] as int);
    }
    return total;
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
                                              onAddToCart: () => _addToCart(_menuList[index]),
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
                    cartItems: _cartItems,
                    totalPrice: _getTotalPrice(),
                    onRemoveItem: (index) {
                      setState(() {
                        if (index >= 0 && index < _cartItems.length) {
                          _cartItems.removeAt(index);
                        }
                      });
                    },
                    onUpdateQuantity: (index, newQty) {
                      setState(() {
                        if (index >= 0 && index < _cartItems.length) {
                          if (newQty <= 0) {
                            _cartItems.removeAt(index);
                          } else {
                            _cartItems[index]['qty'] = newQty;
                          }
                        }
                      });
                    },
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

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal:
                      _sidebarVisible ? 16 : 0,
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
