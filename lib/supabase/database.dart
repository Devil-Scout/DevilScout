import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'repository/auth.dart';
import 'repository/questions.dart';

class Database {
  final AuthRepository auth;
  final QuestionsRepository questions;

  Database({
    required this.auth,
    required this.questions,
  });

  Database.supabase(SupabaseClient supabase)
      : this(
          auth: AuthRepository.supabase(supabase),
          questions: QuestionsRepository.supabase(supabase),
        );

  factory Database.of(BuildContext context) =>
      Provider.of<Database>(context, listen: false);

  static Future<void> initSupabase() async {
    const supabaseUrl = 'https://jlhplhsuiwwcmxrtbdhp.supabase.co';
    const supabaseAnonKey =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpsaHBsaHN1aXd3Y214cnRiZGhwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU4MjA3ODQsImV4cCI6MjA0MTM5Njc4NH0.QKbKHdYoSGC71hrOaHYyJNIJWvwE4ehpNOWVJUYng0M';

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}

class Cache<K, V> {
  final Map<K, _CacheEntry<V>> _cache = {};

  final Future<V> Function(K) origin;
  final Duration expiration;

  Cache({
    required this.expiration,
    required this.origin,
  });

  Future<V> get({
    required K key,
    bool forceOrigin = false,
  }) async {
    final entry = _cache[key];
    if (!forceOrigin && entry != null && entry.isValid(expiration)) {
      return entry.data;
    }

    final data = await origin(key);
    _cache[key] = _CacheEntry(data);
    return data;
  }

  void clear() => _cache.clear();
}

class _CacheEntry<V> {
  final V data;
  final DateTime timestamp;

  _CacheEntry(this.data) : timestamp = DateTime.now();

  bool isValid(Duration expiration) =>
      DateTime.now().isBefore(timestamp.add(expiration));
}
