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

  factory FrcDistrict.fromJson(Map<String, dynamic> json) =>
      _$FrcDistrictFromJson(json);
}

class FrcDistrictsRepository {
  final Cache<String, FrcDistrict> _districtsCache;
  final Cache<int, List<FrcDistrict>> _seasonDistrictsCache;

  FrcDistrictsRepository.supabase(SupabaseClient supabase)
      : this(FrcDistrictsService(supabase));

  FrcDistrictsRepository(FrcDistrictsService service)
      : _districtsCache = Cache(
          expiration: const Duration(minutes: 30),
          origin: service.getDistrict,
        ),
        _seasonDistrictsCache = Cache(
          expiration: const Duration(minutes: 30),
          origin: service.getSeasonDistricts,
        );

  Future<FrcDistrict?> getDistrict({
    required String districtKey,
    bool forceOrigin = false,
  }) =>
      _districtsCache.get(
        key: districtKey,
        forceOrigin: forceOrigin,
      );

  Future<List<FrcDistrict>?> getSeasonDistricts({
    required int season,
    bool forceOrigin = false,
  }) =>
      _seasonDistrictsCache.get(
        key: season,
        forceOrigin: forceOrigin,
      );
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

  Future<List<FrcDistrict>?> getSeasonDistricts(int year) async {
    final data =
        await supabase.from('frc_districts').select().eq('season', year);
    return data.parse(FrcDistrict.fromJson);
  }
}
