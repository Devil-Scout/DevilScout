import 'package:flutter/material.dart';

import '../supabase/core/teams.dart';
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
