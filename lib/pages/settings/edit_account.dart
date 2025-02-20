import 'package:flutter/material.dart';

import '../../components/dialogs.dart';
import '../../components/full_width.dart';
import '../../components/text_fields.dart';
import '../../router.dart';
import '../../supabase/database.dart';

class EditAccountPage extends StatelessWidget {
  const EditAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController =
        TextEditingController(text: context.database.currentUser.name);
    final emailController =
        TextEditingController(text: context.database.currentUser.email);
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Account'),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LabeledTextField(
              label: 'Full Name',
              inputType: TextInputType.text,
              controller: nameController,
            ),
            const SizedBox(height: 16),
            LabeledTextField(
              label: 'Email',
              inputType: TextInputType.text,
              controller: emailController,
            ),
            const SizedBox(height: 16),
            LabeledTextField(
              label: 'Password',
              inputType: TextInputType.text,
              obscureText: true,
              controller: passwordController,
            ),
            const SizedBox(height: 16),
            const _DeleteAccountButton(),
            const Spacer(),
            FullWidth(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Save Changes'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
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
