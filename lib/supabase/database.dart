import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'repository/auth.dart';
import 'repository/scouting/questions.dart';

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
  final Map<K, CacheEntry<V>> cache = {};

  final Future<V?> Function(K) origin;
  final Duration expiration;

  Cache({
    required this.expiration,
    required this.origin,
  });

  Future<V?> get({
    required K key,
    bool forceOrigin = false,
  }) async {
    final entry = cache[key];
    if (!forceOrigin && (entry?.isValid(expiration) ?? false)) {
      return entry!.data;
    }

    final data = await origin(key);
    if (data != null) {
      cache[key] = CacheEntry(data);
      return data;
    } else {
      cache.remove(key);
      return null;
    }
  }

  void clear() => cache.clear();
}

class CacheAll<K, V> extends Cache<K, V> {
  final Future<Map<K, V>> Function() originAll;

  CacheEntry<Null>? _allValues;

  CacheAll({
    required super.expiration,
    required super.origin,
    required this.originAll,
  });

  Future<Map<K, V>> getAll({
    bool forceOrigin = false,
  }) async {
    if (!forceOrigin &&
        (_allValues?.isValid(expiration) ?? false) &&
        cache.values.where((e) => !e.isValid(expiration)).isEmpty) {
      return UnmodifiableMapView(cache.map(
        (key, value) => MapEntry(key, value.data),
      ));
    }

    final data = await originAll();
    cache
      ..clear()
      ..addAll(data.map(
        (key, value) => MapEntry(key, CacheEntry(value)),
      ));
    return UnmodifiableMapView(data);
  }
}

class CacheEntry<V> {
  final V data;
  final DateTime timestamp;

  CacheEntry(this.data) : timestamp = DateTime.now();

  bool isValid(Duration expiration) =>
      DateTime.now().isBefore(timestamp.add(expiration));
}
