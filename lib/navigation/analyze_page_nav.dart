import 'package:devil_scout/pages/analyze/analyze_home.dart';
import 'package:flutter/material.dart';

class AnalyzePageNavigator extends StatefulWidget {
  const AnalyzePageNavigator({super.key});

  @override
  State<AnalyzePageNavigator> createState() => _AnalyzePageNavigatorState();
}

class _AnalyzePageNavigatorState extends State<AnalyzePageNavigator> {
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

          return AnalyzeHomePage();
        });
      },
    );
  }
}
