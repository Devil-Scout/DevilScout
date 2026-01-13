import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:marquee/marquee.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/match_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          spacing: 12,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final painter = TextPainter(
                              text: TextSpan(
                                text: 'Finger Lakes Regional',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              maxLines: 1,
                              textDirection: TextDirection.ltr,
                            )..layout(maxWidth: constraints.maxWidth);

                            if (!painter.didExceedMaxLines) {
                              return Text(
                                'Finger Lakes Regional',
                                style: Theme.of(context).textTheme.titleLarge,
                              );
                            } else {
                              return SizedBox(
                                height: painter.size.height,
                                child: Marquee(
                                  text: 'Finger Lakes Regional',
                                  style: Theme.of(context).textTheme.titleLarge,
                                  fadingEdgeStartFraction: 0.02,
                                  fadingEdgeEndFraction: 0.1,
                                  pauseAfterRound: const Duration(seconds: 2),
                                  blankSpace: 50,
                                  showFadingOnlyWhenScrolling: false,
                                  velocity: 80,
                                  accelerationCurve: Curves.linear,
                                  accelerationDuration: const Duration(
                                    seconds: 1,
                                  ),
                                  decelerationCurve: Curves.easeOut,
                                  decelerationDuration: const Duration(
                                    seconds: 1,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        Text(
                          'March 13, 2025 - March 15, 2025',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Row(
                          spacing: 4,
                          children: [
                            const Icon(Icons.location_pin, size: 18),
                            Text(
                              'Rochester, NY, USA',
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
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withAlpha(75),
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
                    Text('Current Ranking: 10/45'),
                    Spacer(),
                    Icon(Icons.open_in_new),
                  ],
                ),
              ),
            ),
            // Carousel with pagination dots
            Column(
              spacing: 8,
              children: [
                SizedBox(
                  height: 155,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: 5, // Change this to your actual card count
                    itemBuilder: (context, index) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: MatchCard(
                          matchNumber: 'Q21',
                          blueTeams: [3015, 3173, 340],
                          redTeams: [1787, 1511, 1559],
                        ),
                      );
                    },
                  ),
                ),
                // Pagination dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 6,
                  children: List.generate(
                    5, // Match this to your card count
                    (index) => GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: AnimatedContainer(
                        width: _currentPage == index ? 18 : 6,
                        height: 6,
                        duration: const Duration(milliseconds: 300),
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
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.open_in_new),
              label: const Text('Event Info'),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }

  Future<void> _openTwitch() async {
    final twitchAppUri = Uri.parse('twitch://stream/firstinspires');
    final twitchWebUri = Uri.parse('https://www.twitch.tv/firstinspires');

    // Try to open the Twitch app first
    if (await canLaunchUrl(twitchAppUri)) {
      await launchUrl(twitchAppUri);
    } else {
      // If the app is not available, open the web URL
      await launchUrl(twitchWebUri, mode: LaunchMode.externalApplication);
    }
  }
}
