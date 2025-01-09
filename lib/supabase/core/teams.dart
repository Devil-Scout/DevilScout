import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database.dart';
import '../frc/teams.dart';

part 'teams.freezed.dart';
part 'teams.g.dart';

@immutable
@freezed
class Team with _$Team {
  const factory Team({
    required int number,
    required bool verified,
    required DateTime createdAt,
    required String createdBy,
    required String name,
    FrcTeam? frcTeam,
  }) = _Team;

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);
}

class TeamsRepository {
  final CacheAll<int, Team> _teamsCache;

  TeamsRepository.supabase(SupabaseClient supabase)
      : this(TeamsService(supabase));

  TeamsRepository(TeamsService service)
      : _teamsCache = CacheAll(
          expiration: const Duration(minutes: 30),
          origin: (teamNum) => service.getTeam(teamNum: teamNum),
          originAll: () => service.getAllTeams(),
        );

  Future<Team?> getTeam({
    required int teamNum,
    bool forceOrigin = false,
  }) =>
      _teamsCache.get(
        key: teamNum,
        forceOrigin: forceOrigin,
      );

  Future<Map<int, Team>> getAllTeams({
    bool forceOrigin = false,
  }) =>
      _teamsCache.getAll(
        forceOrigin: forceOrigin,
      );
}

class TeamsService {
  final SupabaseClient supabase;

  TeamsService(this.supabase);

  Future<Team?> getTeam({
    required int teamNum,
  }) async {
    final data = await supabase
        .from('teams')
        .select()
        .eq('number', teamNum)
        .maybeSingle();
    return data?.parse(Team.fromJson);
  }

  Future<Map<int, Team>> getAllTeams() async {
    final data = await supabase.from('teams').select();
    return data.parseToMap(Team.fromJson, (team) => team.number);
  }
}
