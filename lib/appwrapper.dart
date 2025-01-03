import 'package:devil_scout/navigation/analyze_page_nav.dart';
import 'package:devil_scout/navigation/home_page_nav.dart';
import 'package:devil_scout/pages/manage/manage_home.dart';
import 'package:devil_scout/pages/scout/scout_home.dart';
import 'package:flutter/material.dart';

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _pageIndex,
        children: <Widget>[
          HomePageNavigator(),
          ScoutHomePage(),
          AnalyzePageNavigator(),
          ManageHomePage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              blurRadius: 6.0,
              offset: const Offset(0.0, -3.0),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _pageIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _pageIndex = index;
            });
          },
          destinations: <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment),
              label: 'Scout',
            ),
            NavigationDestination(
              icon: Icon(Icons.analytics_outlined),
              selectedIcon: Icon(Icons.analytics),
              label: 'Analyze',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Manage',
            ),
          ],
        ),
      ),
    );
  }
}
