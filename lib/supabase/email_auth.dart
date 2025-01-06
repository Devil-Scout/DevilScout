import 'package:supabase_flutter/supabase_flutter.dart';

import 'client.dart';

Future<void> supabaseCreateEmailUser({
  required String name,
  required String email,
  required String password,
}) async {
  try {
    await supabase.auth.signUp(
      email: email,
      password: password,
    );
  } on AuthException catch (e) {
    throw e.message;
  }

  // Set the user's name in the db
  await supabase.auth.updateUser(
    UserAttributes(
      data: {
        UserName.metadataKey: name,
      },
    ),
  );
}

Future<void> supabaseLoginWithEmail({
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
