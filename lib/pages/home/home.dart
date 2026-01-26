import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:marquee/marquee.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/match_card.dart';
import '../../components/stats_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;
  int _currentPage = 0;

  // Constants
  static const String _eventName = 'Finger Lakes Regional';
  static const String _eventDates = 'March 13, 2025 - March 15, 2025';
  static const String _eventLocation = 'Rochester, NY, USA';
  static const String _twitchAppUri = 'twitch://stream/firstinspires';
  static const String _twitchWebUri = 'https://www.twitch.tv/firstinspires';
  static const int _pageDuration = 400;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  /// Define the carousel pages with their respective widgets
  static const List<Widget> _carouselPages = [
    MatchCard(
      matchNumber: 21,
      headerOverride: 'Now Playing',
      blueTeams: [3015, 3173, 340],
      redTeams: [1787, 1511, 1559],
    ),
    MatchCard(
      matchNumber: 22,
      headerOverride: 'Your Next Match',
      blueTeams: [1234, 5678, 9012],
      redTeams: [3456, 7890, 1234],
    ),
    StatsCard(opr: 70.8, ccwm: -30.2, dpr: 87.9),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            spacing: 12,
            children: [
              _buildEventHeader(),
              _buildRankingButton(),
              _buildCarousel(),
              _buildEventInfoButton(),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    Text(
                      'Assigned Matches',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    _buildAssignedMatchesList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssignedMatchesList() {
    // Sample list of assigned matches - replace with actual data
    final assignedMatches = [
      {
        'matchNumber': 21,
        'blueTeams': [3015, 3173, 340],
        'redTeams': [1787, 1511, 1559],
      },
      {
        'matchNumber': 22,
        'blueTeams': [1234, 5678, 9012],
        'redTeams': [3456, 7890, 1234],
      },
      {
        'matchNumber': 23,
        'blueTeams': [2468, 1358, 9753],
        'redTeams': [7531, 2864, 1975],
      },
      {
        'matchNumber': 24,
        'blueTeams': [4567, 8901, 2345],
        'redTeams': [6789, 0123, 4567],
      },
    ];

    return Column(
      spacing: 12,
      children: List.generate(assignedMatches.length, (index) {
        final match = assignedMatches[index];
        return MatchCard.compact(
          matchNumber: match['matchNumber']! as int,
          blueTeams: List<int>.from(match['blueTeams']! as List),
          redTeams: List<int>.from(match['redTeams']! as List),
          // You can provide the team index you want the card to display here
          // otherwise, it defaults to index 0
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        spacing: 8,
        children: [
          const Text('DevilScout'),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface,
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Text(
              'BETA',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.surface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      centerTitle: false,
      titleSpacing: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: SvgPicture.asset('assets/images/logos/ds-logo.svg'),
      ),
      actions: [IconButton(icon: const Icon(Icons.menu), onPressed: () {})],
    );
  }

  Widget _buildEventHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                _buildEventTitle(),
                Text(
                  _eventDates,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Row(
                  spacing: 4,
                  children: [
                    const Icon(Icons.location_pin, size: 18),
                    Text(
                      _eventLocation,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: ElevatedButton(
              onPressed: _openTwitch,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9146FF),
              ),
              child: SvgPicture.asset(
                'assets/images/logos/glitch_flat_black-ops.svg',
                width: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the event title with automatic marquee if text overflows
  Widget _buildEventTitle() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(
            text: _eventName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        if (!painter.didExceedMaxLines) {
          return Text(
            _eventName,
            style: Theme.of(context).textTheme.titleLarge,
          );
        } else {
          return SizedBox(
            height: painter.size.height,
            child: Marquee(
              text: _eventName,
              style: Theme.of(context).textTheme.titleLarge,
              fadingEdgeStartFraction: 0.02,
              fadingEdgeEndFraction: 0.1,
              pauseAfterRound: const Duration(seconds: 2),
              blankSpace: 50,
              showFadingOnlyWhenScrolling: false,
              velocity: 80,
              accelerationCurve: Curves.linear,
              accelerationDuration: const Duration(seconds: 1),
              decelerationCurve: Curves.easeOut,
              decelerationDuration: const Duration(seconds: 1),
            ),
          );
        }
      },
    );
  }

  /// Build the ranking button
  Widget _buildRankingButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(75),
          foregroundColor: Theme.of(context).colorScheme.primary,
          iconColor: Theme.of(context).colorScheme.primary,
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.5,
          ),
        ),
        onPressed: () {},
        child: const Row(
          spacing: 8,
          children: [
            Icon(Icons.leaderboard),
            Text(
              'Current Ranking: 10/45',
            ), // TODO: Update this so the numbers are variables
            Spacer(),
            Icon(Icons.open_in_new),
          ],
        ),
      ),
    );
  }

  /// Build the match carousel with pagination dots
  Widget _buildCarousel() {
    return Column(
      spacing: 8,
      children: [
        SizedBox(
          height: 145,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _carouselPages.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _carouselPages[index],
              );
            },
          ),
        ),
        _buildPaginationDots(),
      ],
    );
  }

  Widget _buildPaginationDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 6,
      children: List.generate(
        _carouselPages.length,
        (index) => GestureDetector(
          onTap: () {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: _pageDuration),
              curve: Curves.easeInOut,
            );
          },
          child: AnimatedContainer(
            width: _currentPage == index ? 18 : 6,
            height: 6,
            duration: const Duration(milliseconds: _pageDuration),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: _currentPage == index
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventInfoButton() {
    return TextButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.open_in_new),
      label: const Text('Event Info'),
    );
  }

  Future<void> _openTwitch() async {
    final twitchAppUri = Uri.parse(_twitchAppUri);
    final twitchWebUri = Uri.parse(_twitchWebUri);

    try {
      if (await canLaunchUrl(twitchAppUri)) {
        await launchUrl(twitchAppUri);
      } else {
        await launchUrl(twitchWebUri, mode: LaunchMode.externalApplication);
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to open Twitch: $e');
    }
  }
}
