import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'router.dart';
import 'supabase/database.dart';
import 'theme.dart';

Future<void> main() async {
  await Database.initSupabase();
  runApp(
    Provider(
      create: (context) => Database.supabase(Supabase.instance.client),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final StreamSubscription<AuthState> _authSub;

  @override
  void initState() {
    super.initState();

    context.database.currentUser.refresh();
    _authSub = context.database.auth.subscribe((data) {
      switch (data.event) {
        case AuthChangeEvent.signedIn:
          router.go('/home');
        case AuthChangeEvent.signedOut:
          router.go('/login');
        case AuthChangeEvent.initialSession:
          router.go(data.session == null ? '/login' : '/home');
        // case AuthChangeEvent.passwordRecovery:
        // case AuthChangeEvent.tokenRefreshed:
        // case AuthChangeEvent.userUpdated:
        // case AuthChangeEvent.mfaChallengeVerified:
        default: // ignore the rest
      }
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
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
