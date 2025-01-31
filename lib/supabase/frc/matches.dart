import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database.dart';
import 'frc.dart';

part 'matches.freezed.dart';
part 'matches.g.dart';

@immutable
@freezed
class FrcMatch with _$FrcMatch {
  const factory FrcMatch({
    required int number,
    required int set,
    required FrcMatchLevel level,
    required String eventKey,
    required String key,
    DateTime? scheduledTime,
    DateTime? predictedTime,
    DateTime? actualTime,
    required List<FrcMatchTeam> teams,
    FrcMatchResult? result,
  }) = _FrcMatch;

  factory FrcMatch.fromJson(JsonObject json) => _$FrcMatchFromJson(json);
}

@immutable
@freezed
class FrcMatchTeam with _$FrcMatchTeam {
  const factory FrcMatchTeam({
    required int teamNum,
    required int station,
    required FrcAlliance alliance,
    required bool isSurrogate,
    required bool isDisqualified,
    required String matchKey,
  }) = _FrcMatchTeam;

  factory FrcMatchTeam.fromJson(JsonObject json) =>
      _$FrcMatchTeamFromJson(json);
}

@immutable
@freezed
class FrcMatchResult with _$FrcMatchResult {
  const factory FrcMatchResult({
    required int redScore,
    required int blueScore,
    required FrcAlliance? winningAlliance,
    required String matchKey,
    required JsonList videos,
  }) = _FrcMatchResult;

  factory FrcMatchResult.fromJson(JsonObject json) =>
      _$FrcMatchResultFromJson(json);
}

class FrcMatchesRepository {
  final FrcMatchesService _service;

  final Map<String, CacheAll<String, FrcMatch>> _matchesCaches;
  final Map<int, Cache<int, List<FrcMatch>>> _teamMatchesCaches;

  FrcMatchesRepository.supabase(SupabaseClient supabase)
      : this(FrcMatchesService(supabase));

  FrcMatchesRepository(this._service)
      : _matchesCaches = {},
        _teamMatchesCaches = {};

  CacheAll<String, FrcMatch> _matchesCache(String eventKey) => CacheAll(
        expiration: const Duration(minutes: 30),
        origin: _service.getMatch,
        originAll: () async => _service.getEventMatches(eventKey),
        key: (event) => event.key,
      );

  Cache<int, List<FrcMatch>> _teamMatchesCache(int teamNum) => Cache(
        expiration: const Duration(minutes: 30),
        origin: (season) async =>
            _service.getTeamMatches(season: season, teamNum: teamNum),
      );

  Future<FrcMatch?> getMatch({
    required String matchKey,
    bool forceOrigin = false,
  }) {
    final eventKey = matchKey.substring(0, matchKey.indexOf('_'));
    return _matchesCaches
        .putIfAbsent(eventKey, () => _matchesCache(eventKey))
        .get(key: matchKey, forceOrigin: forceOrigin);
  }

  Future<List<FrcMatch>> getEventMatches({
    required String eventKey,
    bool forceOrigin = false,
  }) =>
      _matchesCaches
          .putIfAbsent(eventKey, () => _matchesCache(eventKey))
          .getAll(forceOrigin: forceOrigin);

  Future<List<FrcMatch>> getTeamMatches({
    required int season,
    required int teamNum,
    bool forceOrigin = false,
  }) =>
      _teamMatchesCaches
          .putIfAbsent(teamNum, () => _teamMatchesCache(teamNum))
          .get(key: season, forceOrigin: forceOrigin)
          .then((list) => list ?? List.empty());
}

class FrcMatchesService {
  final SupabaseClient _supabase;

  FrcMatchesService(this._supabase);

  Future<FrcMatch?> getMatch(String matchKey) async {
    final data = await _supabase
        .from('frc_matches')
        .select('*, teams:frc_match_teams(*), result:frc_match_results(*)')
        .eq('key', matchKey)
        .maybeSingle();
    return data?.parse(FrcMatch.fromJson);
  }

  Future<List<FrcMatch>> getEventMatches(String eventKey) async {
    final data = await _supabase
        .from('frc_matches')
        .select('*, teams:frc_match_teams(*), result:frc_match_results(*)')
        .eq('event_key', eventKey);
    return data.parse(FrcMatch.fromJson);
  }

  Future<List<FrcMatch>> getTeamMatches({
    required int season,
    required int teamNum,
  }) async {
    final data = await _supabase
        .from('frc_matches')
        .select(
          '*, teams:frc_match_teams!inner(*), result:frc_match_results(*)',
        )
        .like('key', '$season%')
        .eq('teams.team_num', teamNum);
    return data.parse(FrcMatch.fromJson);
  }
}
