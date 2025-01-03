import 'package:supabase_flutter/supabase_flutter.dart';

import 'client.dart';

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
    await supabase.auth.updateUser(
      UserAttributes(
        data: {
          UserName.metadataKey: name,
        },
      ),
    );

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
