import 'package:flutter/material.dart';

import 'appwrapper.dart';
import 'pages/auth/login_select.dart';
import 'supabase/client.dart';
import 'theme.dart';

Future<void> main() async {
  await supabaseInit();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: supabase.auth.currentSession == null
            ? const LoginSelectPage()
            : const AppWrapper(),
      ),
      theme: lightTheme,
    );
  }
}
