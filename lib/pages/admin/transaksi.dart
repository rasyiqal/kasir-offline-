import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasir/auth/database.dart';

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

  // --- FUNGSI EDIT KUANTITAS ---
  Future<void> _editQty(Map<String, dynamic> item) async {
    int currentQty = item['qty'];
    final TextEditingController qtyController = TextEditingController(
      text: currentQty.toString(),
    );

    final newQty = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Jumlah: ${item['nama_menu']}"),
        content: TextField(
          controller: qtyController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Kuantitas"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, int.tryParse(qtyController.text)),
            child: const Text("Simpan"),
          ),
        ],
      ),
    );

    if (newQty != null && newQty > 0 && newQty != currentQty) {
      final db = await AppDatabase.database;
      int hargaSatuan = item['subtotal'] ~/ currentQty;
      int newSubtotal = hargaSatuan * newQty;

      await db.transaction((txn) async {
        // 1. Update baris detail
        await txn.update(
          'transaksi_detail',
          {'qty': newQty, 'subtotal': newSubtotal},
          where: 'id = ?',
          whereArgs: [item['id']],
        );

        // 2. Hitung ulang total untuk header transaksi
        final result = await txn.rawQuery(
          'SELECT SUM(subtotal) as total FROM transaksi_detail WHERE transaksi_id = ?',
          [_selectedId],
        );
        int totalBaru = result.first['total'] as int;

        await txn.update(
          'transaksi',
          {'total_harga': totalBaru},
          where: 'id = ?',
          whereArgs: [_selectedId],
        );
      });

      _loadTransaksi(); // Refresh list kiri
      _loadDetail(_selectedId!); // Refresh detail kanan
    }
  }

  Future<void> _deleteTransaksi(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_forever, color: Colors.red),
            ),
            const SizedBox(width: 16),
            const Text(
              "Hapus Transaksi",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        content: const Text(
          "Tindakan ini tidak dapat dibatalkan. Seluruh riwayat transaksi ini akan dihapus secara permanen dari sistem.",
          style: TextStyle(color: Color(0xFF64748B), height: 1.5),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(0, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              "Batal",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Ya, Hapus",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
                      width: 1,
                    ),
                  ),

                  child: ListTile(
                    onTap: () => _loadDetail(trx['id']),
                    title: Text(
                      "Trx #${trx['id']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      // Ubah ke Column agar bisa menampung 2 baris teks
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat(
                            'dd MMM yyyy, HH:mm',
                          ).format(DateTime.parse(trx['tanggal'])),
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        // Menampilkan Label Metode Pembayaran
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            trx['metode_pembayaran'] ??
                                'Cash', // Default 'Cash' jika null
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
        child: _selectedId == null ? _buildEmptyState() : _buildDetailContent(),
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
                "STRUK DIGITAL",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: Colors.grey,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _deleteTransaksi(_selectedId!),
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
                    avatar: const Icon(Icons.edit, size: 14),
                  ),
                  title: Text("${item['nama_menu']}"),
                  trailing: Text(currencyFormat.format(item['subtotal'])),
                );
              },
            ),
          ),
          const Divider(thickness: 2),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
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
                    fontWeight: FontWeight.w900,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "Pilih transaksi untuk dikelola",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
