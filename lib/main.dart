import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'appwrapper.dart';
import 'pages/auth/login_select.dart';
import 'supabase/client.dart';
import 'theme.dart';

Future<void> main() async {
  await supabaseInit();
  Future.delayed(Duration(seconds: 5), supabase.auth.signOut);
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      switch (event) {
        case AuthChangeEvent.signedIn:
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AppWrapper()),
            (_) => false,
          );
          break;
        case AuthChangeEvent.signedOut:
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginSelectPage()),
            (_) => false,
          );
          break;
        case AuthChangeEvent.initialSession:
          navigatorKey.currentState?.pushAndRemoveUntil(
            session == null
                ? MaterialPageRoute(builder: (_) => const LoginSelectPage())
                : MaterialPageRoute(builder: (_) => const AppWrapper()),
            (_) => false,
          );
          break;
        // case AuthChangeEvent.passwordRecovery:
        // case AuthChangeEvent.tokenRefreshed:
        // case AuthChangeEvent.userUpdated:
        // case AuthChangeEvent.mfaChallengeVerified:
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:
          const Scaffold(), // TODO: start page while determining session status
      theme: lightTheme,
      navigatorKey: navigatorKey,
    );
  }
}
