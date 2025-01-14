// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database.dart';

part 'events.freezed.dart';
part 'events.g.dart';

@immutable
@freezed
class FrcEventType with _$FrcEventType {
  const factory FrcEventType({
    required int id,
    required bool isDistrict,
    required bool isChampionship,
    required bool isDivision,
    required bool isOffseason,
    required String name,
    required String nameShort,
  }) = _FrcEventType;

  factory FrcEventType.fromJson(JsonObject json) =>
      _$FrcEventTypeFromJson(json);
}

@immutable
@freezed
class FrcEvent with _$FrcEvent {
  const factory FrcEvent({
    required int season,
    required FrcEventType eventType,
    required DateTime startDate,
    required DateTime endDate,
    @JsonKey(fromJson: _pointFromString) (double, double)? coordinates,
    int? week,
    required String key,
    required String code,
    required String name,
    String? nameShort,
    String? districtKey,
    String? timezone,
    String? country,
    String? province,
    String? city,
    String? address,
    String? location,
    String? website,
    String? postalCode,
  }) = _FrcEvent;

  factory FrcEvent.fromJson(JsonObject json) => _$FrcEventFromJson(json);
}

(double, double)? _pointFromString(String? json) => json == null
    ? null
    : (
        double.parse(json.substring(
          1,
          json.indexOf(','),
        )),
        double.parse(json.substring(
          json.indexOf(',') + 1,
          json.length - 1,
        ))
      );

class FrcEventsRepository {
  final FrcEventsService _service;
  final Map<int, CacheAll<String, FrcEvent>> _eventsCaches;
  final Cache<int, List<FrcEvent>> _teamEventsCache;

  FrcEventsRepository.supabase(SupabaseClient supabase)
      : this(FrcEventsService(supabase));

  FrcEventsRepository(this._service)
      : _eventsCaches = {},
        _teamEventsCache = Cache(
          expiration: const Duration(minutes: 30),
          origin: _service.getTeamEvents,
        );

  CacheAll<String, FrcEvent> _cache(int season) => CacheAll(
        expiration: const Duration(minutes: 30),
        origin: _service.getEvent,
        originAll: () => _service.getSeasonEvents(season),
        key: (event) => event.key,
      );

  Future<FrcEvent?> getEvent({
    required String eventKey,
    bool forceOrigin = false,
  }) {
    int season = int.parse(eventKey.substring(0, 4));
    return _eventsCaches
        .putIfAbsent(season, () => _cache(season))
        .get(key: eventKey, forceOrigin: forceOrigin);
  }

  Future<List<FrcEvent>?> getSeasonEvents({
    required int season,
    bool forceOrigin = false,
  }) =>
      _eventsCaches
          .putIfAbsent(season, () => _cache(season))
          .getAll(forceOrigin: forceOrigin);

  Future<List<FrcEvent>?> getTeamEvents({
    required int teamNum,
    bool forceOrigin = false,
  }) =>
      _teamEventsCache.get(
        key: teamNum,
        forceOrigin: forceOrigin,
      );
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

  Future<List<FrcEvent>> getSeasonEvents(int season) async {
    final data = await _supabase
        .from('frc_events')
        .select('*, event_type:frc_event_types(*)')
        .eq('season', season);
    return data.parse(FrcEvent.fromJson);
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
}
