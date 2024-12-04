import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pages/auth/login_select.dart';
import 'theme.dart';

// these are safe to share publicly
const supabaseUrl = 'https://jlhplhsuiwwcmxrtbdhp.supabase.co';
const supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpsaHBsaHN1aXd3Y214cnRiZGhwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU4MjA3ODQsImV4cCI6MjA0MTM5Njc4NH0.QKbKHdYoSGC71hrOaHYyJNIJWvwE4ehpNOWVJUYng0M';

Future<void> main() async {
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

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
