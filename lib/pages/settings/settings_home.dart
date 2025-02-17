import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';

import '../../components/dialogs.dart';
import '../../components/full_width.dart';
import '../../components/teams.dart';
import '../../router.dart';
import '../../supabase/database.dart';

class SettingsHomePage extends StatelessWidget {
  const SettingsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        minimum: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _UserCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard();

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.7),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.badge_outlined,
                  size: 60,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.database.currentUser.name ?? 'Name Not Found',
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Builder(
                      builder: (context) {
                        final joinDate =
                            context.database.currentUser.createdAt!;
                        return Text(
                          'Joined on ${joinDate.month}/${joinDate.day}/${joinDate.year}',
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(),
            ),
            Builder(
              builder: (context) {
                if (context.database.currentUser.isOnTeam) {
                  return _TeamInfo(
                    teamNum: context.database.currentUser.teamNum!,
                    isMember: true,
                  );
                } else if (context.database.currentUser.hasTeamRequest) {
                  return _TeamInfo(
                    teamNum: context.database.currentUser.requestedTeamNum!,
                    isMember: false,
                  );
                } else {
                  return const _JoinTeamPlaceholder();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _JoinTeamPlaceholder extends StatelessWidget {
  const _JoinTeamPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Join a team to unlock the full functionality of DevilScout.',
        ),
        const SizedBox(height: 12),
        FullWidth(
          child: ElevatedButton(
            child: const Text('Join a Team'),
            onPressed: () => router.go('/settings/join-team'),
          ),
        ),
      ],
    );
  }
}

class _TeamInfo extends StatelessWidget {
  final int teamNum;
  final bool isMember;

  const _TeamInfo({required this.teamNum, required this.isMember});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TeamCardFuture(teamNum: teamNum),
        const SizedBox(height: 8),
        FullWidth(
          child: OutlinedButton(
            onPressed: () {
              if (isMember) {
                showDialog(
                  context: context,
                  builder: (context) => const _LeaveTeamDialog(),
                );
              } else {
                // TODO: dialog for cancelling request
              }
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              side: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            child: Text(
              isMember ? 'Leave Team' : 'Cancel Request',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LeaveTeamDialog extends StatelessWidget {
  const _LeaveTeamDialog();

  @override
  Widget build(BuildContext context) {
    return ActionDialog(
      title: 'Leave Team?',
      content: const Text(
        textAlign: TextAlign.center,
        'Are you sure you want to leave this team? You will no longer be able to scout matches and will have send a new request if you wish to rejoin.',
      ),
      actionButton: ElevatedButton(
        onPressed: () async {
          try {
            await context.database.teamUsers
                .removeUser(context.database.currentUser.id!);
          } on PostgrestException {
            // TODO: handle
            return;
          }

          // TODO: ui success
          router.pop();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
        child: const Text('Leave Team'),
      ),
    );
  }
}
