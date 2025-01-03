import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

late final SupabaseClient supabase;

Future<void> supabaseInit() async {
  const supabaseUrl = 'https://jlhplhsuiwwcmxrtbdhp.supabase.co';
  const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpsaHBsaHN1aXd3Y214cnRiZGhwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU4MjA3ODQsImV4cCI6MjA0MTM5Njc4NH0.QKbKHdYoSGC71hrOaHYyJNIJWvwE4ehpNOWVJUYng0M';

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  supabase = Supabase.instance.client;
}

enum SsoProvider {
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

  const SsoProvider({
    required this.name,
    required this.iconPath,
  });
}

Future<AuthResponse?> supabaseLoginWithSso(SsoProvider provider) async {
  final AuthResponse? loginResponse;
  try {
    loginResponse = switch (provider) {
      SsoProvider.apple => await _loginWithAppleNative(),
      SsoProvider.google => await _loginWithGoogle(),
    };
  } on AuthException catch (e) {
    // TODO: notify user of the error in the UI
    // https://supabase.com/docs/guides/auth/debugging/error-codes#auth-error-codes-table
    print('sso login failed');
    print(e.code);
    print(e.message);
    return null;
  } catch (e) {
    // other exceptions
    print('sso login failed');
    print(e);
    return null;
  }

  if (loginResponse == null) {
    print('sso login aborted');
    return null;
  }

  print(loginResponse);
  print(loginResponse.user?.identities);

  return loginResponse;
}

Future<AuthResponse?> _loginWithGoogle() async {
  // from https://console.cloud.google.com/apis/credentials
  const webClientId =
      '609606147453-l9aepfbrr7bc3c8qgf3sp6mjlrguo6un.apps.googleusercontent.com';
  const iosClientId =
      '609606147453-at5j8nhgv2j52ogh7rn1nfij7vpn8h2v.apps.googleusercontent.com';

  final googleSignIn = GoogleSignIn(
    clientId: iosClientId,
    serverClientId: webClientId,
  );

  final googleUser = await googleSignIn.signIn();
  if (googleUser == null) {
    // login was aborted
    return null;
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

Future<AuthResponse?> _loginWithAppleNative() async {
  if (!Platform.isIOS) {
    print('only supported on iOS');
    return null;
  }

  final rawNonce = supabase.auth.generateRawNonce();
  final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

  final credential = await SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
    nonce: hashedNonce,
  );

  final idToken = credential.identityToken;
  if (idToken == null) {
    throw const AuthException(
      'Could not find ID Token from generated credential.',
    );
  }

  return await supabase.auth.signInWithIdToken(
    provider: OAuthProvider.apple,
    idToken: idToken,
    nonce: rawNonce,
  );
}

Future<AuthResponse?> supabaseCreateEmailUser({
  required String name,
  required String email,
  required String password,
}) async {
  final AuthResponse signupResponse;
  try {
    signupResponse = await supabase.auth.signUp(
      email: email,
      password: password,
    );
  } on AuthException catch (e) {
    // TODO: notify user of the error in the UI
    // https://supabase.com/docs/guides/auth/debugging/error-codes#auth-error-codes-table
    print('email signup failed');
    print(e.code);
    print(e.message);
    return null;
  }

  // TODO: handle Confirm Emails once enabled

  Session? session = signupResponse.session;
  if (session != null) {
    // Set the user's name in the db
    await supabase.from('users').upsert({
      'name': name,
    }).eq('id', session.user.id);

    // TODO: clear nav stack and push home page
    print('email signup succeeded');
  }

  return signupResponse;
}

Future<AuthResponse?> supabaseLoginWithEmail({
  required String email,
  required String password,
}) async {
  final AuthResponse loginResponse;
  try {
    loginResponse = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  } on AuthException catch (e) {
    // TODO: notify user of the error in the UI
    // https://supabase.com/docs/guides/auth/debugging/error-codes#auth-error-codes-table
    print('email login failed');
    print(e.code);
    print(e.message);
    return null;
  }

  if (loginResponse.session != null) {
    // TODO: clear nav stack and push home page
    print('email login succeeded');
  }

  return loginResponse;
}
