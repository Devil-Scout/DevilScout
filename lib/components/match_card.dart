import 'package:flutter/material.dart';

class MatchCard extends StatelessWidget {
  static const Color _redTeamColor = Color(0xFFFF7777);
  static const Color _blueTeamColor = Color(0xFF557FFF);
  static const double _cellPadding = 8;
  static const double _cellSpacing = 3;
  static const double _borderRadius = 10.7;

  final String matchNumber;
  final List<int> blueTeams;
  final List<int> redTeams;
  final double? height;

  const MatchCard({
    super.key,
    required this.matchNumber,
    required this.blueTeams,
    required this.redTeams,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const Spacer(),
            _buildTeamsTable(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Text('Now Playing', style: Theme.of(context).textTheme.titleLarge),
        const Icon(Icons.gamepad),
        const Spacer(),
        _buildMatchNumberBadge(context),
      ],
    );
  }

  Widget _buildMatchNumberBadge(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
        child: Text(
          matchNumber,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Theme.of(context).colorScheme.surface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTeamsTable(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_borderRadius),
      child: Table(
        columnWidths: {
          for (int i = 0; i < redTeams.length; i++) i: const FlexColumnWidth(1),
        },
        children: [
          TableRow(
            children: [
              ...redTeams.asMap().entries.map(
                (entry) => _buildTeamCell(
                  context,
                  entry.value,
                  _redTeamColor,
                  isLast: entry.key == redTeams.length - 1,
                ),
              ),
            ],
          ),
          TableRow(
            children: [
              ...blueTeams.asMap().entries.map(
                (entry) => _buildTeamCell(
                  context,
                  entry.value,
                  _blueTeamColor,
                  isLast: entry.key == blueTeams.length - 1,
                  topSpacing: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCell(
    BuildContext context,
    int teamNumber,
    Color backgroundColor, {
    required bool isLast,
    bool topSpacing = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        right: isLast ? 0 : _cellSpacing,
        top: topSpacing ? _cellSpacing : 0,
      ),
      child: ColoredBox(
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(_cellPadding),
          child: Text(
            teamNumber.toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.surface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
