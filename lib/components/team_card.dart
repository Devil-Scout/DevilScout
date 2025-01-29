import 'package:flutter/material.dart';

import '../supabase/core/teams.dart';

class TeamCard extends StatelessWidget {
  final Team team;
  final bool showCreatedChip;

  const TeamCard({
    super.key,
    required this.team,
    this.showCreatedChip = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.7),
      ),
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Image.network(
          "https://www.thebluealliance.com/avatar/${DateTime.now().year}/frc1559.png",
        ),
        title: Text(team.name),
        titleTextStyle: Theme.of(context).textTheme.displaySmall!.copyWith(
              fontSize: 16.0,
            ),
        subtitle: Text("Team ${team.number} | ${team.city}, ${team.province}"),
        subtitleTextStyle: Theme.of(context).textTheme.bodySmall,
        trailing: team.registration == null
            ? Icon(Icons.error_outline,
                color: Theme.of(context).colorScheme.error)
            : null,
      ),
    );
  }
}
