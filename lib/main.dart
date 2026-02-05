import 'package:flutter/material.dart';
import 'package:kasir/auth/login.dart';
import 'package:kasir/pages/dashboard.dart';
import 'package:kasir/pages/kasir.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
      },
    );
  }
}
