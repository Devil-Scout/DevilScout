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

  factory FrcTeam.fromJson(JsonObject json) => _$FrcTeamFromJson(json);
}

class FrcTeamsRepository {
  final FrcTeamsService service;
  final CacheAll<int, FrcTeam> _teamsCache;
  final Cache<String, List<FrcTeam>> _eventTeamsCache;

  FrcTeamsRepository.supabase(SupabaseClient supabase)
      : this(FrcTeamsService(supabase));

  FrcTeamsRepository(this.service)
      : _teamsCache = CacheAll(
          expiration: const Duration(minutes: 30),
          origin: service.getTeam,
          originAll: service.getAllTeams,
          key: (team) => team.number,
        ),
        _eventTeamsCache = Cache(
          expiration: const Duration(minutes: 30),
          origin: service.getTeamsAtEvent,
        );

  Future<FrcTeam?> getTeam({
    required int teamNum,
    bool forceOrigin = false,
  }) =>
      _teamsCache.get(key: teamNum, forceOrigin: forceOrigin);

  Future<List<FrcTeam>> getAllTeams({
    bool forceOrigin = false,
  }) =>
      _teamsCache.getAll(forceOrigin: forceOrigin);

  Future<List<FrcTeam>?> getTeamsAtEvent({
    required String eventKey,
    bool forceOrigin = false,
  }) =>
      _eventTeamsCache.get(key: eventKey, forceOrigin: forceOrigin);
}

class FrcTeamsService {
  final SupabaseClient supabase;

  FrcTeamsService(this.supabase);

  Future<FrcTeam?> getTeam(int teamNum) async {
    final data = await supabase
        .from('frc_teams')
        .select()
        .eq('number', teamNum)
        .maybeSingle();
    return data == null ? null : FrcTeam.fromJson(data);
  }

  Future<List<FrcTeam>> getAllTeams() async {
    final data = await supabase.from('frc_teams').select();
    return data.parse(FrcTeam.fromJson);
  }

  Future<List<FrcTeam>> getTeamsAtEvent(String eventKey) async {
    final data = await supabase
        .from('frc_teams')
        .select()
        .eq('event_teams.event_key', eventKey);
    return data.parse(FrcTeam.fromJson);
  }
}
