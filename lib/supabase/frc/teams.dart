import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database.dart';

part 'teams.freezed.dart';
part 'teams.g.dart';

@immutable
@freezed
class FrcTeam with _$FrcTeam {
  const factory FrcTeam({
    required int number,
    int? rookieSeason,
    required String name,
    String? country,
    String? province,
    String? city,
    String? postalCode,
    String? website,
  }) = _FrcTeam;

  factory FrcTeam.fromJson(Map<String, dynamic> json) =>
      _$FrcTeamFromJson(json);
}

class FrcTeamsRepository {
  final CacheAll<int, FrcTeam> _teamsCache;
  final Cache<String, List<FrcTeam>> _eventTeamsCache;

  FrcTeamsRepository.supabase(SupabaseClient supabase)
      : this(FrcTeamsService(supabase));

  FrcTeamsRepository(FrcTeamsService service)
      : _teamsCache = CacheAll(
          expiration: const Duration(minutes: 30),
          origin: (teamNum) => service.getTeam(teamNum: teamNum),
          originAll: () => service.getAllTeams(),
        ),
        _eventTeamsCache = Cache(
          expiration: const Duration(minutes: 30),
          origin: (eventKey) => service.getTeamsAtEvent(eventKey: eventKey),
        );

  Future<FrcTeam?> getTeam({
    required int teamNum,
    bool forceOrigin = false,
  }) =>
      _teamsCache.get(
        key: teamNum,
        forceOrigin: forceOrigin,
      );

  Future<Map<int, FrcTeam>> getAllTeams({
    bool forceOrigin = false,
  }) =>
      _teamsCache.getAll(
        forceOrigin: forceOrigin,
      );

  Future<List<FrcTeam>?> getTeamsAtEvent({
    required String eventKey,
    bool forceOrigin = false,
  }) =>
      _eventTeamsCache.get(
        key: eventKey,
        forceOrigin: forceOrigin,
      );
}

class FrcTeamsService {
  final SupabaseClient supabase;

  FrcTeamsService(this.supabase);

  Future<FrcTeam?> getTeam({
    required int teamNum,
  }) async {
    final data = await supabase
        .from('frc_teams')
        .select()
        .eq('number', teamNum)
        .maybeSingle();
    return data == null ? null : FrcTeam.fromJson(data);
  }

  Future<Map<int, FrcTeam>> getAllTeams() async {
    final data = await supabase.from('frc_teams').select();
    final teams = data.map(FrcTeam.fromJson);
    return Map.fromEntries(teams.map(
      (team) => MapEntry(team.number, team),
    ));
  }

  Future<List<FrcTeam>?> getTeamsAtEvent({
    required String eventKey,
  }) async {
    final data = await supabase
        .from('frc_teams')
        .select()
        .eq('event_teams.event_key', eventKey);
    return data.isEmpty ? null : data.map(FrcTeam.fromJson).toList();
  }
}
