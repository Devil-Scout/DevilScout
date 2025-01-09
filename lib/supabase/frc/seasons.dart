import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database.dart';

part 'seasons.freezed.dart';
part 'seasons.g.dart';

@immutable
@freezed
class FrcSeason with _$FrcSeason {
  const factory FrcSeason({
    required int year,
    required String name,
  }) = _FrcSeason;

  factory FrcSeason.fromJson(JsonObject json) => _$FrcSeasonFromJson(json);
}

class FrcSeasonsRepository {
  final FrcSeasonsService service;
  final CacheAll<int, FrcSeason> _seasonsCache;

  FrcSeasonsRepository.supabase(SupabaseClient supabase)
      : this(FrcSeasonsService(supabase));

  FrcSeasonsRepository(this.service)
      : _seasonsCache = CacheAll(
          expiration: const Duration(minutes: 30),
          origin: service.getSeason,
          originAll: service.getAllSeasons,
          key: (season) => season.year,
        );

  Future<FrcSeason?> getSeason({
    required int year,
    bool forceOrigin = false,
  }) =>
      _seasonsCache.get(key: year, forceOrigin: forceOrigin);

  Future<List<FrcSeason>> getAllSeasons({
    bool forceOrigin = false,
  }) =>
      _seasonsCache.getAll(forceOrigin: forceOrigin);
}

class FrcSeasonsService {
  final SupabaseClient supabase;

  FrcSeasonsService(this.supabase);

  Future<FrcSeason?> getSeason(int year) async {
    final data = await supabase
        .from('frc_seasons')
        .select()
        .eq('year', year)
        .maybeSingle();
    return data?.parse(FrcSeason.fromJson);
  }

  Future<List<FrcSeason>> getAllSeasons() async {
    final data = await supabase.from('frc_seasons').select();
    return data.parse(FrcSeason.fromJson);
  }
}
