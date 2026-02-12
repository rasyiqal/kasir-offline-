import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class NotaService {
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
    final doc = pw.Document();
    final date = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    // Data Dummy Nomor Pesanan & Kasir
    const String orderNumber = "ORD-20260211-001";
    const String namaKasir = "Kasir Sky";

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
              // Header Toko
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      "SKY POS",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    pw.Text(
                      "Jl. Contoh Alamat No. 123",
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.Text(
                      "Telp: 0812-3456-7890",
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 5),
              pw.Divider(borderStyle: pw.BorderStyle.dashed, thickness: 0.5),

              // Informasi Transaksi
              pw.DefaultTextStyle(
                style: const pw.TextStyle(fontSize: 8),
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [pw.Text("No"), pw.Text(orderNumber)],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [pw.Text("Tgl"), pw.Text("$date")],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [pw.Text("Kasir"), pw.Text(namaKasir)],
                    ),
                  ],
                ),
              ),

              pw.Divider(borderStyle: pw.BorderStyle.dashed, thickness: 0.5),

              // Header Tabel Item
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        "Item",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 8,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text(
                        "Qty",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 8,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        "Total",
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // List Item
              pw.ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  int subtotal = (item['qty'] as int) * (item['harga'] as int);

                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 1),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          flex: 3,
                          child: pw.Text(
                            "${item['nama']}",
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            "${item['qty']}",
                            textAlign: pw.TextAlign.center,
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            formatCurrency(subtotal),
                            textAlign: pw.TextAlign.right,
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              pw.Divider(borderStyle: pw.BorderStyle.dashed, thickness: 0.5),

              // Bagian Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "TOTAL",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                  ),
                  pw.Text(
                    "Rp ${formatCurrency(total)}",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 15),

              // Footer
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      "Terima Kasih Atas Kunjungan Anda",
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontStyle: pw.FontStyle.italic,
                        fontSize: 7,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      "Kiritik dan Saran",
                      style: const pw.TextStyle(fontSize: 6),
                    ),
                    pw.Text(
                      "085xx-xxx-xx",
                      style: pw.TextStyle(
                        fontSize: 6,
                        fontStyle: pw.FontStyle.italic,
                      ),
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

    // Kirim ke printer
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Nota_$orderNumber',
    );
  }
}
