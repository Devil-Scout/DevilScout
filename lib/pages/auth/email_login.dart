import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import '../../components/labeled_text_field.dart';
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
        minimum: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerText(context),
            const SizedBox(height: 40.0),
            LabeledTextField(
              label: "Email",
              inputType: TextInputType.emailAddress,
              controller: _emailController,
            ),
            const SizedBox(height: 14.0),
            LabeledTextField(
              label: "Password",
              inputType: TextInputType.text,
              obscureText: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 14.0),
            _forgotPasswordButton(context),
            const SizedBox(height: 40.0),
            _bottomButtons(context),
            const SizedBox(height: 32.0),
            _createAccountText(context),
          ],
        ),
      ),
    );
  }

  Widget _headerText(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 256.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Ready to scout?",
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 6.0),
          Text(
            "Enter your information to access your account",
            style: Theme.of(context).textTheme.bodyLarge,
          )
        ],
      ),
    );
  }

  Widget _forgotPasswordButton(BuildContext context) {
    return TextButton(
      onPressed: () {},
      child: const Text("Forgot password?"),
    );
  }

  Widget _bottomButtons(BuildContext context) {
    return Row(
      children: [
        OutlinedButton(
          onPressed: router.pop,
          child: const Icon(
            Icons.arrow_back,
          ),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: ListenableBuilder(
            listenable: Listenable.merge([
              _emailController,
              _passwordController,
            ]),
            builder: (context, _) {
              return ElevatedButton(
                // TODO: style button when inactive using MaterialState.disabled
                onPressed:
                    _isFormValid() ? () => _loginWithEmail(context) : null,
                child: const Text('Sign In'),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _createAccountText(BuildContext context) {
    return Row(
      children: [
        Text(
          "Don't have an account?",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(width: 6.0),
        TextButton(
          onPressed: () => router.go('/login/email/signup'),
          child: const Text("Create one"),
        )
      ],
    );
  }

  bool _isFormValid() =>
      EmailValidator.validate(_emailController.text) &&
      _passwordController.text.isNotEmpty;

  void _loginWithEmail(BuildContext context) async {
    try {
      await Database.of(context).auth.signInWithEmail(
            email: _emailController.text,
            password: _passwordController.text,
          );
    } catch (e) {
      // TODO: notify user of error
    }
  }
}
