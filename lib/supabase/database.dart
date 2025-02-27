import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'base/auth.dart';
import 'base/current_user.dart';
import 'core/team_requests.dart';
import 'core/team_users.dart';
import 'core/teams.dart';
import 'frc/districts.dart';
import 'frc/events.dart';
import 'frc/matches.dart';
import 'frc/seasons.dart';
import 'frc/teams.dart';
import 'scouting/questions.dart';

class Database {
  final SupabaseClient? supabase;

  final AuthRepository auth;
  final CurrentUserRepository currentUser;

  final TeamsRepository teams;
  final TeamUsersRepository teamUsers;
  final TeamRequestsRepository teamRequests;

  final FrcSeasonsRepository frcSeasons;
  final FrcTeamsRepository frcTeams;
  final FrcDistrictsRepository frcDistricts;
  final FrcEventsRepository frcEvents;
  final FrcMatchesRepository frcMatches;

  final QuestionsRepository questions;

  Database({
    this.supabase,
    required this.auth,
    required this.currentUser,
    required this.teams,
    required this.teamUsers,
    required this.teamRequests,
    required this.frcSeasons,
    required this.frcTeams,
    required this.frcDistricts,
    required this.frcEvents,
    required this.frcMatches,
    required this.questions,
  });

  Database.supabase(SupabaseClient supabase)
      : this(
          supabase: supabase,
          auth: AuthRepository.supabase(supabase),
          currentUser: CurrentUserRepository.supabase(supabase),
          teams: TeamsRepository.supabase(supabase),
          teamUsers: TeamUsersRepository.supabase(supabase),
          teamRequests: TeamRequestsRepository.supabase(supabase),
          frcSeasons: FrcSeasonsRepository.supabase(supabase),
          frcTeams: FrcTeamsRepository.supabase(supabase),
          frcDistricts: FrcDistrictsRepository.supabase(supabase),
          frcEvents: FrcEventsRepository.supabase(supabase),
          frcMatches: FrcMatchesRepository.supabase(supabase),
          questions: QuestionsRepository.supabase(supabase),
        );

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

extension DatabaseContext on BuildContext {
  Database get database => Provider.of<Database>(this, listen: false);
}

class Cache<K extends Object, V extends Object> {
  @protected
  final Future<V?> Function(K) origin;
  @protected
  final Future<Iterable<V>> Function(Iterable<K>) originMultiple;
  @protected
  final K Function(V) keyMapper;
  @protected
  final Duration expiration;

  @protected
  final Map<K, CacheEntry<V>> cache = {};

  Cache({
    required this.expiration,
    required this.origin,
    K Function(V)? key,
    Future<Iterable<V>> Function(Iterable<K>)? originMultiple,
  })  : keyMapper = key ?? _identity,
        originMultiple = originMultiple ?? ((keys) => _multiple(origin, keys));

  Future<V?> get({
    required K key,
    required bool forceOrigin,
  }) async {
    if (forceOrigin || (cache[key]?.isExpired(expiration) ?? true)) {
      final data = await origin(key);
      if (data != null) {
        cache[key] = CacheEntry(data);
      } else {
        cache.remove(key);
      }
    }

    return cache[key]?.data;
  }

  Future<List<V>> getMultiple({
    required Iterable<K> keys,
    required bool forceOrigin,
  }) async {
    if (forceOrigin ||
        keys.any((k) => cache[k]?.isExpired(expiration) ?? true)) {
      final data = await originMultiple(keys);
      for (final val in data) {
        cache[keyMapper(val)] = CacheEntry(val);
      }
    }

    return keys.map((k) => cache[k]?.data).nonNulls.toList();
  }

  void clear() => cache.clear();

  static K _identity<K, V>(V value) => value as K;

  static Future<Iterable<V>> _multiple<K extends Object, V extends Object>(
    Future<V?> Function(K) origin,
    Iterable<K> keys,
  ) {
    return Future.wait([for (final key in keys) origin(key)])
        .then((values) => values.nonNulls);
  }
}

class CacheAll<K extends Object, V extends Object> extends Cache<K, V> {
  @protected
  final Future<Iterable<V>> Function() originAll;
  @protected
  CacheEntry<void>? allValues;

  CacheAll({
    required super.expiration,
    required super.origin,
    super.key,
    super.originMultiple,
    required this.originAll,
  });

  Future<List<V>> getAll({
    required bool forceOrigin,
  }) async {
    if (forceOrigin ||
        (allValues?.isExpired(expiration) ?? true) ||
        cache.values.where((e) => !e.isExpired(expiration)).isNotEmpty) {
      final data = await originAll();
      cache
        ..clear()
        ..addEntries(
          data.map(
            (value) => MapEntry(keyMapper(value), CacheEntry(value)),
          ),
        );
      allValues = CacheEntry(null);
    }

    return UnmodifiableListView(
      cache.values.map(
        (entry) => entry.data,
      ),
    );
  }
}

class CacheEntry<V> {
  final V data;
  final DateTime timestamp;

  CacheEntry(this.data) : timestamp = DateTime.now();

  bool isExpired(Duration expiration) =>
      DateTime.now().isAfter(timestamp.add(expiration));
}

typedef Uuid = String;
typedef JsonObject = Map<String, dynamic>;
typedef JsonList = List<Map<String, dynamic>>;

extension JsonParseObject on JsonObject {
  T parse<T>(T Function(JsonObject) fromJson) => fromJson(this);
}

extension JsonParseList on JsonList {
  List<T> parse<T>(T Function(JsonObject) fromJson) => map(fromJson).toList();
}

enum DatabaseErrorClass {
  success('00'),
  warning('01'),
  noData('02'),
  notYetComplete('03'),
  connection('08'),
  trigger('09'),
  unsupported('0A'),
  transactionInitiation('0B'),
  locator('0F'),
  grantor('0L'),
  role('0P'),
  diagnostics('0Z'),
  caseNotFound('20'),
  cardinality('21'),
  data('22'),
  integrity('23'),
  cursor('24'),
  transactionState('25'),
  statementName('26'),
  triggerChange('27'),
  authorization('28'),
  dependentPrivilegeDescriptorsStillExist('2B'),
  transactionTermination('2D'),
  sqlRoutine('2F'),
  cursorName('34'),
  externalRoutine('38'),
  externalRoutineInvocation('39'),
  savepoint('3B'),
  catalogName('3D'),
  schemaName('3F'),
  transactionRollback('40'),
  syntaxOrAccess('42'),
  checkViolation('44'),
  insufficientResources('53'),
  programLimitExceeded('54'),
  prerequisiteState('55'),
  operatorIntervention('57'),
  externalSystem('58'),
  config('F0'),
  foerignData('HV'),
  plpgsql('P0'),
  internal('XX');

  final String _prefix;

  const DatabaseErrorClass(this._prefix);

  static DatabaseErrorClass? of(String? prefix) => _map[prefix];

  static final Map<String, DatabaseErrorClass> _map = Map.fromEntries(
    DatabaseErrorClass.values.map((e) => MapEntry(e._prefix, e)),
  );
}
