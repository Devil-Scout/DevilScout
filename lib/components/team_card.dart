import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../supabase/core/teams.dart';
import '../supabase/database.dart';
import 'team_avatar.dart';

class TeamCard extends StatelessWidget {
  final Team team;
  final bool showTrailingIcon;

  const TeamCard({
    super.key,
    required this.team,
    this.showTrailingIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final location = [
      team.city,
      team.province,
      team.country,
    ].nonNulls.join(', ');
    return Card.filled(
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.7),
      ),
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: TeamAvatarImage(
          year: DateTime.now().year,
          teamNum: team.number,
        ),
        title: Text(team.name),
        titleTextStyle: Theme.of(context).textTheme.titleSmall,
        subtitle: Text(
          location.isEmpty
              ? 'Team ${team.number}'
              : 'Team ${team.number} | $location',
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        subtitleTextStyle: Theme.of(context).textTheme.bodySmall,
        trailing: showTrailingIcon
            ? (team.registration == null
                ? const Icon(Icons.add)
                : Icon(
                    Icons.person_add_alt,
                    color: Theme.of(context).colorScheme.primary,
                  ))
            : null,
      ),
    );
  }
}

class TeamCardFuture extends StatelessWidget {
  final int teamNum;

  const TeamCardFuture({super.key, required this.teamNum});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.database.teams.getTeam(teamNum: teamNum),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(
            child: LoadingAnimationWidget.horizontalRotatingDots(
              color: Theme.of(context).colorScheme.onSurface,
              size: 50,
            ),
          );
        } else if (!snapshot.hasData) {
          // TODO: what here?
        }

        final team = snapshot.requireData!;
        return TeamCard(team: team);
      },
    );
  }
}
