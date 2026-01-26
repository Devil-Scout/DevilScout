import 'dart:math' as math;

import 'package:flutter/material.dart';

class MatchCard extends StatelessWidget {
  static const Color _redTeamColor = Color(0xFFFF7777);
  static const Color _blueTeamColor = Color(0xFF557FFF);
  static const double _cellPadding = 8;
  static const double _cellSpacing = 6;
  static const double _borderRadius = 10.7;
  static const double _cardPadding = 16;

  final int matchNumber;
  final String headerOverride;
  final List<int> blueTeams;
  final List<int> redTeams;

  // Compact mode controls
  final bool compact;
  final int
  compactTeamIndex; // which team to pick when compact (0-based across red then blue)

  const MatchCard({
    super.key,
    required this.matchNumber,
    this.headerOverride = '',
    required this.blueTeams,
    required this.redTeams,
    this.compact = false,
    this.compactTeamIndex = 0,
  });

  /// Convenience constructor for the compact variant
  const MatchCard.compact({
    Key? key,
    required int matchNumber,
    String headerOverride = '',
    required List<int> blueTeams,
    required List<int> redTeams,
    int compactTeamIndex = 0,
  }) : this(
         key: key,
         matchNumber: matchNumber,
         headerOverride: headerOverride,
         blueTeams: blueTeams,
         redTeams: redTeams,
         compact: true,
         compactTeamIndex: compactTeamIndex,
       );

  @override
  Widget build(BuildContext context) {
    // use min main axis so card height can shrink in compact variant
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(_cardPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            if (compact)
              _buildCompactTeam(context)
            else
              _buildTeamsTable(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            headerOverride.isEmpty
                ? 'Qualification $matchNumber'
                : headerOverride,
            style: Theme.of(context).textTheme.titleLarge,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        _buildMatchInfoBadge(context),
      ],
    );
  }

  Widget _buildMatchInfoBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: colorScheme.surface,
      fontWeight: FontWeight.bold,
    );

    // spec: default (no header override) -> show time; header override -> show match number
    final label = headerOverride.isNotEmpty ? 'Q$matchNumber' : '12:00 PM';

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: colorScheme.onSurfaceVariant,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
        child: Text(label, style: textStyle),
      ),
    );
  }

  /// Build a compact single-team view. Picks a team from redTeams first, then blueTeams.
  Widget _buildCompactTeam(BuildContext context) {
    final all = [...redTeams, ...blueTeams];
    if (all.isEmpty) {
      return const SizedBox.shrink();
    }

    final idx = compactTeamIndex % all.length;
    final team = all[idx];
    final isRed = idx < redTeams.length;
    final bg = isRed ? _redTeamColor : _blueTeamColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(_borderRadius),
      child: ColoredBox(
        color: bg,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  team.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.surface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamsTable(BuildContext context) {
    final maxColumns = math.max(redTeams.length, blueTeams.length);
    // ensure at least 1 column to avoid invalid table
    final columns = math.max(1, maxColumns);

    return ClipRRect(
      borderRadius: BorderRadius.circular(_borderRadius),
      child: Table(
        columnWidths: {
          for (int i = 0; i < columns; i++) i: const FlexColumnWidth(),
        },
        children: [
          TableRow(
            children: List.generate(columns, (colIndex) {
              final hasTeam = colIndex < redTeams.length;
              return _buildTeamCell(
                context,
                hasTeam ? redTeams[colIndex] : null,
                hasTeam ? _redTeamColor : Colors.transparent,
                isLast: colIndex == columns - 1,
              );
            }),
          ),
          TableRow(
            children: List.generate(columns, (colIndex) {
              final hasTeam = colIndex < blueTeams.length;
              return _buildTeamCell(
                context,
                hasTeam ? blueTeams[colIndex] : null,
                hasTeam ? _blueTeamColor : Colors.transparent,
                isLast: colIndex == columns - 1,
                topSpacing: true,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCell(
    BuildContext context,
    int? teamNumber,
    Color backgroundColor, {
    required bool isLast,
    bool topSpacing = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: colorScheme.surface,
      fontWeight: FontWeight.bold,
    );

    // If teamNumber is null we render a transparent placeholder so the table keeps alignment.
    if (teamNumber == null) {
      return Padding(
        padding: EdgeInsets.only(
          right: isLast ? 0 : _cellSpacing,
          top: topSpacing ? _cellSpacing : 0,
        ),
        child: const SizedBox.shrink(),
      );
    }

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
            style: textStyle,
          ),
        ),
      ),
    );
  }
}
