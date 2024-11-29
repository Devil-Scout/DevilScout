import 'package:flutter/material.dart';

import 'package:devil_scout/pages/login.dart';
import 'package:devil_scout/theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
      theme: lightTheme,
    );
  }
}
