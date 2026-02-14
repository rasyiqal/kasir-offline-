import 'package:flutter/material.dart';
import 'package:kasir/pages/dashboard.dart';
import 'package:kasir/pages/kasir.dart';
import 'package:permission_handler/permission_handler.dart'; 

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
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
    
    print("Status Izin: $statuses");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kasir App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/kasir',
      routes: {
        '/kasir': (context) => const KasirPage(),
        '/dashboard': (context) => const DashboardPage(),
      },
    );
  }
}