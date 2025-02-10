import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase/supabase.dart';

import '../database.dart';

part 'teams.freezed.dart';
part 'teams.g.dart';

@immutable
@freezed
class Team with _$Team {
  const Team._();

  const factory Team({
    required int number,
    required String name,
    String? country,
    String? province,
    String? city,
    TeamRegistration? registration,
  }) = _Team;

  factory Team.fromJson(JsonObject json) => _$TeamFromJson(json);

  bool get isRegistered => registration != null;
}

@immutable
@freezed
class TeamRegistration with _$TeamRegistration {
  const factory TeamRegistration({
    required int number,
    required bool verified,
    required DateTime createdAt,
    required String name,
  }) = _TeamRegistration;

  factory TeamRegistration.fromJson(JsonObject json) =>
      _$TeamRegistrationFromJson(json);
}

class TeamsRepository {
  final TeamsService _service;
  final Cache<int, Team> _teamsCache;

  TeamsRepository.supabase(SupabaseClient supabase)
      : this(TeamsService(supabase));

  TeamsRepository(this._service)
      : _teamsCache = Cache(
          expiration: const Duration(minutes: 30),
          origin: _service.getTeam,
          originMultiple: _service.getTeams,
          key: (team) => team.number,
        );

  Future<Team?> getTeam({
    required int teamNum,
    bool forceOrigin = false,
  }) =>
      _teamsCache.get(key: teamNum, forceOrigin: forceOrigin);

  Future<List<Team>> getTeams({
    required Iterable<int> teamNums,
    bool forceOrigin = false,
  }) =>
      _teamsCache.getMultiple(keys: teamNums, forceOrigin: forceOrigin);

  Future<List<int>> searchTeams({
    required String query,
    int limit = 20,
  }) =>
      _service.searchTeams(query: query, limit: limit);

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
        .select('number, name, country, province, city, registration:teams(*)')
        .eq('number', teamNum)
        .maybeSingle();
    return data?.parse(Team.fromJson);
  }

  Future<List<Team>> getTeams(Iterable<int> teamNums) async {
    final data = await _supabase
        .from('frc_teams')
        .select('number, name, country, province, city, registration:teams(*)')
        .inFilter('number', teamNums.toList());
    return data.parse(Team.fromJson);
  }

  Future<List<int>> searchTeams({
    required String query,
    required int limit,
  }) async {
    final data = await _supabase
        .rpc('frc_teams_search', params: {'query': query}).limit(limit);
    return List.castFrom(data as List<dynamic>);
  }

  Future<void> createTeam({
    required int teamNum,
    required String name,
  }) async {
    await _supabase.from('teams').insert({
      'number': teamNum,
      'name': name,
    });
    await _supabase.auth.refreshSession();
  }

  Future<void> deleteTeam(int teamNum) =>
      _supabase.from('teams').delete().eq('number', teamNum);

  Future<void> updateTeamName({
    required int teamNum,
    required String name,
  }) =>
      _supabase.from('teams').update({'name': name}).eq('team_num', teamNum);
}
