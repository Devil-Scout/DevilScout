import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DevilScout'),
        centerTitle: false,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: SvgPicture.asset('assets/images/logos/ds-logo.svg'),
        ),
        actions: [IconButton(icon: const Icon(Icons.menu), onPressed: () {})],
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      'Finger Lakes Regional',
                      style: Theme.of(context).textTheme.titleLarge,
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
                const Spacer(),
                ElevatedButton(
                  onPressed: _openTwitch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9146FF),
                  ),
                  child: SvgPicture.asset(
                    'assets/images/logos/glitch_flat_white.svg',
                    width: 24,
                    height: 28,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
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
