import 'package:flutter/material.dart';

class ScoutHomePage extends StatelessWidget {
  const ScoutHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Scaffold(
        body: _JoinTeamMessage(),
      ),
    );
  }
}

class _JoinTeamMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              Icon(
                Icons.info_outline,
                size: 64.0,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16.0),
              Text(
                'You must join a team before you can start scouting.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 32.0),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text("Join a Team"),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
