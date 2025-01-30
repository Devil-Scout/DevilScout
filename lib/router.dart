import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'nav_bar.dart';
import 'pages/analyze/analyze_home.dart';
import 'pages/auth/email_login.dart';
import 'pages/auth/email_signup.dart';
import 'pages/auth/login_select.dart';
import 'pages/home/home.dart';
import 'pages/manage/manage_home.dart';
import 'pages/scout/scout_home.dart';

final _rootNavigator = GlobalKey<NavigatorState>();
final _homeNavigator = GlobalKey<NavigatorState>();
final _scoutNavigator = GlobalKey<NavigatorState>();
final _analyzeNavigator = GlobalKey<NavigatorState>();
final _settingsNavigator = GlobalKey<NavigatorState>();

final router = _router();

GoRouter _router() {
  return GoRouter(
    navigatorKey: _rootNavigator,
    routes: [
      _loginRoutes(),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            NavBarWrapper(shell: navigationShell),
        branches: [
          _homeBranch(),
          _scoutBranch(),
          _analyzeBranch(),
          _settingsBranch(),
        ],
      )
    ],
  );
}

GoRoute _loginRoutes() {
  return GoRoute(
    path: '/login',
    builder: (context, state) => const LoginSelectPage(),
    routes: [
      GoRoute(
        path: 'email',
        builder: (context, state) => EmailLoginPage(),
        routes: [
          GoRoute(
            path: 'signup',
            builder: (context, state) => EmailSignUpPage(),
          )
        ],
      )
    ],
  );
}

StatefulShellBranch _homeBranch() {
  return StatefulShellBranch(
    navigatorKey: _homeNavigator,
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      )
    ],
  );
}

StatefulShellBranch _scoutBranch() {
  return StatefulShellBranch(
    navigatorKey: _scoutNavigator,
    routes: [
      GoRoute(
        path: '/scout',
        builder: (context, state) => const ScoutHomePage(),
      )
    ],
  );
}

StatefulShellBranch _analyzeBranch() {
  return StatefulShellBranch(
    navigatorKey: _analyzeNavigator,
    routes: [
      GoRoute(
        path: '/analyze',
        builder: (context, state) => const AnalyzeHomePage(),
      )
    ],
  );
}

StatefulShellBranch _settingsBranch() {
  return StatefulShellBranch(
    navigatorKey: _settingsNavigator,
    routes: [
      GoRoute(
        path: '/settings',
        builder: (context, state) => const ManageHomePage(),
      )
    ],
  );
}
