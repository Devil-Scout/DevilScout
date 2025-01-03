import 'package:devil_scout/pages/scout/scout_home.dart';
import 'package:flutter/material.dart';

class ScoutPageNavigator extends StatefulWidget {
  const ScoutPageNavigator({super.key});

  @override
  State<ScoutPageNavigator> createState() => _ScoutPageNavigatorState();
}

class _ScoutPageNavigatorState extends State<ScoutPageNavigator> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(builder: (BuildContext context) {
          // if (settings.name == '') {
          //   // Return next page
          // }

          return ScoutHomePage();
        });
      },
    );
  }
}
