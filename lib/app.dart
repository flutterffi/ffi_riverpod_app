import 'package:flutter/material.dart';

import 'ui/pages/home_page.dart';

class FfiRiverpodApp extends StatelessWidget {
  const FfiRiverpodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FFI Riverpod BLE',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
