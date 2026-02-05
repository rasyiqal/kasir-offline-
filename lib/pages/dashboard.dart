import 'package:flutter/material.dart';
import 'package:kasir/pages/admin/kategori.dart';
import 'package:kasir/pages/admin/menu.dart';
import 'package:kasir/pages/admin/input_kategori.dart';
import 'package:kasir/pages/admin/input_menu.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  final Color primaryBlue = const Color(0xFF007AFF); // Blue ala iOS/Modern
  final Color bgSurface = const Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSurface,
      body: Row(
        children: [
          // --- SIDEBAR ---
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 20,
                  offset: const Offset(5, 0),
                )
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('DASHBOARD',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 2)),
                const SizedBox(height: 48),
                _navItem(0, Icons.grid_view_rounded, 'Menu'),
                const SizedBox(height: 8),
                _navItem(1, Icons.layers_rounded, 'Kategori'),
                const Spacer(),
                _navItem(99, Icons.logout_rounded, 'Keluar', isLogout: true),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              _selectedIndex == 0
                                  ? 'Manajemen Menu'
                                  : 'Manajemen Kategori',
                              style: const TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.bold)),
                          Text('Kelola data item toko Anda di sini',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 14)),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            builder: (ctx) {
                              if (_selectedIndex == 0) {
                                return const InputMenuDialog();
                              } else {
                                return const InputKategoriDialog();
                              }
                            },
                          );
                          setState(
                              () {}); // Refresh tampilan setelah dialog ditutup
                        },
                        icon: const Icon(Icons.add,
                            color: Colors.white, size: 20),
                        label: const Text('Tambah Baru',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Data Area
                  Expanded(
                    child: _selectedIndex == 0
                        ? MenuTable(
                            bgSurface: bgSurface, primaryBlue: primaryBlue)
                        : const CategoryGrid(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String title,
      {bool isLogout = false}) {
    bool isActive = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? primaryBlue.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isActive
                    ? primaryBlue
                    : (isLogout ? Colors.redAccent : Colors.grey[400])),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: isActive
                    ? primaryBlue
                    : (isLogout ? Colors.redAccent : Colors.grey[600]),
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
