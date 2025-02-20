import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import '../../components/dialogs.dart';
import '../../components/full_width.dart';
import '../../components/text_fields.dart';
import '../../router.dart';
import '../../supabase/database.dart';

class EditAccountPage extends StatefulWidget {
  const EditAccountPage({super.key});

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = context.database.currentUser.name;
    _emailController.text = context.database.currentUser.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Account'),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LabeledTextField(
                        label: 'Full Name',
                        inputType: TextInputType.text,
                        controller: _nameController,
                      ),
                      const SizedBox(height: 16),
                      LabeledTextField(
                        label: 'Email',
                        inputType: TextInputType.text,
                        controller: _emailController,
                      ),
                      const SizedBox(height: 16),
                      LabeledTextField(
                        label: 'New Password',
                        inputType: TextInputType.text,
                        obscureText: true,
                        controller: _passwordController,
                      ),
                      const SizedBox(height: 16),
                      LabeledTextField(
                        label: 'Confirm Password',
                        inputType: TextInputType.text,
                        obscureText: true,
                        controller: _confirmPasswordController,
                      ),
                      const SizedBox(height: 16),
                      const _DeleteAccountButton(),
                      const SizedBox(height: 8),
                      const Spacer(),
                      FullWidth(
                        child: ListenableBuilder(
                          listenable: Listenable.merge([
                            _nameController,
                            _emailController,
                            _passwordController,
                            _confirmPasswordController,
                          ]),
                          builder: (context, _) => ElevatedButton(
                            onPressed: isValid() ? _saveChanges : null,
                            child: const Text('Save Changes'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  bool isValid() {
    return _nameController.text.trim().isNotEmpty &&
        EmailValidator.validate(_emailController.text) &&
        _passwordController.text == _confirmPasswordController.text;
  }

  Future<void> _saveChanges() async {
    final currentName = context.database.currentUser.name;
    final newName = _nameController.text;
    final currentEmail = context.database.currentUser.email;
    final newEmail = _emailController.text;
    final newPassword = _passwordController.text;

    if (newName != currentName) {
      await context.database.currentUser.setName(newName);
    }

    if (mounted && newEmail != currentEmail) {
      await context.database.currentUser.setEmail(newEmail);
    }

    if (mounted && newPassword.isNotEmpty) {
      await context.database.currentUser.setPassword(newPassword);
    }

    if (!mounted) return;
    await context.database.currentUser.refresh();
    router.go('/settings');
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
