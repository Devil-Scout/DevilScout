import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase/supabase.dart';

import '../database.dart';

part 'districts.freezed.dart';
part 'districts.g.dart';

@immutable
@freezed
class FrcDistrict with _$FrcDistrict {
  const factory FrcDistrict({
    required int season,
    required String key,
    required String code,
    required String name,
  }) = _FrcDistrict;

  factory FrcDistrict.fromJson(JsonObject json) => _$FrcDistrictFromJson(json);
}

class FrcDistrictsRepository {
  final FrcDistrictsService _service;
  final Map<int, CacheAll<String, FrcDistrict>> _districtsCaches;

  FrcDistrictsRepository.supabase(SupabaseClient supabase)
      : this(FrcDistrictsService(supabase));

  FrcDistrictsRepository(this._service) : _districtsCaches = {};

  CacheAll<String, FrcDistrict> _cache(int season) => CacheAll(
        expiration: const Duration(minutes: 30),
        origin: _service.getDistrict,
        originAll: () async => _service.getSeasonDistricts(season),
        key: (district) => district.name,
      );

  Future<FrcDistrict?> getDistrict({
    required String districtKey,
    bool forceOrigin = false,
  }) {
    final season = int.parse(districtKey.substring(0, 4));
    return _districtsCaches
        .putIfAbsent(season, () => _cache(season))
        .get(key: districtKey, forceOrigin: forceOrigin);
  }

  Future<List<FrcDistrict>?> getSeasonDistricts({
    required int season,
    bool forceOrigin = false,
  }) =>
      _districtsCaches
          .putIfAbsent(season, () => _cache(season))
          .getAll(forceOrigin: forceOrigin);
}

class FrcDistrictsService {
  final SupabaseClient _supabase;

  FrcDistrictsService(this._supabase);

  Future<FrcDistrict?> getDistrict(String districtKey) async {
    final data = await _supabase
        .from('frc_districts')
        .select()
        .eq('key', districtKey)
        .maybeSingle();
    return data?.parse(FrcDistrict.fromJson);
  }

  Future<List<FrcDistrict>> getSeasonDistricts(int season) async {
    final data =
        await _supabase.from('frc_districts').select().eq('season', season);
    return data.parse(FrcDistrict.fromJson);
  }
}
