import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

class AuthRepository {
  final AuthService _service;

  AuthRepository(this._service);
  AuthRepository.supabase(SupabaseClient supabase)
      : this(AuthService(supabase));

  String? get name => _service.name;
  Future<void> setName(String name) => _service.setName(name);

  StreamSubscription<AuthState> addListener(
    void Function(AuthState data) onData,
  ) =>
      _service.addListener(onData);

  Future<void> signOut() => _service.signOut();

  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) =>
      _service.signUpWithEmail(name: name, email: email, password: password);

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _service.signInWithEmail(email: email, password: password);

  Future<void> signInWithSso(SsoProvider provider) =>
      _service.signInWithSso(provider);
}

class AuthService {
  final SupabaseClient supabase;

  AuthService(this.supabase);

  String? get name => supabase.auth.currentUser?.userMetadata?['full_name'];

  Future<void> setName(String name) => supabase.auth.updateUser(
        UserAttributes(
          data: {'full_name': name},
        ),
      );

  int? get teamNum => supabase.auth.currentUser?.userMetadata?['team_num'];

  StreamSubscription<AuthState> addListener(
    void Function(AuthState data) onData,
  ) =>
      supabase.auth.onAuthStateChange.listen(onData);

  Future<void> signOut() => supabase.auth.signOut();

  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await supabase.auth.signUp(
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

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      throw e.message;
    }
  }

  Future<void> signInWithSso(SsoProvider provider) async {
    try {
      await switch (provider) {
        SsoProvider.apple =>
          Platform.isIOS ? _loginWithAppleNative() : _loginWithAppleWeb(),
        SsoProvider.google => _signInWithGoogle(),
      };
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> _signInWithGoogle() async {
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

    await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  Future<void> _loginWithAppleNative() async {
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
      throw 'Invalid AppleID credential';
    }

    await supabase.auth.signInWithIdToken(
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
      await supabase.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': name,
          },
        ),
      );
    }
  }

  Future<void> _loginWithAppleWeb() async {
    await supabase.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'org.devilscout.client://',
      queryParams: {'client_id': 'org.devilscout.supabase'},
    );
  }
}
