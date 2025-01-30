import 'package:flutter/material.dart';

import '../supabase/core/teams.dart';
import 'team_avatar.dart';

class TeamCard extends StatelessWidget {
  final Team team;

  const TeamCard({
    super.key,
    required this.team,
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
        titleTextStyle: Theme.of(context).textTheme.displaySmall!.copyWith(
              fontSize: 16.0,
            ),
        subtitle: Text(
          location.isEmpty
              ? "Team ${team.number}"
              : "Team ${team.number} | $location",
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        subtitleTextStyle: Theme.of(context).textTheme.bodySmall,
        trailing: team.registration == null
            ? Icon(Icons.error_outline,
                color: Theme.of(context).colorScheme.error)
            : null,
      ),
    );
  }
}
