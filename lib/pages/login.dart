import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 256.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Text(
                        "Welcome! 👋",
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ),
                    Text(
                      "Choose your sign in method below",
                      style: Theme.of(context).textTheme.bodyLarge,
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 14.0),
              child: OutlinedButton(
                // Sign in with Google
                onPressed: () {},
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                        padding: EdgeInsets.only(right: 12.0),
                        child: FaIcon(FontAwesomeIcons.google, size: 25.0)),
                    Text("Sign in with Google"),
                  ],
                ),
              ),
            ),
            OutlinedButton(
              // Sign in with Apple
              onPressed: () {},
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                      padding: EdgeInsets.only(right: 12.0),
                      child: FaIcon(FontAwesomeIcons.apple, size: 30.0)),
                  Text("Sign in with Apple"),
                ],
              ),
            ),
            Padding(
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
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text(
                "Sign in",
                style: Theme.of(context)
                    .textTheme
                    .displaySmall!
                    .copyWith(color: Theme.of(context).colorScheme.onPrimary),
              ),
            )
          ],
        ),
      ),
    );
  }
}
