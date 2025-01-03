import 'package:flutter/material.dart';

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            label: 'Scout',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            label: 'Analyze',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Manage',
          ),
        ],
      ),
    );
  }
}
