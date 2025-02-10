import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../components/team_card.dart';
import '../../supabase/database.dart';

class ManageHomePage extends StatelessWidget {
  const ManageHomePage({super.key});

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
                  Icons.account_circle_outlined,
                  size: 80,
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
                    FutureBuilder(
                      future: context.database.currentUser.getProfile(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Text('Loading...');
                        }

                        final profile = snapshot.requireData!;
                        final joinDate = profile.createdAt;
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
            _TeamInfo(),
          ],
        ),
      ),
    );
  }
}

class _TeamInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(),
        ),
        if (context.database.currentUser.isOnTeam)
          FutureBuilder(
            future: context.database.teams
                .getTeam(teamNum: context.database.currentUser.teamNum!),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: LoadingAnimationWidget.halfTriangleDot(
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
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainer,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  minimumSize: const Size.fromHeight(50),
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
