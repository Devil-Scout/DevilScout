import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

SupabaseClient _supabase() => Supabase.instance.client;

Future<void> supabaseInit() async {
  const supabaseUrl = 'https://jlhplhsuiwwcmxrtbdhp.supabase.co';
  const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpsaHBsaHN1aXd3Y214cnRiZGhwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU4MjA3ODQsImV4cCI6MjA0MTM5Njc4NH0.QKbKHdYoSGC71hrOaHYyJNIJWvwE4ehpNOWVJUYng0M';

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
}

StreamSubscription<AuthState> supabaseAuthListen(
        void Function(AuthState data) onData) =>
    _supabase().auth.onAuthStateChange.listen(onData);

Future<void> supabaseSignOut() => _supabase().auth.signOut();

Future<void> supabaseCreateEmailUser({
  required String name,
  required String email,
  required String password,
}) async {
  try {
    await _supabase().auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': name,
      },
    );
  } on AuthException catch (e) {
    throw e.message;
  }
}

Future<void> supabaseLoginWithEmail({
  required String email,
  required String password,
}) async {
  try {
    await _supabase().auth.signInWithPassword(
          email: email,
          password: password,
        );
  } on AuthException catch (e) {
    throw e.message;
  }
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

Future<void> supabaseLoginWithSso(SsoProvider provider) async {
  try {
    await switch (provider) {
      SsoProvider.apple =>
        Platform.isIOS ? _loginWithAppleNative() : _loginWithAppleAndroid(),
      SsoProvider.google => _loginWithGoogle(),
    };
  } on AuthException catch (e) {
    throw e.message;
  } catch (e) {
    throw e.toString();
  }
}

Future<void> _loginWithGoogle() async {
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
    // aborted
    return;
  }

  final googleAuth = await googleUser.authentication;
  final accessToken = googleAuth.accessToken;
  final idToken = googleAuth.idToken;

  if (accessToken == null || idToken == null) {
    throw 'Error';
  }

  await _supabase().auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
}

Future<void> _loginWithAppleNative() async {
  final rawNonce = _supabase().auth.generateRawNonce();
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
    throw 'Invalid AppleID credential';
  }

  await _supabase().auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

  final String? name;
  if (credential.givenName == null) {
    name = credential.familyName;
  } else if (credential.familyName == null) {
    name = credential.givenName;
  } else {
    name = '${credential.givenName} ${credential.familyName}';
  }

  if (name != null) {
    // native Apple doesn't return name for some reason
    await _supabase().auth.updateUser(
          UserAttributes(
            data: {
              'full_name': name,
            },
          ),
        );
  }
}

Future<void> _loginWithAppleAndroid() async {
  await _supabase().auth.signInWithOAuth(
    OAuthProvider.apple,
    redirectTo: 'org.devilscout.client://',
    queryParams: {'client_id': 'org.devilscout.supabase'},
  );
}
