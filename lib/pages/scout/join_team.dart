import 'dart:async';

import 'package:flutter/material.dart';

import '../../components/full_screen_message.dart';
import '../../components/searchable_text_field.dart';
import '../../components/team_card.dart';
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

  Timer? _timer;
  Future<List<Team>> _teams = Future.value([]);

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
    setState(() {
      _teams = _getTeams(_controller.text);
    });
  }

  Future<List<Team>> _getTeams([String query = '']) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final teamsDb = Database.of(context).teams;
    final teamNums = await teamsDb.searchTeams(query: query);
    final teams = await teamsDb.getTeams(teamNums: teamNums);
    return teams;
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
              child: FutureBuilder(
                future: _teams,
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
      itemBuilder: (context, index) => TeamCard(team: _teams[index]),
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
