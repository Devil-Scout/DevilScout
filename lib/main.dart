import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'appwrapper.dart';
import 'pages/auth/login_select.dart';
import 'supabase/database.dart';
import 'theme.dart';

Future<void> main() async {
  await Database.initSupabase();
  runApp(Provider(
    create: (context) => Database.supabase(Supabase.instance.client),
    child: const MainApp(),
  ));
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Database.of(context).auth.addListener((data) {
        switch (data.event) {
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
              data.session == null
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
