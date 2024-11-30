import 'package:devil_scout/pages/auth/login_select.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EmailSignUpPage extends StatelessWidget {
  const EmailSignUpPage({super.key});

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
            _SignUpButton(),
            const SizedBox(height: 14.0),
            _CancelSignUnButton(),
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
            "Welcome!",
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 6.0),
          Text(
            "Level up your scouting with the DevilScout platform",
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
        Text(
          "Verify Password",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8.0),
        const TextField(
          autocorrect: false,
          obscureText: true,
          enableSuggestions: false,
        ),
      ],
    );
  }
}

class _SignUpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            child: const Text("Sign Up"),
          ),
        )
      ],
    );
  }
}

class _CancelSignUnButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginSelectPage(),
                ),
              );
            },
            icon: const FaIcon(FontAwesomeIcons.rightFromBracket),
            iconAlignment: IconAlignment.start,
            label: const Padding(
              padding: EdgeInsets.only(left: 4.0),
              child: Text("Return to Sign In"),
            ),
          ),
        )
      ],
    );
  }
}
