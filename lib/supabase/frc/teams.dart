import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase/supabase.dart';

import '../database.dart';

part 'teams.freezed.dart';
part 'teams.g.dart';

@immutable
@freezed
@JsonSerializable()
class FrcTeam with _$FrcTeam {
  @override
  final int number;
  @override
  final int? rookieSeason;
  @override
  final String name;
  @override
  final String? country;
  @override
  final String? province;
  @override
  final String? city;
  @override
  final String? postalCode;
  @override
  final String? website;

  const FrcTeam({
    required this.number,
    this.rookieSeason,
    required this.name,
    this.country,
    this.province,
    this.city,
    this.postalCode,
    this.website,
  });

  factory FrcTeam.fromJson(JsonObject json) => _$FrcTeamFromJson(json);
}

class FrcTeamsRepository {
  final Cache<int, FrcTeam> _teamsCache;
  final Cache<String, List<FrcTeam>> _eventTeamsCache;

  FrcTeamsRepository.supabase(SupabaseClient supabase)
    : this(FrcTeamsService(supabase));

  FrcTeamsRepository(FrcTeamsService service)
    : _teamsCache = Cache(
        expiration: const Duration(minutes: 30),
        origin: service.getTeam,
      ),
      _eventTeamsCache = Cache(
        expiration: const Duration(minutes: 30),
        origin: service.getTeamsAtEvent,
      );

  Future<FrcTeam?> getTeam({required int teamNum, bool forceOrigin = false}) =>
      _teamsCache.get(key: teamNum, forceOrigin: forceOrigin);

  Future<List<FrcTeam>?> getTeamsAtEvent({
    required String eventKey,
    bool forceOrigin = false,
  }) => _eventTeamsCache.get(key: eventKey, forceOrigin: forceOrigin);
}

class FrcTeamsService {
  final SupabaseClient _supabase;

  FrcTeamsService(this._supabase);

  Future<FrcTeam?> getTeam(int teamNum) async {
    final data = await _supabase
        .from('frc_teams')
        .select()
        .eq('number', teamNum)
        .maybeSingle();
    return data?.parse(FrcTeam.fromJson);
  }

  Future<List<FrcTeam>> getTeamsAtEvent(String eventKey) async {
    final data = await _supabase
        .from('frc_teams')
        .select()
        .eq('event_teams.event_key', eventKey);
    return data.parse(FrcTeam.fromJson);
  }
}
