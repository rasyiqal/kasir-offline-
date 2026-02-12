import 'package:flutter/material.dart';
import 'package:kasir/auth/login.dart';
import 'package:kasir/auth/resetpindialog.dart';

class EmptyWarningDialog extends StatelessWidget {
  const EmptyWarningDialog({super.key});

  static Future<void> show(BuildContext context) async {
    bool loginSuccess = false;

    while (!loginSuccess) {
      if (!context.mounted) break;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const EmptyWarningDialog(),
      );

      if (!context.mounted) break;

      final dynamic result = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const LoginPopup(),
      );

      if (result == true) {
        loginSuccess = true;
      } else if (result == "reset") {
        if (context.mounted) {
          await showDialog(
            context: context,
            builder: (context) => const ResetPinDialog(),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined, 
                color: Colors.orange,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Data Belum Diatur',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Menu dan kategori masih kosong. Silakan masuk ke panel pengelola untuk menambahkan data produk Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),

            // Button Section
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.settings_suggest_rounded, size: 22),
                    SizedBox(width: 12),
                    Text(
                      'Buka Kelola Menu',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}