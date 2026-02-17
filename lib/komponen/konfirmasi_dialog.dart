import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasir/komponen/nota_thermal.dart';

class CheckoutDialog extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final int totalPrice;
  final Future<int> Function() onConfirm;
  final String paymentMethod;

  const CheckoutDialog({
    super.key,
    required this.cartItems,
    required this.totalPrice,
    required this.onConfirm,
    required this.paymentMethod,
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
        if (mounted) Navigator.pop(context);
      } else {
        await NotaService_thermal.cetakNota(
          items: widget.cartItems,
          total: widget.totalPrice,
          transactionId: _savedId!,
          metodeBayar: widget.paymentMethod,
        );
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (e is Map && e.containsKey('id')) {
        _savedId = e['id'];
        _showErrorDialog("Transaksi Tersimpan, tapi Printer Error: ${e['error']}");
      } else {
        _showErrorDialog(e.toString());
      }
    }
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text("Masalah Printer", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white, // Mencegah warna tint di Material 3
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
                  backgroundColor: _savedId == null ? const Color(0xFFE3F2FD) : Colors.orange[50],
                  child: Icon(
                    _savedId == null ? Icons.payments_outlined : Icons.print_disabled_outlined,
                    color: _savedId == null ? const Color(0xFF0D47A1) : Colors.orange[800],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _savedId == null ? "Konfirmasi Bayar" : "Gagal Cetak",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- METODE BAYAR ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Metode Pembayaran", style: TextStyle(color: Colors.grey, fontSize: 13)),
                  Text(
                    widget.paymentMethod.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- LIST ITEM ---
            const Text("Rincian Pesanan", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 180),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = widget.cartItems[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text("${item['qty']}x", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(item['nama'], style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
                          ),
                          Text(currencyFormat.format(item['harga'] * item['qty']), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(height: 1),
            ),

            // --- TOTAL ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Tagihan", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                Text(
                  currencyFormat.format(widget.totalPrice),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                ),
              ],
            ),

            if (_savedId != null)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[100]!),
                ),
                child: Text(
                  "Transaksi sudah tersimpan di sistem dengan ID #$_savedId. Silakan coba cetak ulang nota.",
                  style: TextStyle(color: Colors.orange[900], fontSize: 12, height: 1.4),
                ),
              ),

            const SizedBox(height: 24),

            // --- ACTIONS ---
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Batal"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _savedId == null ? const Color(0xFF0D47A1) : Colors.orange[800],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_savedId == null ? Icons.print : Icons.refresh, size: 18),
                              const SizedBox(width: 8),
                              Text(_savedId == null ? "BAYAR & CETAK" : "CETAK ULANG", style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}