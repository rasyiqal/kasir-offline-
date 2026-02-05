import 'package:flutter/material.dart';

class Cart extends StatelessWidget {
  final bool cartVisible;
  final VoidCallback onShow;
  final VoidCallback onHide;
  final Color primaryBlue;
  final Color bgWhite;

  const Cart({
    Key? key,
    required this.cartVisible,
    required this.onShow,
    required this.onHide,
    required this.primaryBlue,
    required this.bgWhite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Keadaan ketika keranjang disembunyikan (Sidebar Kecil)
    if (!cartVisible) {
      return GestureDetector(
        onTap: onShow,
        child: Container(
          width: 60, // Sedikit lebih lebar agar proporsional
          decoration: BoxDecoration(
            color: bgWhite,
            border: Border(left: BorderSide(color: Colors.grey.shade100)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.shopping_cart_outlined,
                    color: primaryBlue, size: 24),
              ),
              const SizedBox(height: 10),
              // Indikator jumlah item bisa diletakkan di sini nanti
            ],
          ),
        ),
      );
    }

    // Keadaan ketika keranjang terbuka
    return Container(
      width: 350, // Disamakan dengan lebar search bar agar seimbang
      decoration: BoxDecoration(
        color: bgWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(-4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Keranjang
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.shopping_bag_outlined,
                        color: primaryBlue, size: 22),
                    const SizedBox(width: 12),
                    const Text(
                      'KERANJANG',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.close, size: 18, color: Colors.grey),
                  ),
                  onPressed: onHide,
                ),
              ],
            ),
          ),

          // List Item (Empty State)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_shopping_cart_rounded,
                      size: 60, color: Colors.grey.shade200),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada item terpilih',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Footer & Summary Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: bgWhite,
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Bayar',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                    const Text(
                      'Rp 0',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text(
                    'BAYAR SEKARANG',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
