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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: supabase.auth.currentSession == null
            ? const LoginSelectPage()
            : Center(child: Text('${supabase.auth.currentUser?.name}')),
      ),
      theme: lightTheme,
    );
  }
}
