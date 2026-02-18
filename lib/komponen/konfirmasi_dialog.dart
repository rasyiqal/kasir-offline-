import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasir/print/nota_thermal.dart';
import 'package:kasir/print/print_manager.dart';

class CheckoutDialog extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final int totalPrice;
  final Future<int> Function() onConfirm;
  final String paymentMethod;
  final int nominalBayar;

  const CheckoutDialog({
    super.key,
    required this.cartItems,
    required this.totalPrice,
    required this.onConfirm,
    required this.paymentMethod,
    required this.nominalBayar,
  });

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  bool _isLoading = false;
  int? _savedId;

  Future<void> _handleConfirm() async {
    setState(() => _isLoading = true);

    try {
      if (_savedId == null) {
        _savedId = await widget.onConfirm();
      }

      if (PrinterManager().selectedPrinter == null) {
        throw "Printer belum dipilih. Silakan atur printer di menu Pengaturan.";
      }

      int kembalian = widget.nominalBayar - widget.totalPrice;

      await NotaService_thermal.cetakNota(
        items: widget.cartItems,
        total: widget.totalPrice,
        transactionId: _savedId!,
        metodeBayar: widget.paymentMethod,
        bayar: widget.nominalBayar,
        kembalian: kembalian < 0 ? 0 : kembalian,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);

      if (_savedId != null) {
        _showErrorDialog(
          "Transaksi Berhasil (#$_savedId), gagal cetak: $e",
        );
      } else {
        _showErrorDialog(e.toString());
      }
    }
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Peringatan"),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Tutup")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID', symbol: 'Rp', decimalDigits: 0,
    );

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFE3F2FD),
                  child: Icon(Icons.shopping_basket_outlined, color: Colors.blue[900]),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Rincian Pesanan",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16), 

            // --- LIST ITEM (TAMPILKAN ITEM DI SINI) ---
            const Text("Item yang dibeli:", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200), 
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: widget.cartItems.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  itemBuilder: (context, index) {
                    final item = widget.cartItems[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['nama'], style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                                Text("${item['qty']} x ${currencyFormat.format(item['harga'])}", 
                                     style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                          ),
                          Text(currencyFormat.format(item['qty'] * item['harga']), 
                               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(thickness: 1, color: Colors.black12),
            ),

            // --- RINGKASAN PEMBAYARAN ---
            _buildRowInfo("Metode", widget.paymentMethod.toUpperCase()),
            const SizedBox(height: 4),
            _buildRowInfo("Total Tagihan", currencyFormat.format(widget.totalPrice), isBold: true),
            
            if (widget.paymentMethod == 'Cash') ...[
              const SizedBox(height: 4),
              _buildRowInfo("Uang Bayar", currencyFormat.format(widget.nominalBayar)),
              const SizedBox(height: 4),
              _buildRowInfo(
                "Kembalian", 
                currencyFormat.format(widget.nominalBayar - widget.totalPrice),
                valueColor: Colors.green[700],
                isBold: true
              ),
            ],

            const SizedBox(height: 24),

            // --- ACTIONS ---
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text("Batal"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(_savedId == null ? "KONFIRMASI & CETAK" : "CETAK ULANG"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRowInfo(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}