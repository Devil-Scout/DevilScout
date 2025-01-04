import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../appwrapper.dart';
import '../../supabase/sso_auth.dart';
import 'email_login.dart';

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
            _headerText(context),
            const SizedBox(height: 40.0),
            _ssoButton(context, provider: SsoProvider.google),
            const SizedBox(height: 14.0),
            _ssoButton(context, provider: SsoProvider.apple),
            _divider(context),
            _emailButton(context),
            const SizedBox(height: 16.0),
            _signInInfo(context),
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
            "Choose your sign in method below to get started",
            style: Theme.of(context).textTheme.bodyLarge,
          )
        ],
      ),
    );
  }

  Widget _ssoButton(
    BuildContext context, {
    required SsoProvider provider,
  }) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _loginWithSso(context, provider),
            icon: SvgPicture.asset(
              provider.iconPath,
              width: 24.0,
              height: 24.0,
            ),
            label: Padding(
              padding: EdgeInsets.only(left: 6.0),
              child: Text('Sign in with ${provider.name}'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _divider(BuildContext context) {
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

  Widget _emailButton(BuildContext context) {
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
            icon: Icon(Icons.mail_outline),
            label: const Padding(
              padding: EdgeInsets.only(left: 6.0),
              child: Text("Continue with Email"),
            ),
          ),
        ),
      ],
    );
  }

  Widget _signInInfo(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () {},
        icon: Icon(Icons.help_outline, size: 22.0),
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

  Future<void> _loginWithSso(BuildContext context, SsoProvider provider) async {
    final response = await supabaseLoginWithSso(provider);
    if (!context.mounted) return;

    if (response?.session != null) {
      // Push home page and clear nav stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AppWrapper()),
        (_) => false,
      );
    }

    // TODO: unsuccessful/additional steps
    print(response);
  }
}
