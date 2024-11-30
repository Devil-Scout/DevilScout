import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
            _InfoText(),
            const SizedBox(height: 40.0),
            _EmailField(),
            const SizedBox(height: 14.0),
            _PasswordField(),
            const SizedBox(height: 40.0),
            _EmailSignInFunctions(),
            const SizedBox(height: 32.0),
            _CreateAccountText(),
          ],
        ),
      ),
    );
  }
}

class _InfoText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
}

class _EmailField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Email",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8.0),
        const TextField(
          autocorrect: false,
          keyboardType: TextInputType.emailAddress,
          enableSuggestions: false,
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Password",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8.0),
        const TextField(
          autocorrect: false,
          obscureText: true,
          enableSuggestions: false,
        ),
        const SizedBox(height: 14.0),
        TextButton(
          onPressed: () {},
          child: const Text("Forgot password?"),
        ),
      ],
    );
  }
}

class _EmailSignInFunctions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            child: const Text("Sign in"),
          ),
        )
      ],
    );
  }
}

class _CreateAccountText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "Don't have an account?",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(width: 6.0),
        TextButton(
          onPressed: () {},
          child: const Text("Create one"),
        )
      ],
    );
  }
}
