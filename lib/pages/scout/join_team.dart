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
  static const debounce = Duration(milliseconds: 100);

  final _controller = TextEditingController();
  Timer? _timer;
  List<Team> _teams = [];

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      _timer?.cancel();
      _timer = Timer(debounce, _updateSearch);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Join a Team"),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 16.0,
        ),
        child: Column(
          children: [
            SearchableTextField(
              controller: _controller,
              hintText: "Search for a team...",
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Divider(),
            ),
            Expanded(
              child: Builder(builder: (context) {
                if (_teams.isEmpty) {
                  return const _SearchMessage();
                } else {
                  return _TeamList(teams: _teams);
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _updateSearch() async {
    final timer = _timer;
    final query = _controller.text;
    if (query.trim().isEmpty) {
      setState(() {
        _teams = [];
      });
      return;
    }

    final teamsDb = Database.of(context).teams;

    final teamNums = await teamsDb.searchTeams(query: _controller.text);
    final teams = await teamsDb.getTeams(teamNums: teamNums);

    if (identical(_timer, timer)) {
      setState(() {
        _teams = teams.nonNulls.toList();
      });
    }
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
        separatorBuilder: (context, index) => const SizedBox(height: 6.0),
        padding: EdgeInsets.symmetric(vertical: 6.0));
  }
}

class _SearchMessage extends StatelessWidget {
  const _SearchMessage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight),
      child: Center(
        child: FullScreenMessage(
          icon: Icons.search,
          message:
              "Search for a team by name or number using the search bar above.",
        ),
      ),
    );
  }
}
