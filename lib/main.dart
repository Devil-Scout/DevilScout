import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'router.dart';
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
  @override
  void initState() {
    super.initState();

    Database.of(context).auth.addListener((data) {
      switch (data.event) {
        case AuthChangeEvent.signedIn:
          router.go('/home');
          break;
        case AuthChangeEvent.signedOut:
          router.go('/login');
          break;
        case AuthChangeEvent.initialSession:
          router.go(data.session == null ? '/login' : '/home');
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
    return MaterialApp.router(
      routerConfig: router,
      theme: lightTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
