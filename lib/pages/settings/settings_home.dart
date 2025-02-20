import 'dart:async';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase/supabase.dart';

import '../../components/dialogs.dart';
import '../../components/full_width.dart';
import '../../components/teams.dart';
import '../../router.dart';
import '../../supabase/database.dart';

class SettingsHomePage extends StatelessWidget {
  const SettingsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        minimum: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 32,
          bottom: kBottomNavigationBarHeight,
        ),
        child: Column(
          children: [
            SizedBox(height: 16),
            _UserCard(),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(),
            ),
            _TeamSection(),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(),
            ),
            Spacer(),
            _SignOutButton(),
            SizedBox(height: 8),
            _BuildVersion(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _BuildVersion extends StatefulWidget {
  const _BuildVersion();

  @override
  State<_BuildVersion> createState() => _BuildVersionState();
}

class _BuildVersionState extends State<_BuildVersion> {
  PackageInfo _packageInfo = PackageInfo(
    appName: '',
    packageName: '',
    version: '',
    buildNumber: '',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: 'DevilScout Client',
        style: const TextStyle(fontWeight: FontWeight.bold),
        children: [
          TextSpan(
            text: ' | Version ${_packageInfo.version}',
            style: const TextStyle(fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }
}

class _TeamSection extends StatefulWidget {
  const _TeamSection();

  @override
  State<_TeamSection> createState() => _TeamSectionState();
}

class _TeamSectionState extends State<_TeamSection> {
  late final StreamSubscription<AuthState> _authSub;

  @override
  void initState() {
    super.initState();

    _authSub = context.database.auth.subscribe((state) {
      if (state.event != AuthChangeEvent.tokenRefreshed) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (context.database.currentUser.isOnTeam) {
          return _TeamInfo(
            teamNum: context.database.currentUser.teamNum!,
            isMember: true,
          );
        } else if (context.database.currentUser.hasTeamRequest) {
          return _TeamInfo(
            teamNum: context.database.currentUser.requestedTeamNum!,
            isMember: false,
          );
        } else {
          return const _JoinTeamPlaceholder();
        }
      },
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
          iconColor: Theme.of(context).colorScheme.error,
          overlayColor: Theme.of(context).colorScheme.error.withAlpha(45),
        ),
        icon: const Icon(Icons.logout),
        label: const Text('Sign Out'),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => ActionDialog(
              title: 'Sign out?',
              content: const Text('Are you sure you want to sign out?'),
              actionButton: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Sign Out'),
                onPressed: () {
                  context.database.auth.signOut();
                  // automatic redirect to /login
                  // this should almost never fail
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UserCard extends StatefulWidget {
  const _UserCard();

  @override
  State<_UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<_UserCard> {
  late final StreamSubscription<AuthState> _authSub;

  @override
  void initState() {
    super.initState();

    _authSub = context.database.auth.subscribe((state) {
      if (state.event != AuthChangeEvent.tokenRefreshed) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(
              Icons.badge_outlined,
              size: 60,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.database.currentUser.name,
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  context.database.currentUser.email,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              onPressed: () => router.go('/settings/edit-account'),
              icon: const Icon(Icons.edit_outlined),
              color: Theme.of(context).colorScheme.primary,
              splashColor: Theme.of(context).colorScheme.primary.withAlpha(45),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.schedule_outlined, size: 24),
            const SizedBox(width: 6),
            Builder(
              builder: (context) {
                final joinDate = context.database.currentUser.createdAt;
                return Text(
                  'Joined on ${joinDate.month}/${joinDate.day}/${joinDate.year}',
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _JoinTeamPlaceholder extends StatelessWidget {
  const _JoinTeamPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.info_outline,
          size: 40,
        ),
        const SizedBox(height: 12),
        const Text(
          'Join a team to unlock the full functionality of DevilScout.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        FullWidth(
          child: ElevatedButton(
            child: const Text('Join a Team'),
            onPressed: () => router.go('/settings/join-team'),
          ),
        ),
      ],
    );
  }
}

class _TeamInfo extends StatelessWidget {
  final int teamNum;
  final bool isMember;

  const _TeamInfo({required this.teamNum, required this.isMember});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Your Team',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            if (!isMember)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  child: Text(
                    'Request Pending',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TeamCardFuture(teamNum: teamNum),
        const SizedBox(height: 8),
        Center(
          child: TextButton.icon(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => isMember
                  ? _LeaveTeamDialog(teamNum: teamNum)
                  : _CancelRequestDialog(teamNum: teamNum),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              overlayColor: Theme.of(context).colorScheme.error.withAlpha(45),
              iconColor: Theme.of(context).colorScheme.error,
            ),
            icon: isMember
                ? const Icon(Icons.logout)
                : const Icon(Icons.cancel_outlined),
            label: Text(
              isMember ? 'Leave Team' : 'Cancel Request',
            ),
          ),
        ),
      ],
    );
  }
}

class _LeaveTeamDialog extends StatelessWidget {
  final int teamNum;

  const _LeaveTeamDialog({required this.teamNum});

  @override
  Widget build(BuildContext context) {
    return ActionDialog(
      title: 'Leave Team $teamNum?',
      content: const Text(
        textAlign: TextAlign.left,
        'Are you sure you want to leave this team? You will no longer be able to collect scouting data, and you will have send a new request if you wish to rejoin.',
      ),
      actionButton: ElevatedButton(
        onPressed: () async {
          try {
            await context.database.teamUsers
                .removeUser(context.database.currentUser.id);
          } on PostgrestException {
            if (!context.mounted) return;
            await showDialog(
              context: context,
              builder: (context) =>
                  const UnexpectedErrorDialog(title: 'Failed to Leave Team'),
            );
            return;
          }

          if (!context.mounted) return;
          await showDialog(
            context: context,
            builder: (context) => TextDialog(
              title: 'Success',
              message: 'You are no longer a member of Team $teamNum',
            ),
          );

          if (!context.mounted) return;
          router.pop();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
        child: const Text('Leave Team'),
      ),
    );
  }
}

class _CancelRequestDialog extends StatelessWidget {
  final int teamNum;

  const _CancelRequestDialog({required this.teamNum});

  @override
  Widget build(BuildContext context) {
    return ActionDialog(
      title: 'Cancel request?',
      content: Text(
        textAlign: TextAlign.left,
        "Are you sure you want to cancel your request to join Team $teamNum? Team admins won't be able to add you as a member.",
      ),
      actionButton: ElevatedButton(
        onPressed: () async {
          try {
            await context.database.teamRequests
                .deleteRequest(userId: context.database.currentUser.id);
          } on PostgrestException {
            if (!context.mounted) return;
            await showDialog(
              context: context,
              builder: (context) => const UnexpectedErrorDialog(
                title: 'Failed to Cancel Request',
              ),
            );
            return;
          }

          if (!context.mounted) return;
          await context.database.currentUser.refresh();

          if (!context.mounted) return;
          router.pop();

          // TODO: UI: is this dialog needed? updates in background
          await showDialog(
            context: context,
            builder: (context) => const TextDialog(
              title: 'Success',
              message: 'Your join request was cancelled.',
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
        child: const Text('Cancel Request'),
      ),
    );
  }
}
