import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasir/auth/database.dart';
import 'package:kasir/print/nota_thermal.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  List<Map<String, dynamic>> _allTransaksi = [];
  List<Map<String, dynamic>> _filteredTransaksi = [];
  List<Map<String, dynamic>> _selectedDetails = [];
  int? _selectedId;
  bool _loading = true;
  final TextEditingController _searchController = TextEditingController();

  final currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadTransaksi();
  }

  Future<void> _loadTransaksi() async {
    final db = await AppDatabase.database;
    final data = await db.query('transaksi', orderBy: 'tanggal DESC');
    setState(() {
      _allTransaksi = data;
      _filteredTransaksi = data;
      _loading = false;
    });
  }

  void _filterTransaksi(String query) {
    setState(() {
      _filteredTransaksi = _allTransaksi
          .where((trx) => trx['id'].toString().contains(query))
          .toList();
    });
  }

  Future<void> _loadDetail(int transaksiId) async {
    final db = await AppDatabase.database;
    final details = await db.query(
      'transaksi_detail',
      where: 'transaksi_id = ?',
      whereArgs: [transaksiId],
    );
    setState(() {
      _selectedId = transaksiId;
      _selectedDetails = details;
    });
  }

  // --- TAMBAH MENU KE TRANSAKSI ---
  Future<void> _addMenuToTransaksi() async {
    final db = await AppDatabase.database;
    // Ambil menu dan urutkan berdasarkan nama agar mudah dicari
    final allMenus = await db.query('menu', orderBy: 'nama ASC');

    final Map<String, dynamic>? selectedMenu = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // Background Putih
        surfaceTintColor:
            Colors.white, // Memastikan tidak ada tint ungu/biru dari Material 3
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF0D47A1), // Header Biru agar kontras
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.add_shopping_cart, color: Colors.white),
              SizedBox(width: 12),
              Text(
                "Tambah Menu",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        content: SizedBox(
          width:
              MediaQuery.of(context).size.width *
              0.4, // Atur lebar agar tidak terlalu lebar di tablet
          child: allMenus.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text("Data menu kosong", textAlign: TextAlign.center),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: allMenus.length,
                  separatorBuilder: (context, index) =>
                      Divider(color: Colors.grey[100]),
                  itemBuilder: (context, index) {
                    final menu = allMenus[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[50],
                        child: const Icon(
                          Icons.restaurant_menu,
                          color: Color(0xFF0D47A1),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        menu['nama'].toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      subtitle: Text(
                        currencyFormat.format(menu['harga'] as int),
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.grey,
                      ),
                      onTap: () => Navigator.pop(context, menu),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Batal",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (selectedMenu != null && _selectedId != null) {
      await db.insert('transaksi_detail', {
        'transaksi_id': _selectedId,
        'menu_id': selectedMenu['id'],
        'nama_menu': selectedMenu['nama'].toString(),
        'qty': 1,
        'harga_saat_ini': selectedMenu['harga'] as int,
        'subtotal': selectedMenu['harga'] as int,
      });
      await _updateTotalTransaksi();
    }
  }

  // --- HAPUS SATU ITEM MENU ---
  Future<void> _deleteItem(int detailId) async {
    final db = await AppDatabase.database;
    await db.delete('transaksi_detail', where: 'id = ?', whereArgs: [detailId]);
    await _updateTotalTransaksi();
  }

  // Fungsi pembantu untuk sinkronisasi total harga
  Future<void> _updateTotalTransaksi() async {
    final db = await AppDatabase.database;
    final result = await db.rawQuery(
      'SELECT SUM(subtotal) as total FROM transaksi_detail WHERE transaksi_id = ?',
      [_selectedId],
    );
    int newTotal = (result.first['total'] as int?) ?? 0;

    await db.update(
      'transaksi',
      {'total_harga': newTotal},
      where: 'id = ?',
      whereArgs: [_selectedId],
    );

    await _loadTransaksi();
    await _loadDetail(_selectedId!);
  }

  // --- FUNGSI CETAK ULANG ---
  void _reprint() {
    if (_selectedId == null) return;
    final trx = _allTransaksi.firstWhere((t) => t['id'] == _selectedId);

    List<Map<String, dynamic>> itemsToPrint = _selectedDetails
        .map(
          (d) => {
            'nama': d['nama_menu'],
            'qty': d['qty'],
            'harga': d['harga_saat_ini'],
          },
        )
        .toList();

    NotaService_thermal.cetakNota(
      items: itemsToPrint,
      total: trx['total_harga'],
      metodeBayar: trx['metode_pembayaran'] ?? 'Cash',
      transactionId: _selectedId,
    );
  }

  Future<void> _editQty(Map<String, dynamic> item) async {
    int currentQty = item['qty'];
    final TextEditingController qtyController = TextEditingController(
      text: currentQty.toString(),
    );

    qtyController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: qtyController.text.length,
    );

    final newQty = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ubah Jumlah",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${item['nama_menu']}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        content: TextField(
          controller: qtyController,
          keyboardType: TextInputType.number,
          autofocus: true, 
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: "0",
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(qtyController.text);
              if (val != null && val >= 0) {
                Navigator.pop(context, val);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D47A1),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Simpan"),
          ),
        ],
      ),
    );

    if (newQty != null && newQty != currentQty) {
      if (newQty == 0) {
        await _deleteItem(item['id']);
      } else {
        final db = await AppDatabase.database;
        int hargaSatuan = item['harga_saat_ini'];
        int newSubtotal = hargaSatuan * newQty;

        await db.update(
          'transaksi_detail',
          {'qty': newQty, 'subtotal': newSubtotal},
          where: 'id = ?',
          whereArgs: [item['id']],
        );
        await _updateTotalTransaksi();
      }
    }
  }

  Future<void> _deleteTransaksi(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Seluruh Transaksi?"),
        content: const Text("Riwayat transaksi ini akan hilang selamanya."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final db = await AppDatabase.database;
      await db.delete('transaksi', where: 'id = ?', whereArgs: [id]);
      await db.delete(
        'transaksi_detail',
        where: 'transaksi_id = ?',
        whereArgs: [id],
      );
      setState(() {
        _selectedId = null;
        _selectedDetails = [];
      });
      _loadTransaksi();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTransaksiList(),
              const SizedBox(width: 24),
              _buildDetailPane(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.only(bottom: 24),
      child: TextField(
        controller: _searchController,
        onChanged: _filterTransaksi,
        decoration: InputDecoration(
          hintText: 'Cari nomor transaksi...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTransaksiList() {
    return Expanded(
      flex: 2,
      child: _filteredTransaksi.isEmpty
          ? const Center(child: Text("Transaksi tidak ditemukan"))
          : ListView.builder(
              itemCount: _filteredTransaksi.length,
              itemBuilder: (context, index) {
                final trx = _filteredTransaksi[index];
                bool isSelected = _selectedId == trx['id'];
                return Card(
                  elevation: isSelected ? 2 : 0,
                  color: isSelected
                      ? Colors.blue.withOpacity(0.05)
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? Colors.blue : Colors.transparent,
                    ),
                  ),
                  child: ListTile(
                    onTap: () => _loadDetail(trx['id']),
                    title: Text(
                      "Trx #${trx['id']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      DateFormat(
                        'dd MMM, HH:mm',
                      ).format(DateTime.parse(trx['tanggal'])),
                    ),
                    trailing: Text(
                      currencyFormat.format(trx['total_harga']),
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDetailPane() {
    return Expanded(
      flex: 3,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: _selectedId == null
            ? const Center(child: Text("Pilih transaksi"))
            : _buildDetailContent(),
      ),
    );
  }

  Widget _buildDetailContent() {
    final selectedTrx = _allTransaksi.firstWhere((t) => t['id'] == _selectedId);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "DETAIL TRANSAKSI",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _reprint,
                    icon: const Icon(Icons.print, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: _addMenuToTransaksi,
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.green,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _deleteTransaksi(_selectedId!),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                ],
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedDetails.length,
              itemBuilder: (context, index) {
                final item = _selectedDetails[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ActionChip(
                    label: Text("${item['qty']}x"),
                    onPressed: () => _editQty(item),
                  ),
                  title: Text("${item['nama_menu']}"),
                  subtitle: Text(currencyFormat.format(item['harga_saat_ini'])),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currencyFormat.format(item['subtotal']),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          size: 20,
                          color: Colors.red,
                        ),
                        onPressed: () => _deleteItem(item['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(thickness: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "TOTAL",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                currencyFormat.format(selectedTrx['total_harga']),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
