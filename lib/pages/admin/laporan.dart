import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasir/auth/database.dart';
import 'package:kasir/print/nota_laporan.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  int _selectedRange = 3;
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  List<Map<String, dynamic>> _currentData = [];
  int _currentGrandTotal = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    try {
      final data = await AppDatabase.getRingkasanPendapatan(
        days: _selectedRange,
      );
      setState(() {
        _currentData = data;
        _currentGrandTotal = data.fold(
          0,
          (sum, item) => sum + (item['total_harian'] as int),
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], 
      appBar: AppBar(
        title: const Text(
          "Laporan Pendapatan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print, color: Color(0xFF0D47A1)),
            onPressed: () {
              if (_currentData.isNotEmpty) {
                NotaLaporanService_thermal.cetakLaporan(
                  data: _currentData,
                  range: _selectedRange,
                  grandTotal: _currentGrandTotal,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Tidak ada data untuk dicetak")),
                );
              }
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
          PopupMenuButton<int>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _selectedRange = value);
              _refreshData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 1, child: Text("Hari Ini")),
              const PopupMenuItem(value: 3, child: Text("3 Hari Terakhir")),
              const PopupMenuItem(value: 7, child: Text("7 Hari Terakhir")),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentData.isEmpty
          ? const Center(child: Text("Belum ada data transaksi"))
          : Column(
              children: [
                _buildHeaderTotal(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.history, size: 18, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        "Detail Harian & Metode",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _buildListLaporan()),
              ],
            ),
    );
  }

  // otal Pendapatan
  Widget _buildHeaderTotal() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D47A1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Pendapatan ($_selectedRange Hari)",
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(_currentGrandTotal),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // rincian harian
  Widget _buildListLaporan() {
    return ListView.builder(
      itemCount: _currentData.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final item = _currentData[index];
        final dateParsed = DateTime.parse(item['hari']);
        final dateFormatted = DateFormat(
          'EEEE, dd MMM yyyy',
          'id_ID',
        ).format(dateParsed);

        return Card(
          color: Colors.white,
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: item['metode_pembayaran'] == 'Cash'
                  ? Colors.green[50]
                  : Colors.purple[50],
              child: Icon(
                item['metode_pembayaran'] == 'Cash'
                    ? Icons.money
                    : Icons.qr_code,
                color: item['metode_pembayaran'] == 'Cash'
                    ? Colors.green
                    : Colors.purple,
                size: 20,
              ),
            ),
            title: Text(
              dateFormatted,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "${item['metode_pembayaran']} (${item['jumlah_transaksi']} Transaksi)",
            ),
            trailing: Text(
              currencyFormat.format(item['total_harian']),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
          ),
        );
      },
    );
  }
}
