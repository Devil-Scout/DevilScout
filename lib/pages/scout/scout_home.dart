import 'package:flutter/material.dart';

import '../../components/full_screen_message.dart';
import '../../router.dart';

class ScoutHomePage extends StatelessWidget {
  const ScoutHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              FullScreenMessage(
                icon: Icons.info_outline,
                message: 'You must join a team before you can start scouting.',
              ),
              const SizedBox(height: 24.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => router.go('/scout/join-team'),
                      child: Text('Join a Team'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
