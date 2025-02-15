import 'package:flutter/material.dart';

import '../../components/full_screen_message.dart';
import '../../router.dart';
import '../../supabase/database.dart';

class ScoutHomePage extends StatelessWidget {
  const ScoutHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!context.database.currentUser.isOnTeam) {
      return const _JoinTeamMessage();
    }

    return const Center(
      child: Text('Scout Page'),
    );
  }
}

class _JoinTeamMessage extends StatelessWidget {
  const _JoinTeamMessage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const FullScreenMessage(
                icon: Icons.info_outline,
                message: 'You must join a team before you can start scouting.',
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => router.go('/settings/join-team'),
                      child: const Text('Join a Team'),
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
