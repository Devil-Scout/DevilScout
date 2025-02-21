import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';

import '../../components/dialogs.dart';
import '../../components/full_screen_message.dart';
import '../../components/teams.dart';
import '../../components/text_fields.dart';
import '../../router.dart';
import '../../supabase/core/teams.dart';
import '../../supabase/database.dart';

class JoinTeamPage extends StatefulWidget {
  const JoinTeamPage({super.key});

  @override
  State<JoinTeamPage> createState() => _JoinTeamPageState();
}

class _JoinTeamPageState extends State<JoinTeamPage> {
  static const debounce = Duration(milliseconds: 50);

  final _controller = TextEditingController();

  final _teams = ValueNotifier(Future.value(<Team>[]));
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      _timer?.cancel();

      // Don't delay for empty queries
      final query = _controller.text;
      if (query.trim().isEmpty) {
        _updateSearch();
      } else {
        _timer = Timer(debounce, _updateSearch);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateSearch() {
    _teams.value = _getTeams();
  }

  Future<List<Team>> _getTeams() async {
    final query = _controller.text;
    if (query.trim().isEmpty) return [];

    final teamsDb = context.database.teams;
    final teamNums = await teamsDb.searchTeams(query: query);
    return teamsDb.getTeams(teamNums: teamNums);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join a Team'),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        child: Column(
          children: [
            SearchableTextField(
              controller: _controller,
              hintText: 'Search for a team...',
            ),
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Divider(),
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _teams,
                builder: (_, future, __) => FutureBuilder(
                  future: future,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    final teams = snapshot.requireData;
                    if (teams.isEmpty) {
                      return const _SearchMessage();
                    } else {
                      return _TeamList(teams: snapshot.requireData);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamList extends StatelessWidget {
  const _TeamList({
    required List<Team> teams,
  }) : _teams = teams;

  final List<Team> _teams;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: _teams.length,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () => showDialog(
          context: context,
          builder: (context) => JoinTeamDialog(team: _teams[index]),
        ),
        child: TeamCard(
          team: _teams[index],
          showTrailingIcon: true,
        ),
      ),
      separatorBuilder: (context, index) => const SizedBox(height: 6),
      padding: const EdgeInsets.symmetric(vertical: 6),
    );
  }
}

class _SearchMessage extends StatelessWidget {
  const _SearchMessage();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight),
      child: Center(
        child: FullScreenMessage(
          icon: Icons.search,
          message:
              'Search for a team by name or number using the search bar above.',
        ),
      ),
    );
  }
}

class JoinTeamDialog extends StatelessWidget {
  final Team team;

  const JoinTeamDialog({
    super.key,
    required this.team,
  });

  String get _textContent => team.isRegistered
      ? 'By requesting to join this team, your name will be visible to all other team members.'
      : 'This team has not yet been registered. By registering this team, you will become its admin.';
  String get _actionLabel =>
      team.isRegistered ? 'Request to Join' : 'Register Team';
  String get _title => team.isRegistered
      ? 'Join Team ${team.number}?'
      : 'Register Team ${team.number}?';

  @override
  Widget build(BuildContext context) {
    return ActionDialog(
      title: _title,
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
          minWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Column(
          children: [
            _TeamInformation(team: team),
            const SizedBox(height: 8),
            Text(_textContent),
          ],
        ),
      ),
      actionButton: ElevatedButton(
        onPressed: () => _onAction(context),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
        ),
        child: Text(_actionLabel),
      ),
    );
  }

  Future<void> _onAction(BuildContext context) async {
    try {
      final db = context.database;
      if (team.isRegistered) {
        await db.teamRequests.requestToJoin(teamNum: team.number);
      } else {
        await db.teams.createTeam(teamNum: team.number, name: team.name);
      }
      await db.currentUser.refresh();
    } on PostgrestException {
      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (context) => UnexpectedErrorDialog(
          title: team.isRegistered ? 'Request Failed' : 'Registration Failed',
        ),
      );
      return;
    }

    if (!context.mounted) return;
    await context.database.currentUser.refresh();

    if (!context.mounted) return;
    router
      ..pop()
      ..go('/settings');
  }
}

class _TeamInformation extends StatelessWidget {
  const _TeamInformation({
    required this.team,
  });

  final Team team;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TeamAvatarImage(
          year: DateTime.now().year,
          teamNum: team.number,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                team.name,
                style: Theme.of(context).textTheme.displaySmall!.copyWith(
                      fontSize: 18,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
              Builder(
                builder: (context) {
                  final location = [
                    team.city,
                    team.province,
                    team.country,
                  ].nonNulls.join(', ');

                  return Text(
                    'Team ${team.number} | $location',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
