import 'package:flutter/material.dart';
import 'package:kasir/komponen/formatcurrency.dart';

class Cart extends StatefulWidget {
  final bool cartVisible;
  final VoidCallback onShow;
  final VoidCallback onHide;
  final Color primaryBlue;
  final Color bgWhite;
  final List<Map<String, dynamic>> cartItems;
  final int totalPrice;
  final Function(int)? onRemoveItem;
  final Function(int, int)? onUpdateQuantity;

  final Function(String method, int cashAmount, int change)? onCheckout;

  const Cart({
    super.key,
    required this.cartVisible,
    required this.onShow,
    required this.onHide,
    required this.primaryBlue,
    required this.bgWhite,
    this.cartItems = const [],
    this.totalPrice = 0,
    this.onRemoveItem,
    this.onUpdateQuantity,
    this.onCheckout,
  });

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  String selectedMethod = 'Cash';
  final TextEditingController _cashController = TextEditingController();

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  int get _inputCash {
    return int.tryParse(
          _cashController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: widget.cartVisible ? 320 : 60,
      decoration: BoxDecoration(
        color: widget.bgWhite,
        boxShadow: [
          if (widget.cartVisible)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(-2, 0),
            ),
        ],
        border: Border(left: BorderSide(color: Colors.grey.shade200)),
      ),
      child: widget.cartVisible ? _buildFullCart() : _buildCollapsedCart(),
    );
  }

  Widget _buildCollapsedCart() {
    return InkWell(
      onTap: widget.onShow,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Badge(
            label: Text(widget.cartItems.length.toString()),
            isLabelVisible: widget.cartItems.isNotEmpty,
            child: Icon(
              Icons.shopping_cart_outlined,
              color: widget.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullCart() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'KERANJANG (${widget.cartItems.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close, size: 20),
                onPressed: widget.onHide,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: widget.cartItems.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: widget.cartItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _buildCartItem(index),
                ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [_buildPaymentSection(), _buildFooter()],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Metode Pembayaran',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: ['Cash', 'QRIS', 'Debit'].map((method) {
              bool isSelected = selectedMethod == method;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    selectedMethod = method;
                    if (method != 'Cash') _cashController.clear();
                    if (method == 'Cash') _showCashInputSheet();
                  }),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? widget.primaryBlue : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? widget.primaryBlue
                            : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      method,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (selectedMethod == 'Cash') ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: _showCashInputSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.primaryBlue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Bayar Tunai:",
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        Text(
                          _cashController.text.isEmpty
                              ? "Rp 0"
                              : "Rp ${_cashController.text}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.edit_note, color: widget.primaryBlue),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter() {
    // Logika Perhitungan
    int bayar = selectedMethod == 'Cash' ? _inputCash : widget.totalPrice;
    int kembalian = bayar - widget.totalPrice;
    bool isUangCukup = bayar >= widget.totalPrice;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selectedMethod == 'Cash' && _inputCash > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Kembalian', style: TextStyle(fontSize: 12)),
                Text(
                  'Rp${_formatRupiah(kembalian < 0 ? 0 : kembalian)}',
                  style: TextStyle(
                    color: kembalian < 0 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                'Rp${_formatRupiah(widget.totalPrice)}',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: widget.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            // Tombol mati jika keranjang kosong atau uang cash kurang
            onPressed: widget.cartItems.isEmpty || !isUangCukup
                ? null
                : () {
                    widget.onCheckout?.call(
                      selectedMethod,
                      bayar,
                      kembalian < 0 ? 0 : kembalian,
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.primaryBlue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'CHECKOUT',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showCashInputSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar sheet naik mengikuti keyboard
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(
            context,
          ).viewInsets.bottom, // Geser ke atas keyboard
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Input Pembayaran Cash",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _cashController,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  prefixText: 'Rp ',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryBlue,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "SIMPAN NOMINAL",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem(int index) {
    final item = widget.cartItems[index];
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['nama'] ?? '-',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Rp${_formatRupiah(item['harga'])}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        Container(
          height: 32,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _qtyBtn(Icons.remove, () {
                if (item['qty'] > 1) {
                  widget.onUpdateQuantity?.call(index, item['qty'] - 1);
                } else {
                  widget.onRemoveItem?.call(index);
                }
              }),
              Container(
                width: 30,
                alignment: Alignment.center,
                child: Text(
                  '${item['qty']}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _qtyBtn(
                Icons.add,
                () => widget.onUpdateQuantity?.call(index, item['qty'] + 1),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(
            Icons.delete_sweep_outlined,
            color: Colors.red,
            size: 20,
          ),
          onPressed: () => widget.onRemoveItem?.call(index),
        ),
      ],
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(width: 30, child: Icon(icon, size: 16)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: 40,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 8),
          Text(
            'Keranjang Kosong',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _formatRupiah(dynamic value) {
    if (value == null) return '0';
    final n = value is int ? value : int.tryParse(value.toString()) ?? 0;
    return n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}
