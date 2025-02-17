import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../components/team_card.dart';
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
            if (context.database.currentUser.isOnTeam)
              _TeamInfo()
            else
              _JoinTeamPlaceholder(),
          ],
        ),
      ),
    );
  }
}

class _JoinTeamPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Join a team to unlock the full functionality of DevilScout.',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                child: const Text('Join a Team'),
                onPressed: () => router.go('/settings/join-team'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TeamInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder(
          future: context.database.teams
              .getTeam(teamNum: context.database.currentUser.teamNum!),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: LoadingAnimationWidget.horizontalRotatingDots(
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 50,
                ),
              );
            }

            final team = snapshot.requireData!;
            return TeamCard(team: team);
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const _LeaveTeamDialog(),
                  );
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainer,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                child: Text(
                  'Leave Team',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LeaveTeamDialog extends StatelessWidget {
  const _LeaveTeamDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.7)),
      icon: Icon(
        Icons.error_outline,
        size: 40,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      title: Text(
        'Leave team?',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            textAlign: TextAlign.center,
            'Are you sure you want to leave this team? You will no longer be able to scout matches and will have send a new request if you wish to rejoin.',
          ),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Divider(),
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Leave Team'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
