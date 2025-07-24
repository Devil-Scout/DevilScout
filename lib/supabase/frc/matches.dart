import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase/supabase.dart';

import '../database.dart';
import 'frc.dart';

part 'matches.freezed.dart';
part 'matches.g.dart';

@immutable
@freezed
@JsonSerializable()
final class FrcMatch with _$FrcMatch {
  @override
  final int number;
  @override
  final int set;
  @override
  final FrcMatchLevel level;
  @override
  final String eventKey;
  @override
  final String key;
  @override
  final DateTime? scheduledTime;
  @override
  final DateTime? predictedTime;
  @override
  final DateTime? actualTime;
  @override
  final List<FrcMatchTeam> teams;
  @override
  final FrcMatchResult? result;

  const FrcMatch({
    required this.number,
    required this.set,
    required this.level,
    required this.eventKey,
    required this.key,
    this.scheduledTime,
    this.predictedTime,
    this.actualTime,
    required this.teams,
    this.result,
  });

  factory FrcMatch.fromJson(JsonObject json) => _$FrcMatchFromJson(json);
}

@immutable
@freezed
@JsonSerializable()
final class FrcMatchTeam with _$FrcMatchTeam {
  @override
  final int teamNum;
  @override
  final int station;
  @override
  final FrcAlliance alliance;
  @override
  final bool isSurrogate;
  @override
  final bool isDisqualified;
  @override
  final String matchKey;

  const FrcMatchTeam({
    required this.teamNum,
    required this.station,
    required this.alliance,
    required this.isSurrogate,
    required this.isDisqualified,
    required this.matchKey,
  });

  factory FrcMatchTeam.fromJson(JsonObject json) =>
      _$FrcMatchTeamFromJson(json);
}

@immutable
@freezed
@JsonSerializable()
final class FrcMatchResult with _$FrcMatchResult {
  @override
  final int redScore;
  @override
  final int blueScore;
  @override
  final FrcAlliance? winningAlliance;
  @override
  final String matchKey;
  @override
  final JsonList videos;

  const FrcMatchResult({
    required this.redScore,
    required this.blueScore,
    required this.winningAlliance,
    required this.matchKey,
    required this.videos,
  });

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
