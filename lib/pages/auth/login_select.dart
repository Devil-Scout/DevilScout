import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
            _ssoButton(context, provider: _SsoProvider.google),
            const SizedBox(height: 14.0),
            _ssoButton(context, provider: _SsoProvider.apple),
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
    required _SsoProvider provider,
  }) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _loginWithSso(provider),
            icon: SvgPicture.asset(
              provider.iconPath,
              width: 24.0,
              height: 24.0,
            ),
            label: Padding(
              padding: EdgeInsets.only(left: 4.0),
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
            icon: const FaIcon(FontAwesomeIcons.envelope),
            label: const Padding(
              padding: EdgeInsets.only(left: 4.0),
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
        icon: const FaIcon(FontAwesomeIcons.circleQuestion),
        label: const Text("Why do I need to sign in?"),
        style: Theme.of(context).textButtonTheme.style!.copyWith(
              foregroundColor: WidgetStatePropertyAll(Colors.grey[600]),
              overlayColor: WidgetStatePropertyAll(Colors.grey[200]),
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

  void _loginWithSso(_SsoProvider provider) async {
    final AuthResponse loginResponse;
    try {
      loginResponse = switch (provider) {
        _SsoProvider.apple => await _loginWithApple(),
        _SsoProvider.google => await _loginWithGoogle(),
      };
    } on AuthException catch (e) {
      // TODO: notify user of the error in the UI
      // https://supabase.com/docs/guides/auth/debugging/error-codes#auth-error-codes-table
      print('email login failed');
      print(e.code);
      print(e.message);
      return;
    } catch (e) {
      // other exceptions
      print(e);
      return;
    }

    print(loginResponse);
  }
}

enum _SsoProvider {
  apple(
    name: 'Apple',
    iconPath: "assets/images/logos/apple-logo.svg",
  ),
  google(
    name: 'Google',
    iconPath: "assets/images/logos/g-logo.svg",
  );

  final String name;
  final String iconPath;

  const _SsoProvider({
    required this.name,
    required this.iconPath,
  });
}

Future<AuthResponse> _loginWithGoogle() async {
  final supabase = Supabase.instance.client;

  const webClientId = ''; // FIXME
  const iosClientId = ''; // FIXME

  final googleSignIn = GoogleSignIn(
    clientId: iosClientId,
    serverClientId: webClientId,
  );

  final googleUser = await googleSignIn.signIn();
  if (googleUser == null) {
    throw 'Error';
  }

  final googleAuth = await googleUser.authentication;
  final accessToken = googleAuth.accessToken;
  final idToken = googleAuth.idToken;

  if (accessToken == null || idToken == null) {
    throw 'Error';
  }

  return await supabase.auth.signInWithIdToken(
    provider: OAuthProvider.google,
    idToken: idToken,
    accessToken: accessToken,
  );
}

Future<AuthResponse> _loginWithApple() async {
  final supabase = Supabase.instance.client;

  const clientId = ''; // FIXME
  const redirectUri = ''; // FIXME

  final rawNonce = supabase.auth.generateRawNonce();
  final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

  final credential = await SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
    webAuthenticationOptions: WebAuthenticationOptions(
      clientId: clientId,
      redirectUri: Uri.parse(redirectUri),
    ),
    nonce: hashedNonce,
  );

  final idToken = credential.identityToken;
  if (idToken == null) {
    throw 'Error';
  }

  return await supabase.auth.signInWithIdToken(
    provider: OAuthProvider.apple,
    idToken: idToken,
    nonce: rawNonce,
  );
}
