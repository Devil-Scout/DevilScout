import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class NavBarWrapper extends StatelessWidget {
  final StatefulNavigationShell shell;

  const NavBarWrapper({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    return PersistentTabView.router(
      navigationShell: shell,
      navBarBuilder: (config) => Style1BottomNavBar(
        navBarConfig: config,
        navBarDecoration: NavBarDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, -3),
            ),
          ],
        ),
      ),
      tabs: [
        _item(
          context: context,
          title: 'Home',
          icon: const Icon(Icons.home),
          inactiveIcon: const Icon(Icons.home_outlined),
        ),
        _item(
          context: context,
          title: 'Scout',
          icon: const Icon(Icons.edit),
          inactiveIcon: const Icon(Icons.edit_outlined),
        ),
        _item(
          context: context,
          title: 'Analyze',
          icon: const Icon(Icons.analytics),
          inactiveIcon: const Icon(Icons.analytics_outlined),
        ),
        _item(
          context: context,
          title: 'Settings',
          icon: const Icon(Icons.settings),
          inactiveIcon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }

  PersistentRouterTabConfig _item({
    required BuildContext context,
    required Icon icon,
    required Icon inactiveIcon,
    required String title,
  }) =>
      PersistentRouterTabConfig(
        item: ItemConfig(
          icon: icon,
          inactiveIcon: inactiveIcon,
          title: title,
          activeForegroundColor: Theme.of(context).primaryColor,
          textStyle: Theme.of(context).textTheme.labelSmall!,
        ),
      );
}
