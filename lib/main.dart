import 'package:flutter/material.dart';
import 'package:kasir/pages/dashboard.dart';
import 'package:kasir/pages/kasir.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

void main() {
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
      initialRoute: '/kasir',
      routes: {
        '/kasir': (context) => const KasirPage(),
        '/dashboard': (context) => const DashboardPage(),
      },
    );
  }
}
