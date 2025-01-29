import 'package:flutter/material.dart';

import '../../components/full_screen_message.dart';
import '../../components/searchable_text_field.dart';
import '../../components/team_card.dart';
import '../../supabase/database.dart';

class JoinTeamPage extends StatelessWidget {
  final _controller = TextEditingController();

  JoinTeamPage({super.key});

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
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, child) {
                if (value.text.isNotEmpty) {
                  return const _TeamList();
                } else {
                  return _SearchMessage();
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

class _TeamList extends StatelessWidget {
  const _TeamList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 16.0),
        // Use a ListView here to display TeamCards based on the search query
      ],
    );
  }
}

class _SearchMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight),
        child: Center(
          child: FullScreenMessage(
            icon: Icons.search,
            message:
                "Search for a team by name or number using the search bar above.",
          ),
        ),
      ),
    );
  }
}
