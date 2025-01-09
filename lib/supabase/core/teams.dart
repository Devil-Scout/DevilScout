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

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);
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

  factory TeamRegistration.fromJson(Map<String, dynamic> json) =>
      _$TeamRegistrationFromJson(json);
}

class TeamsRepository {
  final TeamsService service;
  final CacheAll<int, Team> _teamsCache;

  TeamsRepository.supabase(SupabaseClient supabase)
      : this(TeamsService(supabase));

  TeamsRepository(this.service)
      : _teamsCache = CacheAll(
          expiration: const Duration(minutes: 30),
          origin: service.getTeam,
          originAll: service.getAllTeams,
          key: (team) => team.number,
        );

  Future<Team?> getTeam({
    required int teamNum,
    bool forceOrigin = false,
  }) =>
      _teamsCache.get(
        key: teamNum,
        forceOrigin: forceOrigin,
      );

  Future<List<Team>> getAllTeams({
    bool forceOrigin = false,
  }) =>
      _teamsCache.getAll(
        forceOrigin: forceOrigin,
      );
}

class TeamsService {
  final SupabaseClient supabase;

  TeamsService(this.supabase);

  Future<Team?> getTeam(int teamNum) async {
    final data = await supabase
        .from('frc_teams')
        .select('number, name, country, province, city, teams:registration(*)')
        .eq('number', teamNum)
        .maybeSingle();
    return data?.parse(Team.fromJson);
  }

  Future<List<Team>> getAllTeams() async {
    final data = await supabase
        .from('frc_teams')
        .select('number, name, country, province, city, teams:registration(*)');
    return data.parse(Team.fromJson);
  }
}
