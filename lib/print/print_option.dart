import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:kasir/print/print_manager.dart';

class PrintOptionPage extends StatefulWidget {
  const PrintOptionPage({super.key});

  @override
  State<PrintOptionPage> createState() => _PrintOptionPageState();
}

class _PrintOptionPageState extends State<PrintOptionPage> {
  final _printerPlugin = FlutterThermalPrinter.instance;
  List<Printer> _printers = [];
  bool _isScanning = false;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _startScan() async {
    setState(() {
      _isScanning = true;
      _printers = [];
    });

    // Jalankan scan untuk USB dan BLE (Bluetooth)
    await _printerPlugin.getPrinters(connectionTypes: [
      ConnectionType.BLE,
      ConnectionType.USB,
    ]);

    _subscription = _printerPlugin.devicesStream.listen((List<Printer> event) {
      if (mounted) {
        setState(() {
          _printers = event;
          _isScanning = false;
        });
      }
    });

    // Timeout scanning setelah 10 detik agar tidak berat
    Timer(const Duration(seconds: 10), () {
      if (mounted && _isScanning) {
        setState(() => _isScanning = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Pengaturan Printer", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (_isScanning)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _startScan,
            )
        ],
      ),
      body: Column(
        children: [
          // Header Status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    PrinterManager().isReady 
                      ? "Printer aktif: ${PrinterManager().selectedPrinter?.name}"
                      : "Pilih printer thermal dari daftar di bawah",
                    style: TextStyle(color: Colors.blue.shade900, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _printers.isEmpty 
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _printers.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final printer = _printers[index];
                    bool isSelected = PrinterManager().selectedPrinter?.address == printer.address;

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade200, width: 1.5),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                        ]
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected ? Colors.blue : Colors.grey.shade100,
                          child: Icon(
                            printer.connectionType == ConnectionType.USB ? Icons.usb : Icons.bluetooth,
                            color: isSelected ? Colors.white : Colors.grey,
                          ),
                        ),
                        title: Text(printer.name ?? "Tanpa Nama", style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(printer.address ?? "No Address"),
                        trailing: isSelected 
                          ? const Icon(Icons.check_circle, color: Colors.blue)
                          : const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () async {
                          setState(() => PrinterManager().selectedPrinter = printer);
                          
                          // Langsung coba hubungkan
                          await _printerPlugin.connect(printer);
                          
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("${printer.name} terpilih sebagai printer utama"))
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.print_disabled_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _isScanning ? "Mencari Printer..." : "Printer tidak ditemukan",
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          if (!_isScanning)
            ElevatedButton(
              onPressed: _startScan,
              child: const Text("Coba Lagi"),
            )
        ],
      ),
    );
  }
}