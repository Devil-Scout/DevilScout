import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import '../../components/full_width.dart';
import '../../components/text_fields.dart';
import '../../router.dart';
import '../../supabase/database.dart';

class EmailLoginPage extends StatelessWidget {
  EmailLoginPage({super.key});

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerText(context),
            const SizedBox(height: 40),
            LabeledTextField(
              label: 'Email',
              inputType: TextInputType.emailAddress,
              controller: _emailController,
            ),
            const SizedBox(height: 14),
            LabeledTextField(
              label: 'Password',
              inputType: TextInputType.text,
              obscureText: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 14),
            _forgotPasswordButton(context),
            const SizedBox(height: 40),
            _bottomButtons(context),
            const SizedBox(height: 32),
            _createAccountText(context),
          ],
        ),
      ),
    );
  }

  Widget _headerText(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 256),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ready to scout?',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Enter your information to access your account',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _forgotPasswordButton(BuildContext context) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        textStyle: Theme.of(context).textTheme.bodyMedium,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        overlayColor: Colors.transparent,
      ),
      child: const Text('Forgot password?'),
    );
  }

  Widget _bottomButtons(BuildContext context) {
    return FullWidth(
      leading: OutlinedButton(
        onPressed: router.pop,
        child: const Icon(
          Icons.arrow_back,
        ),
      ),
      child: ListenableBuilder(
        listenable: Listenable.merge([
          _emailController,
          _passwordController,
        ]),
        builder: (context, _) {
          return ElevatedButton(
            onPressed:
                _isFormValid() ? () async => _loginWithEmail(context) : null,
            child: const Text('Sign In'),
          );
        },
      ),
    );
  }

  Widget _createAccountText(BuildContext context) {
    return Row(
      children: [
        Text(
          "Don't have an account?",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(width: 6),
        TextButton(
          onPressed: () => router.go('/login/email/signup'),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
            textStyle: Theme.of(context).textTheme.bodyMedium,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            overlayColor: Colors.transparent,
          ),
          child: const Text('Create one'),
        ),
      ],
    );
  }

  bool _isFormValid() =>
      EmailValidator.validate(_emailController.text) &&
      _passwordController.text.isNotEmpty;

  Future<void> _loginWithEmail(BuildContext context) async {
    try {
      await context.database.auth.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on Object {
      // TODO: notify user of error
    }
  }
}
