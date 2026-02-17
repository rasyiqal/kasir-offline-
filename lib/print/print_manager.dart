import 'package:flutter_thermal_printer/utils/printer.dart';

class PrinterManager {
  static final PrinterManager _instance = PrinterManager._internal();
  factory PrinterManager() => _instance;
  PrinterManager._internal();
  
  Printer? selectedPrinter;

  bool get isReady => selectedPrinter != null;
}