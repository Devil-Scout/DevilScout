import 'package:flutter/material.dart';

import 'package:devil_scout/theme.dart';

import 'pages/auth/login_select.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginSelectPage(),
      theme: lightTheme,
    );
  }
}
