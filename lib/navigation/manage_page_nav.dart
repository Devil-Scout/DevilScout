import 'package:devil_scout/pages/manage/manage_home.dart';
import 'package:flutter/material.dart';

class ManagePageNavigator extends StatefulWidget {
  const ManagePageNavigator({super.key});

  @override
  State<ManagePageNavigator> createState() => _ManagePageNavigatorState();
}

class _ManagePageNavigatorState extends State<ManagePageNavigator> {
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

          return ManageHomePage();
        });
      },
    );
  }
}
