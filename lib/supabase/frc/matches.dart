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
    required JsonObject? scoreBreakdown,
  }) = _FrcMatchResult;

  factory FrcMatchResult.fromJson(JsonObject json) =>
      _$FrcMatchResultFromJson(json);
}

class FrcMatchesRepository {
  final FrcMatchesService service;

  final Map<String, CacheAll<String, FrcMatch>> _matchesCaches;

  FrcMatchesRepository.supabase(SupabaseClient supabase)
      : this(FrcMatchesService(supabase));

  FrcMatchesRepository(this.service) : _matchesCaches = {};

  CacheAll<String, FrcMatch> _cache(String eventKey) => CacheAll(
        expiration: const Duration(minutes: 30),
        origin: service.getMatch,
        originAll: () => service.getEventMatches(eventKey),
        key: (event) => event.key,
      );

  Future<FrcMatch?> getMatch({
    required String matchKey,
    bool forceOrigin = false,
  }) {
    final eventKey = matchKey.substring(0, matchKey.indexOf('_'));
    return _matchesCaches
        .putIfAbsent(eventKey, () => _cache(eventKey))
        .get(key: matchKey, forceOrigin: forceOrigin);
  }

  Future<List<FrcMatch>> getEventMatches({
    required String eventKey,
    bool forceOrigin = false,
  }) =>
      _matchesCaches
          .putIfAbsent(eventKey, () => _cache(eventKey))
          .getAll(forceOrigin: forceOrigin);
}

class FrcMatchesService {
  final SupabaseClient supabase;

  FrcMatchesService(this.supabase);

  Future<FrcMatch?> getMatch(String matchKey) async {
    final data = await supabase
        .from('frc_matches')
        .select('*, frc_match_teams:teams(*), frc_match_results:result(*)')
        .eq('key', matchKey)
        .maybeSingle();
    return data?.parse(FrcMatch.fromJson);
  }

  Future<List<FrcMatch>> getEventMatches(String eventKey) async {
    final data = await supabase
        .from('frc_matches')
        .select('*, frc_match_teams:teams(*), frc_match_results:result(*)')
        .eq('event_key', eventKey);
    return data.parse(FrcMatch.fromJson);
  }

  Future<List<FrcMatch>> getTeamMatches({
    required int season,
    required int teamNum,
  }) async {
    final data = await supabase
        .from('frc_matches')
        .select('*, frc_match_teams:teams(*), frc_match_results:result(*)')
        .like('key', '$season%')
        .eq('teams.team_num', teamNum);
    return data.parse(FrcMatch.fromJson);
  }
}
