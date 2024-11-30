import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WelcomeText(),
            _SignInWithGoogle(),
            const SizedBox(height: 14.0),
            _SignInWithApple(),
            _SignInDivider(),
            // _EmailField(),
            // _PasswordField(),
            _ContinueWithEmail(),
            // _CreateAccountText()
          ],
        ),
      ),
    );
  }
}

class _WelcomeText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 256.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Text(
                "Ready to scout?",
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            Text(
              "Choose your sign in method below to get started",
              style: Theme.of(context).textTheme.bodyLarge,
            )
          ],
        ),
      ),
    );
  }
}

class _SignInWithGoogle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: SvgPicture.asset(
        "assets/images/logos/g-logo.svg",
        width: 24.0,
        height: 24.0,
      ),
      label: const Padding(
        padding: EdgeInsets.only(left: 4.0),
        child: Text("Sign in with Google"),
      ),
    );
  }
}

class _SignInWithApple extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: SvgPicture.asset(
        "assets/images/logos/apple-logo.svg",
        width: 24.0,
        height: 24.0,
      ),
      label: const Padding(
        padding: EdgeInsets.only(left: 4.0),
        child: Text("Sign in with Apple"),
      ),
    );
  }
}

class _SignInDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "or",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const Expanded(child: Divider())
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
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            "Email",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 14.0),
          child: TextField(
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            enableSuggestions: false,
          ),
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
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            "Password",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 14.0),
          child: TextField(
            autocorrect: false,
            obscureText: true,
            enableSuggestions: false,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 40.0),
          child: TextButton(
            onPressed: () {},
            child: const Text("Forgot password?"),
          ),
        ),
      ],
    );
  }
}

class _ContinueWithEmail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: const FaIcon(FontAwesomeIcons.envelope),
      label: const Padding(
        padding: EdgeInsets.only(left: 4.0),
        child: Text("Continue with email"),
      ),
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
