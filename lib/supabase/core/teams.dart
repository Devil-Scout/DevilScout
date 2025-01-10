import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database.dart';

part 'teams.freezed.dart';
part 'teams.g.dart';

@immutable
@freezed
class Team with _$Team {
  const factory Team({
    required int number,
    required String name,
    String? country,
    String? province,
    String? city,
    TeamRegistration? registration,
  }) = _Team;

  factory Team.fromJson(JsonObject json) => _$TeamFromJson(json);
}

@immutable
@freezed
class TeamRegistration with _$TeamRegistration {
  const factory TeamRegistration({
    required int number,
    required bool verified,
    required DateTime createdAt,
    required Uuid createdBy,
    required String name,
  }) = _TeamRegistration;

  factory TeamRegistration.fromJson(JsonObject json) =>
      _$TeamRegistrationFromJson(json);
}

class TeamsRepository {
  final TeamsService _service;
  final CacheAll<int, Team> _teamsCache;

  TeamsRepository.supabase(SupabaseClient supabase)
      : this(TeamsService(supabase));

  TeamsRepository(this._service)
      : _teamsCache = CacheAll(
          expiration: const Duration(minutes: 30),
          origin: _service.getTeam,
          originAll: _service.getAllTeams,
          key: (team) => team.number,
        );

  Future<Team?> getTeam({
    required int teamNum,
    bool forceOrigin = false,
  }) =>
      _teamsCache.get(key: teamNum, forceOrigin: forceOrigin);

  Future<List<Team>> getAllTeams({bool forceOrigin = false}) =>
      _teamsCache.getAll(forceOrigin: forceOrigin);

  Future<List<int>> searchTeams({
    required String query,
    int limit = 5,
  }) =>
      _service.searchTeams(query, limit: limit);

  Future<void> createTeam({
    required int teamNum,
    required String name,
  }) =>
      _service.createTeam(teamNum: teamNum, name: name);

  Future<void> deleteTeam({required int teamNum}) =>
      _service.deleteTeam(teamNum);

  Future<void> updateTeamName({
    required int teamNum,
    required String name,
  }) =>
      _service.updateTeamName(teamNum: teamNum, name: name);
}

class TeamsService {
  final SupabaseClient _supabase;

  TeamsService(this._supabase);

  Future<Team?> getTeam(int teamNum) async {
    final data = await _supabase
        .from('frc_teams')
        .select('number, name, country, province, city, teams:registration(*)')
        .eq('number', teamNum)
        .maybeSingle();
    return data?.parse(Team.fromJson);
  }

  Future<List<Team>> getAllTeams() async {
    final data = await _supabase
        .from('frc_teams')
        .select('number, name, country, province, city, teams:registration(*)');
    return data.parse(Team.fromJson);
  }

  Future<List<int>> searchTeams(String query, {int limit = 10}) async {
    final data = await _supabase
        .rpc('frc_teams_search', params: {'query': query}).limit(limit);
    return data as List<int>;
  }

  Future<void> createTeam({
    required int teamNum,
    required String name,
  }) =>
      _supabase.from('teams').insert({
        'number': teamNum,
        'name': name,
      });

  Future<void> deleteTeam(int teamNum) =>
      _supabase.from('teams').delete().eq('number', teamNum);

  Future<void> updateTeamName({
    required int teamNum,
    required String name,
  }) =>
      _supabase.from('teams').update({'name': name}).eq('team_num', teamNum);
}
