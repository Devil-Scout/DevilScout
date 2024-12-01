import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../components/labeled_text_field.dart';
import '../../pages/auth/email_signup.dart';

class EmailLoginPage extends StatelessWidget {
  const EmailLoginPage({super.key});

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
            const LabeledTextField(
              label: "Email",
              inputType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14.0),
            const LabeledTextField(
              label: "Password",
              inputType: TextInputType.text,
              obscureText: true,
            ),
            const SizedBox(height: 14.0),
            TextButton(
              onPressed: () {},
              child: const Text("Forgot password?"),
            ),
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

  Widget _bottomButtons(BuildContext context) {
    return Row(
      children: [
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const FaIcon(FontAwesomeIcons.arrowLeft),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            child: const Text("Sign In"),
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EmailSignUpPage()),
            );
          },
          child: const Text("Create one"),
        )
      ],
    );
  }
}
