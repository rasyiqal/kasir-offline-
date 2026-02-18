import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:intl/intl.dart';
import 'package:kasir/print/print_manager.dart';

class NotaService_thermal {
  static String formatCurrency(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  static Future<void> cetakNota({
    required List<Map<String, dynamic>> items,
    required int total,
    required String metodeBayar,
    int? transactionId,
    required int bayar, 
    required int kembalian,
  }) async {
    final printerPlugin = FlutterThermalPrinter.instance;
    final savedPrinter = PrinterManager().selectedPrinter;

    if (savedPrinter == null) {
      throw "Printer belum dipilih. Silakan atur printer di menu Pengaturan.";
    }

    if (!(savedPrinter.isConnected ?? false)) {
      await printerPlugin.connect(savedPrinter);
    }

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    // --- HEADER ---
    bytes += generator.text(
      "Satoe Rock Steak",
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    bytes += generator.text(
      "Jl.Arya Wiraraja,Gedungan Timur",
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      "Kec.Batuan,Sumenep",
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      "Telp: 087728301870",
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      "steaksatoerock@gmail.com",
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.hr();

    // --- INFO TRANSAKSI ---
    final now = DateTime.now();
    final dateStr = DateFormat('dd-MM-yy HH:mm').format(now);
    final orderNumber =
        "TRX${DateFormat('yyyyHHmm').format(now)}${(transactionId ?? 0).toString().padLeft(2, '0')}";

    bytes += generator.row([
      PosColumn(text: "No", width: 4),
      PosColumn(
        text: orderNumber,
        width: 8,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: "Tgl", width: 4),
      PosColumn(
        text: dateStr,
        width: 8,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: "Pembayaran", width: 4),
      PosColumn(
        text: metodeBayar.toUpperCase(),
        width: 8,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);
    bytes += generator.hr();

    // --- LIST ITEMS ---
    for (var item in items) {
      int subtotal = (item['qty'] as int) * (item['harga'] as int);
      bytes += generator.text(
        item['nama'],
        styles: const PosStyles(bold: true),
      );
      bytes += generator.row([
        PosColumn(
          text: "${item['qty']} x ${formatCurrency(item['harga'])}",
          width: 7,
        ),
        PosColumn(
          text: formatCurrency(subtotal),
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }
    bytes += generator.hr(ch: '=');

    // --- TOTAL ---
    bytes += generator.row([
      PosColumn(text: "TOTAL", width: 6, styles: const PosStyles(bold: true)),
      PosColumn(
        text: "Rp ${formatCurrency(total)}",
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);

    // --- BAYAR & KEMBALIAN ---

    bytes += generator.row([
      PosColumn(text: "BAYAR", width: 6),
      PosColumn(
        text: "Rp ${formatCurrency(bayar)}",
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(text: "KEMBALIAN", width: 6),
      PosColumn(
        text: "Rp ${formatCurrency(kembalian)}",
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    // --- FOOTER ---
    bytes += generator.feed(1);
    bytes += generator.text(
      "TERIMA KASIH",
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      "Atas Kunjungan Anda",
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.feed(1);

    bytes += generator.cut();

    await printerPlugin.printData(savedPrinter, bytes);
  }
}
