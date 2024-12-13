import 'package:devil_scout/pages/auth/email_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginSelectPage extends StatelessWidget {
  const LoginSelectPage({super.key});

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
            const SizedBox(height: 40.0),
            _SignInWithGoogle(),
            const SizedBox(height: 14.0),
            _SignInWithApple(),
            _SignInDivider(),
            _ContinueWithEmail(),
            const SizedBox(height: 16.0),
            _SignInInfo()
          ],
        ),
      ),
    );
  }
}

class _WelcomeText extends StatelessWidget {
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
            "Choose your sign in method below to get started",
            style: Theme.of(context).textTheme.bodyLarge,
          )
        ],
      ),
    );
  }
}

class _SignInWithGoogle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: SvgPicture.asset(
              "assets/images/logos/g-logo.svg",
              width: 24.0,
              height: 24.0,
            ),
            label: const Padding(
              padding: EdgeInsets.only(left: 6.0),
              child: Text("Sign in with Google"),
            ),
          ),
        ),
      ],
    );
  }
}

class _SignInWithApple extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: SvgPicture.asset(
              "assets/images/logos/apple-logo.svg",
              width: 24.0,
              height: 24.0,
            ),
            label: const Padding(
              padding: EdgeInsets.only(left: 6.0),
              child: Text("Sign in with Apple"),
            ),
          ),
        ),
      ],
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

class _ContinueWithEmail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EmailLoginPage()),
              );
            },
            icon: const FaIcon(FontAwesomeIcons.envelope),
            label: const Padding(
              padding: EdgeInsets.only(left: 6.0),
              child: Text("Continue with Email"),
            ),
          ),
        ),
      ],
    );
  }
}

class _SignInInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () {},
        icon: const FaIcon(FontAwesomeIcons.circleQuestion),
        label: const Text("Why do I need to sign in?"),
        style: Theme.of(context).textButtonTheme.style!.copyWith(
              foregroundColor: WidgetStatePropertyAll(Colors.grey[600]),
              overlayColor: WidgetStatePropertyAll(Colors.grey[200]),
              iconColor: WidgetStatePropertyAll(Colors.grey[600]),
              textStyle: const WidgetStatePropertyAll(
                TextStyle(decoration: TextDecoration.none),
              ),
              tapTargetSize: MaterialTapTargetSize.padded,
              visualDensity: VisualDensity.standard,
              padding: const WidgetStatePropertyAll(EdgeInsets.all(12.0)),
            ),
      ),
    );
  }
}
