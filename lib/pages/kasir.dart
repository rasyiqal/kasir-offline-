import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasir/auth/cekDataKosong.dart';
import 'package:kasir/auth/login.dart';
import 'package:kasir/komponen/konfirmasi_dialog.dart';
import 'package:kasir/komponen/menu_card.dart';
import 'package:kasir/komponen/cart.dart';
import 'package:kasir/auth/database.dart';
import 'package:kasir/print/nota_thermal.dart';
import 'package:kasir/print/print_manager.dart';
import 'package:kasir/print/print_option.dart';

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
  List<Map<String, dynamic>> _filteredMenuList = [];
  final List<Map<String, dynamic>> _cartItems = [];

  bool _loadingKategori = true;
  bool _loadingMenu = true;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _cashController = TextEditingController();

  final Color primaryBlue = const Color(0xFF0D47A1);
  final Color accentBlue = const Color(0xFFE3F2FD);
  final Color bgWhite = Colors.white;
  final Color lightGrey = const Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _loadKategori();
  }

  // Integrasi dialog peringatan data kosong
  void _showEmptyWarning() {
    EmptyWarningDialog.show(context);
  }

  Future<void> _loadKategori() async {
    setState(() => _loadingKategori = true);
    final kategori = await AppDatabase.getKategori();

    if (!mounted) return;

    setState(() {
      _kategoriList = kategori;
      _loadingKategori = false;

      if (_kategoriList.isNotEmpty) {
        _selectedCategoryId = _kategoriList[0]['id'];
        _selectedCategoryName = _kategoriList[0]['nama'];
        _loadMenu();
      } else {
        // Memanggil class dialog yang sudah Anda pisahkan
        _showEmptyWarning();
      }
    });
  }

  Future<void> _loadMenu() async {
    setState(() => _loadingMenu = true);
    if (_selectedCategoryId == null) return;

    final db = await AppDatabase.database;
    final menu = await db.rawQuery(
      '''
      SELECT menu.*, kategori.nama AS kategori_nama
      FROM menu
      LEFT JOIN kategori ON menu.kategori_id = kategori.id
      WHERE menu.kategori_id = ?
      ORDER BY menu.nama
    ''',
      [_selectedCategoryId],
    );

    setState(() {
      _menuList = menu;
      _filteredMenuList = menu;
      _loadingMenu = false;
      _searchController.clear();
    });
  }

  // search
  void _filterMenu(String query) {
    setState(() {
      _filteredMenuList = _menuList
          .where(
            (item) => item['nama'].toString().toLowerCase().contains(
              query.toLowerCase(),
            ),
          )
          .toList();
    });
  }

  void _addToCart(Map<String, dynamic> menu) {
    setState(() {
      final existingItemIndex = _cartItems.indexWhere(
        (item) => item['menu_id'] == menu['id'],
      );

      if (existingItemIndex >= 0) {
        _cartItems[existingItemIndex]['qty'] += 1;
      } else {
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

  int _getTotalPrice() {
    return _cartItems.fold(
      0,
      (sum, item) => sum + (item['harga'] as int) * (item['qty'] as int),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: bgWhite,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER SECTION
            // --- BAGIAN HEADER YANG DIPERBAIKI ---
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
                  // 1. LOGO SECTION
                  SizedBox(
                    // Gunakan SizedBox atau Expanded dengan flex
                    width: 200,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: accentBlue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.storefront_rounded,
                            color: primaryBlue,
                            size: 28,
                          ),
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

                  // 2. SEARCH & PRINTER SECTION (Tengah)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          // Search Bar
                          Expanded(
                            child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                color: lightGrey,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: _filterMenu,
                                decoration: const InputDecoration(
                                  hintText: "Cari produk...",
                                  hintStyle: TextStyle(fontSize: 14),
                                  prefixIcon: Icon(Icons.search, size: 20),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Icon Printer
                          Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                              color: PrinterManager().isReady
                                  ? Colors.blue.shade50
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: PrinterManager().isReady
                                    ? Colors.blue.shade200
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.print_rounded,
                                color: PrinterManager().isReady
                                    ? Colors.blue.shade700
                                    : Colors.grey.shade600,
                                size: 22,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PrintOptionPage(),
                                  ),
                                ).then(
                                  (_) => setState(() {}),
                                ); // Refresh status warna icon setelah kembali
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. DATE SECTION (Kanan)
                  SizedBox(
                    width: 200,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        DateFormat('EEEE, d MMM yyyy').format(DateTime.now()),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // MAIN CONTENT SECTION
            Expanded(
              child: Row(
                children: [
                  _buildSidebar(),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: lightGrey,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                        ),
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
                              Text(
                                "${_filteredMenuList.length} Produk ditemukan",
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: _loadingMenu
                                ? Center(
                                    child: CircularProgressIndicator(
                                      color: primaryBlue,
                                    ),
                                  )
                                : _filteredMenuList.isEmpty
                                ? _buildEmptyState()
                                : GridView.builder(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    gridDelegate:
                                        const SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 180,
                                          childAspectRatio: 0.8,
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 16,
                                        ),
                                    itemCount: _filteredMenuList.length,
                                    itemBuilder: (context, index) => MenuCard(
                                      index: index,
                                      primaryBlue: primaryBlue,
                                      menu: _filteredMenuList[index],
                                      onAddToCart: () =>
                                          _addToCart(_filteredMenuList[index]),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // CART SECTION
                  Cart(
                    cartVisible: _cartVisible,
                    onShow: () => setState(() => _cartVisible = true),
                    onHide: () => setState(() => _cartVisible = false),
                    primaryBlue: primaryBlue,
                    bgWhite: bgWhite,
                    cartItems: _cartItems,
                    totalPrice: _getTotalPrice(),

                    onCheckout:
                        (String metode, int nominalBayar, int kembalian) async {
                          if (_cartItems.isEmpty) return;

                          showDialog(
                            context: context,
                            builder: (dialogContext) => CheckoutDialog(
                              paymentMethod: metode,
                              cartItems: List.from(_cartItems),
                              totalPrice: _getTotalPrice(),
                              nominalBayar: nominalBayar,
                              onConfirm: () async {
                                int transaksiId =
                                    await AppDatabase.simpanTransaksi(
                                      List.from(_cartItems),
                                      _getTotalPrice(),
                                      metode,
                                    );

                                // Cetak ke Thermal
                                try {
                                  await NotaService_thermal.cetakNota(
                                    items: List.from(_cartItems),
                                    total: _getTotalPrice(),
                                    transactionId: transaksiId,
                                    metodeBayar: metode,
                                    bayar: nominalBayar,
                                    kembalian: kembalian,
                                  );

                                  setState(() {
                                    _cartItems.clear();
                                    _cashController.clear();
                                  });
                                } catch (e) {
                                  // Jika cetak gagal, transaksi tetap tersimpan tapi lempar error
                                  throw {
                                    'id': transaksiId,
                                    'error': e.toString(),
                                  };
                                }

                                return transaksiId;
                              },
                            ),
                          );
                        },

                    onRemoveItem: (index) =>
                        setState(() => _cartItems.removeAt(index)),
                    onUpdateQuantity: (index, newQty) {
                      setState(() {
                        if (newQty <= 0) {
                          _cartItems.removeAt(index);
                        } else {
                          _cartItems[index]['qty'] = newQty;
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

  // SIDEBAR & CATEGORY SECTION
  Widget _buildSidebar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _sidebarVisible ? 240 : 70,
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
                  const Text(
                    'KATEGORI',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                IconButton(
                  icon: Icon(
                    _sidebarVisible ? Icons.arrow_back_ios_new : Icons.menu,
                    size: 20,
                  ),
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
                      strokeWidth: 2,
                      color: primaryBlue,
                    ),
                  )
                : ListView.builder(
                    itemCount: _kategoriList.length,
                    itemBuilder: (context, index) =>
                        _categoryItem(_kategoriList[index]),
                  ),
          ),
          const Divider(height: 1),
          _buildAdminButton(),
        ],
      ),
    );
  }

  Widget _buildAdminButton() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: InkWell(
        onTap: () => showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const LoginPopup(),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 12,
            horizontal: _sidebarVisible ? 16 : 0,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: _sidebarVisible
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Icon(Icons.settings_suggest, color: primaryBlue, size: 20),
              if (_sidebarVisible) ...[
                const SizedBox(width: 15),
                const Text(
                  'Kelola Menu',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),
        ),
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
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
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
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? "Menu belum tersedia"
                : "Produk tidak ditemukan",
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
