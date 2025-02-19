import 'dart:async';

import 'package:flutter/material.dart';
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
        minimum: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: SingleChildScrollView(
          child: Column(
            children: [
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
              _UserSection(),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(),
              ),
              _SignOutButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserSection extends StatefulWidget {
  const _UserSection();

  @override
  State<_UserSection> createState() => _UserSectionState();
}

class _UserSectionState extends State<_UserSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Account Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                overlayColor:
                    Theme.of(context).colorScheme.primary.withAlpha(45),
                iconColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _AccountInfoSection(
          label: 'Full Name',
          content: context.database.currentUser.name,
        ),
        const SizedBox(height: 16),
        _AccountInfoSection(
          label: 'Email Address',
          content: context.database.currentUser.email,
        ),
        const SizedBox(height: 16),
        const _AccountInfoSection(
          label: 'Password',
          content: '********',
        ),
        const SizedBox(height: 12),
        const _DeleteAccountButton(),
      ],
    );
  }
}

class _AccountInfoSection extends StatelessWidget {
  final String label;
  final String content;

  const _AccountInfoSection({
    required this.label,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
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
              title: 'Sign Out',
              content: const Text('Are you sure you want to sign out?'),
              actionButton: ElevatedButton(
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

class _DeleteAccountButton extends StatelessWidget {
  const _DeleteAccountButton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
          iconColor: Theme.of(context).colorScheme.error,
          overlayColor: Theme.of(context).colorScheme.error.withAlpha(45),
        ),
        icon: const Icon(Icons.delete_forever_outlined),
        label: const Text('Delete Account'),
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) => ActionDialog(
              title: 'Delete account?',
              content: const Text(
                'Are you sure you want to delete your account? You will be logged out immediately. All of your personal information and preferences will be deleted, but any previously submitted scouting data will be anonymized and retained.',
              ),
              actionButton: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete Account'),
                onPressed: () async {
                  router.pop();
                  await showDialog(
                    context: context,
                    builder: (context) => ActionDialog(
                      title: 'Delete account?',
                      content: const Text(
                        'Are you absolutely sure? This action cannot be reversed.',
                      ),
                      actionButton: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                        child: const Text('Delete Account'),
                        onPressed: () async {
                          await context.database.auth.deleteAccount();
                          // TODO: error handling
                          // automatic redirect to /login
                        },
                      ),
                    ),
                  );
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
    return Row(
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
              'Current Team',
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
                  const UnexpectedErrorDialog(title: 'Failed to leave team'),
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
                title: 'Failed to cancel request',
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
