import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart'; // Penting untuk class Printer
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:intl/intl.dart';

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
  }) async {
    final printerPlugin = FlutterThermalPrinter.instance;
    
     await printerPlugin.getPrinters(connectionTypes: [
      ConnectionType.USB,
      ConnectionType.BLE,
    ]);
 final List<Printer> printers = await printerPlugin.devicesStream.first;

    if (printers.isEmpty) {
      print("Tidak ada printer terdeteksi");
      return;
    }

    Printer selectedPrinter = printers.first;

    // 2. Hubungkan jika belum
    if (!(selectedPrinter.isConnected ?? false)) {
      await printerPlugin.connect(selectedPrinter);
    }

    // 3. Generate Byte ESC/POS
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    final date = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    // Header
    bytes += generator.text("SKY POS", 
        styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2));
    bytes += generator.text("Jl. Contoh Alamat No. 123", styles: const PosStyles(align: PosAlign.center));
    bytes += generator.hr();

    // Info
    bytes += generator.text("No: ORD-20260215");
    bytes += generator.text("Tgl: $date");
    bytes += generator.hr();

    // Items
    for (var item in items) {
      int subtotal = (item['qty'] as int) * (item['harga'] as int);
      bytes += generator.text(item['nama'], styles: const PosStyles(bold: true));
      bytes += generator.row([
        PosColumn(text: "${item['qty']} x ${formatCurrency(item['harga'])}", width: 8),
        PosColumn(text: formatCurrency(subtotal), width: 4, styles: const PosStyles(align: PosAlign.right)),
      ]);
    }

    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: "TOTAL", width: 6, styles: const PosStyles(bold: true)),
      PosColumn(text: "Rp ${formatCurrency(total)}", width: 6, styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);

    bytes += generator.feed(2);
    bytes += generator.text("Terima Kasih", styles: const PosStyles(align: PosAlign.center));
    bytes += generator.cut();

    // 4. Kirim ke printer (Menggunakan printData sesuai doc)
    await printerPlugin.printData(
      selectedPrinter,
      bytes,
      longData: true,
    );
  }
}