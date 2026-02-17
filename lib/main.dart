import 'package:flutter/material.dart';
import 'package:kasir/pages/dashboard.dart';
import 'package:kasir/pages/kasir.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _requestBluetoothPermission();
  }

  Future<void> _requestBluetoothPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.bluetoothScan.request().isGranted &&
          await Permission.bluetoothConnect.request().isGranted) {
        // print("Izin Bluetooth diizinkan");
      }

      await Permission.location.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kasir App',
      theme: ThemeData(primarySwatch: Colors.blue),
      locale: const Locale('id', 'ID'),
      initialRoute: '/kasir',
      routes: {
        '/kasir': (context) => const KasirPage(),
        '/dashboard': (context) => const DashboardPage(),
      },
    );
  }
}
