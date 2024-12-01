import 'package:flutter/material.dart';

import 'pages/auth/login_select.dart';
import 'theme.dart';

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
