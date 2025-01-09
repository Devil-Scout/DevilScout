import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final FrcDistrictsService service;
  final Map<int, CacheAll<String, FrcDistrict>> _districtsCaches;

  FrcDistrictsRepository.supabase(SupabaseClient supabase)
      : this(FrcDistrictsService(supabase));

  FrcDistrictsRepository(this.service) : _districtsCaches = {};

  CacheAll<String, FrcDistrict> _cache(int season) => CacheAll(
        expiration: const Duration(minutes: 30),
        origin: service.getDistrict,
        originAll: () => service.getSeasonDistricts(season),
        key: (district) => district.name,
      );

  Future<FrcDistrict?> getDistrict({
    required String districtKey,
    bool forceOrigin = false,
  }) {
    final year = int.parse(districtKey.substring(0, 4));
    return _districtsCaches
        .putIfAbsent(year, () => _cache(year))
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
  final SupabaseClient supabase;

  FrcDistrictsService(this.supabase);

  Future<FrcDistrict?> getDistrict(String districtKey) async {
    final data = await supabase
        .from('frc_districts')
        .select()
        .eq('key', districtKey)
        .maybeSingle();
    return data?.parse(FrcDistrict.fromJson);
  }

  Future<List<FrcDistrict>> getSeasonDistricts(int year) async {
    final data =
        await supabase.from('frc_districts').select().eq('season', year);
    return data.parse(FrcDistrict.fromJson);
  }
}
