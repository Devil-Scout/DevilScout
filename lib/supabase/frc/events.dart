// JsonKey not designed for use on constructor parameters
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase/supabase.dart';

import '../database.dart';

part 'events.freezed.dart';
part 'events.g.dart';

@immutable
@freezed
@JsonSerializable()
class FrcEventType with _$FrcEventType {
  @override
  final int id;
  @override
  final bool isDistrict;
  @override
  final bool isChampionship;
  @override
  final bool isDivision;
  @override
  final bool isOffseason;
  @override
  final String name;
  @override
  final String nameShort;

  const FrcEventType({
    required this.id,
    required this.isDistrict,
    required this.isChampionship,
    required this.isDivision,
    required this.isOffseason,
    required this.name,
    required this.nameShort,
  });

  factory FrcEventType.fromJson(JsonObject json) =>
      _$FrcEventTypeFromJson(json);
}

@immutable
@freezed
@JsonSerializable()
class FrcEvent with _$FrcEvent {
  @override
  final int season;
  @override
  final FrcEventType eventType;
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  @JsonKey(fromJson: _pointFromString)
  final (double, double)? coordinates;
  @override
  final int? week;
  @override
  final String key;
  @override
  final String code;
  @override
  final String name;
  @override
  final String? nameShort;
  @override
  final String? districtKey;
  @override
  final String? timezone;
  @override
  final String? country;
  @override
  final String? province;
  @override
  final String? city;
  @override
  final String? address;
  @override
  final String? location;
  @override
  final String? website;
  @override
  final String? postalCode;

  const FrcEvent({
    required this.season,
    required this.eventType,
    required this.startDate,
    required this.endDate,
    this.coordinates,
    this.week,
    required this.key,
    required this.code,
    required this.name,
    this.nameShort,
    this.districtKey,
    this.timezone,
    this.country,
    this.province,
    this.city,
    this.address,
    this.location,
    this.website,
    this.postalCode,
  });

  factory FrcEvent.fromJson(JsonObject json) => _$FrcEventFromJson(json);
}

(double, double)? _pointFromString(String? json) => json == null
    ? null
    : (
        double.parse(json.substring(1, json.indexOf(','))),
        double.parse(json.substring(json.indexOf(',') + 1, json.length - 1)),
      );

class FrcEventsRepository {
  final FrcEventsService _service;
  final Map<int, Cache<String, FrcEvent>> _eventsCaches;
  final Cache<int, List<FrcEvent>> _teamEventsCache;

  FrcEventsRepository.supabase(SupabaseClient supabase)
    : this(FrcEventsService(supabase));

  FrcEventsRepository(this._service)
    : _eventsCaches = {},
      _teamEventsCache = Cache(
        expiration: const Duration(minutes: 30),
        origin: _service.getTeamEvents,
      );

  Cache<String, FrcEvent> _cache(int season) =>
      Cache(expiration: const Duration(minutes: 30), origin: _service.getEvent);

  Future<FrcEvent?> getEvent({
    required String eventKey,
    bool forceOrigin = false,
  }) {
    final season = int.parse(eventKey.substring(0, 4));
    return _eventsCaches
        .putIfAbsent(season, () => _cache(season))
        .get(key: eventKey, forceOrigin: forceOrigin);
  }

  Future<List<FrcEvent>?> getTeamEvents({
    required int teamNum,
    bool forceOrigin = false,
  }) => _teamEventsCache.get(key: teamNum, forceOrigin: forceOrigin);

  Future<List<String>> searchEvents({
    required int season,
    required String query,
    int limit = 20,
  }) => _service.searchEvents(season: season, query: query, limit: limit);
}

class FrcEventsService {
  final SupabaseClient _supabase;

  FrcEventsService(this._supabase);

  Future<FrcEvent?> getEvent(String eventKey) async {
    final data = await _supabase
        .from('frc_events')
        .select('*, event_type:frc_event_types(*)')
        .eq('key', eventKey)
        .maybeSingle();
    return data?.parse(FrcEvent.fromJson);
  }

  Future<List<FrcEvent>> getTeamEvents(int teamNum) async {
    final data = await _supabase
        .from('frc_events')
        .select(
          '*, event_type:frc_event_types(*), frc_event_teams!inner(team_num)',
        )
        .eq('frc_event_teams.team_num', teamNum);
    return data.parse(FrcEvent.fromJson);
  }

  Future<List<String>> searchEvents({
    required int season,
    required String query,
    required int limit,
  }) async {
    final data = await _supabase
        .rpc('frc_events_search', params: {'year': season, 'query': query})
        .limit(limit);
    return List.castFrom(data as List<dynamic>);
  }
}
