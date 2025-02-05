import 'dart:async';

import 'package:flutter/material.dart';

import '../../components/full_screen_message.dart';
import '../../components/searchable_text_field.dart';
import '../../components/team_avatar.dart';
import '../../components/team_card.dart';
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

    final teamsDb = Database.of(context).teams;
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
        child: TeamCard(team: _teams[index]),
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

  @override
  Widget build(BuildContext context) {
    final location = [
      team.city,
      team.province,
      team.country,
    ].nonNulls.join(', ');

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.7)),
      contentPadding: const EdgeInsets.all(18),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
          minWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TeamInformation(team: team, location: location),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(),
            ),
            _JoinActionCluster(team: team),
          ],
        ),
      ),
    );
  }
}

class _JoinActionCluster extends StatelessWidget {
  final Team team;

  const _JoinActionCluster({required this.team});

  String get _textContent => team.isRegistered
      ? 'By requesting to join this team, your name will be visible to all other team members.'
      : 'This team has not yet been registered. By registering this team, you will become its admin.';
  String get _actionLabel =>
      team.isRegistered ? 'Request to Join' : 'Register Team';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _textContent,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _onAction(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: Text(_actionLabel),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: router.pop,
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _onAction(BuildContext context) async {
    if (team.isRegistered) {
      await context.database.teamRequests.requestToJoin(teamNum: team.number);
    } else {
      await context.database.teams
          .createTeam(teamNum: team.number, name: team.name);
    }
    // TODO: display ui notice
    router
      ..pop()
      ..pop();
    unawaited(router.pushReplacement('/scout'));
  }
}

class _TeamInformation extends StatelessWidget {
  const _TeamInformation({
    required this.team,
    required this.location,
  });

  final Team team;
  final String location;

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
              Text(
                'Team ${team.number} | $location',
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
