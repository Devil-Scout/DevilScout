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

  factory FrcEventType.fromJson(Map<String, dynamic> json) =>
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
    @JsonKey(fromJson: _pointFromString) (int, int)? coordinates,
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

  factory FrcEvent.fromJson(Map<String, dynamic> json) =>
      _$FrcEventFromJson(json);
}

(int, int)? _pointFromString(String? json) => json == null
    ? null
    : (
        int.parse(json.substring(
          1,
          json.indexOf(' '),
        )),
        int.parse(json.substring(
          json.indexOf(' ') + 1,
          json.length - 1,
        ))
      );

class FrcEventsRepository {
  final Cache<String, FrcEvent> _eventsCache;
  final Cache<int, List<FrcEvent>> _seasonEventsCache;

  FrcEventsRepository.supabase(SupabaseClient supabase)
      : this(FrcEventsService(supabase));

  FrcEventsRepository(FrcEventsService service)
      : _eventsCache = Cache(
          expiration: const Duration(minutes: 30),
          origin: (eventKey) => service.getEvent(eventKey: eventKey),
        ),
        _seasonEventsCache = Cache(
          expiration: const Duration(minutes: 30),
          origin: (year) => service.getSeasonEvents(year: year),
        );

  Future<FrcEvent?> getEvent({
    required String eventKey,
    bool forceOrigin = false,
  }) =>
      _eventsCache.get(
        key: eventKey,
        forceOrigin: forceOrigin,
      );

  Future<List<FrcEvent>?> getSeasonEvents({
    required int season,
    bool forceOrigin = false,
  }) =>
      _seasonEventsCache.get(
        key: season,
        forceOrigin: forceOrigin,
      );
}

class FrcEventsService {
  final SupabaseClient supabase;

  FrcEventsService(this.supabase);

  Future<FrcEvent?> getEvent({
    required String eventKey,
  }) async {
    final data = await supabase
        .from('frc_events')
        .select('*, frc_event_types:event_type(*)')
        .eq('key', eventKey)
        .maybeSingle();
    return data?.parse(FrcEvent.fromJson);
  }

  Future<List<FrcEvent>?> getSeasonEvents({
    required int year,
  }) async {
    final data = await supabase
        .from('frc_events')
        .select('*, frc_event_types:event_type(*)')
        .eq('season', year);
    return data.parseToList(FrcEvent.fromJson);
  }
}
