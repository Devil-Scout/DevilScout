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

extension UserName on User {
  static const metadataKey = 'full_name';
  String? get name => userMetadata?[metadataKey];
}
