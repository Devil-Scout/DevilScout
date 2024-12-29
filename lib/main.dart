import 'package:flutter/material.dart';

import 'pages/auth/login_select.dart';
import 'supabase.dart';
import 'theme.dart';

Future<void> main() async {
  await supabaseInit();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: check supabase.currentSession on startup

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginSelectPage(),
      theme: lightTheme,
    );
  }
}
