import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:intl/intl.dart';
import 'package:kasir/print/print_manager.dart';

class NotaLaporanService_thermal {
  static String formatCurrency(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  static Future<void> cetakLaporan({
    required List<Map<String, dynamic>> data,
    required int range,
    required int grandTotal,
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

    // --- HEADER LAPORAN ---
    bytes += generator.text(
      "LAPORAN PENDAPATAN",
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size1,
      ),
    );
    
    bytes += generator.text(
      "Satoe Rock Steak",
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    
    bytes += generator.text(
      "Periode: $range Hari Terakhir",
      styles: const PosStyles(align: PosAlign.center),
    );

    final now = DateTime.now();
    final dateStr = DateFormat('dd-MM-yy HH:mm').format(now);
    bytes += generator.text(
      "Dicetak: $dateStr",
      styles: const PosStyles(align: PosAlign.center),
    );
    
    bytes += generator.hr();

    // --- HEADER TABEL ---
    bytes += generator.row([
      PosColumn(text: "Tgl/Metode", width: 7, styles: const PosStyles(bold: true)),
      PosColumn(text: "Total", width: 5, styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.hr();

    // --- DATA LAPORAN ---
    for (var item in data) {
      final tgl = DateFormat('dd/MM').format(DateTime.parse(item['hari']));
      final metode = item['metode_pembayaran'].toString();
      final totalHarian = item['total_harian'] as int;

      bytes += generator.row([
        PosColumn(text: "$tgl ($metode)", width: 7),
        PosColumn(
          text: formatCurrency(totalHarian), 
          width: 5, 
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }
    
    bytes += generator.hr(ch: '=');

    // --- GRAND TOTAL ---
    bytes += generator.row([
      PosColumn(text: "GRAND TOTAL", width: 6, styles: const PosStyles(bold: true)),
      PosColumn(
        text: "Rp ${formatCurrency(grandTotal)}",
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);

    // --- FOOTER ---
    bytes += generator.feed(1);
    bytes += generator.text(
      "-- Laporan Selesai --",
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.feed(3);
    bytes += generator.cut();

    // Kirim data ke Printer
    await printerPlugin.printData(savedPrinter, bytes);
  }
}