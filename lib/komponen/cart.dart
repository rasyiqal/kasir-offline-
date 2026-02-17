import 'package:flutter/material.dart';

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
  final Function(String)? onCheckout;

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

        // Bagian list tetap Expanded
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [_buildPaymentSection(), _buildFooter()],
            ),
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
                  onTap: () => setState(() => selectedMethod = method),
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
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
            onPressed: widget.cartItems.isEmpty
                ? null
                : () => widget.onCheckout?.call(selectedMethod),
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
