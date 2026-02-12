import 'package:flutter/material.dart';

class Cart extends StatelessWidget {
  final bool cartVisible;
  final VoidCallback onShow;
  final VoidCallback onHide;
  final Color primaryBlue;
  final Color bgWhite;
  final List<Map<String, dynamic>> cartItems;
  final int totalPrice;
  final Function(int)? onRemoveItem;
  final Function(int, int)? onUpdateQuantity;
  final VoidCallback? onCheckout;

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
  Widget build(BuildContext context) {
    // Mini Sidebar (Tertutup)
    if (!cartVisible) {
      return GestureDetector(
        onTap: onShow,
        child: Container(
          width: 50, 
          decoration: BoxDecoration(
            color: bgWhite,
            border: Border(left: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Badge(
                label: Text(cartItems.length.toString()),
                isLabelVisible: cartItems.isNotEmpty,
                child: Icon(Icons.shopping_cart_outlined, color: primaryBlue),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: 300, 
      decoration: BoxDecoration(
        color: bgWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'KERANJANG (${cartItems.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onHide,
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // List Item
          Expanded(
            child: cartItems.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => _buildCartItem(index),
                  ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontWeight: FontWeight.w500)),
                    Text(
                      'Rp${_formatRupiah(totalPrice)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: cartItems.isEmpty ? null : onCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('CHECKOUT', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(int index) {
    final item = cartItems[index];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Info Item
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['nama'] ?? '-',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              _qtyBtn(Icons.remove, () => onUpdateQuantity?.call(index, (item['qty'] as int) - 1)),
              SizedBox(
                width: 25,
                child: Text('${item['qty']}', 
                  textAlign: TextAlign.center, 
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
                ),
              ),
              _qtyBtn(Icons.add, () => onUpdateQuantity?.call(index, (item['qty'] as int) + 1)),
            ],
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
          onPressed: () => onRemoveItem?.call(index),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, size: 14),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'Kosong',
        style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      ),
    );
  }

  String _formatRupiah(dynamic value) {
    if (value == null) return '0';
    final n = value is int ? value : int.tryParse(value.toString()) ?? 0;
    return n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}