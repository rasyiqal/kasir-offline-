import 'package:flutter/material.dart';
import 'package:kasir/auth/database.dart';
import 'package:kasir/pages/admin/kategori.dart';
import 'package:kasir/pages/admin/menu.dart';
import 'package:kasir/pages/admin/input_kategori.dart';
import 'package:kasir/pages/admin/input_menu.dart';
import 'package:kasir/pages/admin/transaksi.dart';
import 'package:kasir/pages/admin/laporan.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  final Color primaryBlue = const Color(0xFF007AFF);
  final Color bgSurface = const Color(0xFFF8F9FA);

  final GlobalKey<CategoryListState> _categoryListKey =
      GlobalKey<CategoryListState>();
  final GlobalKey<MenuTableState> _menuTableKey = GlobalKey<MenuTableState>();

  Widget _getContentTitle() {
    switch (_selectedIndex) {
      case 0:
        return const Text('Manajemen Menu');
      case 1:
        return const Text('Manajemen Kategori');
      case 2:
        return const Text('Riwayat Transaksi');
      case 3:
        return const Text('Laporan Pendapatan');
      default:
        return const Text('Dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: bgSurface,
      body: Row(
        children: [
          // --- SIDEBAR ---
          Container(
            width: 250,
            decoration: BoxDecoration(color: Colors.white),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DASHBOARD',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 48),
                _navItem(0, Icons.grid_view_rounded, 'Menu'),
                const SizedBox(height: 8),
                _navItem(1, Icons.layers_rounded, 'Kategori'),
                const SizedBox(height: 8),
                _navItem(2, Icons.history_rounded, 'Riwayat'),
                const SizedBox(height: 8),
                _navItem(3, Icons.bar_chart_rounded, 'Laporan'),
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
                          DefaultTextStyle(
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            child: _getContentTitle(),
                          ),
                          Text(
                            'Kelola data dan pantau aktivitas toko Anda',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      // Sembunyikan tombol "Tambah Baru" di riwayat dan laporan
                      if (_selectedIndex != 2 && _selectedIndex != 3)
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await showDialog(
                              context: context,

                              builder: (ctx) {
                                if (_selectedIndex == 0) {
                                  return const InputMenuDialog();
                                } else {
                                  return const InputKategoriDialog();
                                }
                              },
                            );
                            if (result == true) {
                              if (_selectedIndex == 0) {
                                _menuTableKey.currentState?.refreshMenu();
                              } else if (_selectedIndex == 1) {
                                _categoryListKey.currentState
                                    ?.refreshCategories();
                              }
                            }
                          },

                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: const Text(
                            'Tambah Baru',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  Expanded(
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: [
                        MenuTable(
                          key: _menuTableKey,
                          bgSurface: bgSurface,
                          primaryBlue: primaryBlue,
                        ),
                        CategoryList(
                          key: _categoryListKey,
                          onEdit: _editKategori,
                          onDelete: _deleteKategori,
                        ),
                        const TransaksiPage(),
                        const LaporanPage(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editKategori(Map<String, dynamic> kategoriData) async {
    final result = await showDialog(
      context: context,
      builder: (ctx) => InputKategoriDialog(kategoriData: kategoriData),
    );
    if (result == true) {
      _categoryListKey.currentState?.refreshCategories();
    }
  }

  Future<void> _deleteKategori(int kategoriId) async {
    try {
      await AppDatabase.deleteKategori(kategoriId);
      _categoryListKey.currentState?.refreshCategories();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error menghapus kategori: $e')));
      }
    }
  }

  Widget _navItem(
    int index,
    IconData icon,
    String title, {
    bool isLogout = false,
  }) {
    bool isActive = _selectedIndex == index;
    return InkWell(
      onTap: () {
        if (isLogout) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/kasir',
            (route) => false,
          );
        } else {
          setState(() => _selectedIndex = index);
        }
      },
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
            Icon(
              icon,
              color: isActive
                  ? primaryBlue
                  : (isLogout ? Colors.redAccent : Colors.grey[400]),
            ),
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
