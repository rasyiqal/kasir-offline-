import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class NotaLaporanService {
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
    final doc = pw.Document();
    final now = DateTime.now();
    final String dateStr = DateFormat('dd-MM-yy : HH:mm').format(now);

    doc.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          58 * PdfPageFormat.mm,
          double.infinity,
          marginAll: 2 * PdfPageFormat.mm,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text("LAPORAN PENDAPATAN",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    pw.Text("Periode: $range Hari Terakhir", style: const pw.TextStyle(fontSize: 8)),
                    pw.Text("Dicetak: $dateStr", style: const pw.TextStyle(fontSize: 7)),
                  ],
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Divider(borderStyle: pw.BorderStyle.dashed, thickness: 0.5),
              
              // Header Tabel
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Tgl/Metode", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                  pw.Text("Total", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 3),

              // Data Laporan
              pw.ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final item = data[index];
                  final tgl = DateFormat('dd/MM').format(DateTime.parse(item['hari']));
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 1),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text("$tgl (${item['metode_pembayaran']})", style: const pw.TextStyle(fontSize: 7)),
                        pw.Text(formatCurrency(item['total_harian']), style: const pw.TextStyle(fontSize: 7)),
                      ],
                    ),
                  );
                },
              ),
              
              pw.Divider(borderStyle: pw.BorderStyle.dashed, thickness: 0.5),
              
              // Grand Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("GRAND TOTAL", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  pw.Text("Rp ${formatCurrency(grandTotal)}", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Center(child: pw.Text("-- Laporan Selesai --", style: const pw.TextStyle(fontSize: 6))),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Laporan_${range}_hari',
    );
  }
}