import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
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
    required String metodeBayar,
    int? transactionId, 
  }) async {
    final doc = pw.Document();
    final now = DateTime.now();
    
    final String dateStr = DateFormat('dd-MM-yy : HH:mm').format(now);
    final String timestamp = DateFormat('yyyyHHmm').format(now);
    final String orderNumber = "TRX$timestamp${(transactionId ?? 0).toString().padLeft(2, '0')}";

    final imageBytes = await rootBundle.load('assets/logo/logo-struk.png'); 
    final logoImage = pw.MemoryImage(imageBytes.buffer.asUint8List());

    doc.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          58 * PdfPageFormat.mm,
          double.infinity,
          marginAll: 2 * PdfPageFormat.mm,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // --- HEADER: LOGO & INFO TOKO ---
              pw.Center(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(
                      height: 40,
                      width: 40,
                      child: pw.Image(logoImage),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      "Satoe Rock Steak",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                    ),
                    pw.Text("JI. Arya Wiraraja, GedunganTimur, Kec.Batuan", textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 7)),
                    pw.Text("Kabupaten Sumenep,Jawa Timur-6945", textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 7)),
                    pw.Text("087728301870", textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 7)),
                    pw.Text("steaksatoerock@gmail.com", textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 7)),
                  ],
                ),
              ),

              pw.SizedBox(height: 4),
              pw.Divider(borderStyle: pw.BorderStyle.dashed, thickness: 0.5),

              // --- INFO TRANSAKSI ---
              pw.DefaultTextStyle(
                style: const pw.TextStyle(fontSize: 7),
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [pw.Text("No. Pesanan:"), pw.Text(orderNumber)],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [pw.Text("Tgl & Jam:"), pw.Text(dateStr)],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [pw.Text("Metode:"), pw.Text(metodeBayar.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold))],
                    ),
                  ],
                ),
              ),

              pw.Divider(borderStyle: pw.BorderStyle.dashed, thickness: 0.5),

              // --- ITEM TRANSAKSI ---
              pw.ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  int subtotal = (item['qty'] as int) * (item['harga'] as int);

                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 1),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("${item['nama']}", style: const pw.TextStyle(fontSize: 8)),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              "${item['qty']} x ${formatCurrency(item['harga'])}",
                              style: const pw.TextStyle(fontSize: 7),
                            ),
                            pw.Text(
                              formatCurrency(subtotal),
                              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              pw.Divider(borderStyle: pw.BorderStyle.dashed, thickness: 0.5),

              // --- TOTAL ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "TOTAL",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
                  ),
                  pw.Text(
                    "Rp ${formatCurrency(total)}",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
                  ),
                ],
              ),

              pw.SizedBox(height: 15),

              // --- FOOTER ---
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      "TERIMA KASIH",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
                    ),
                    pw.Text(
                      "Atas Kunjungan Anda",
                      style: const pw.TextStyle(fontSize: 7),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Nota_$orderNumber',
      dynamicLayout: false,
    );
  }
}