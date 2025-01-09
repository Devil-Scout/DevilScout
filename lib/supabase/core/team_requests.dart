import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../database.dart';
import 'team_users.dart';

part 'team_requests.freezed.dart';
part 'team_requests.g.dart';

@immutable
@freezed
class TeamRequest with _$TeamRequest {
  const factory TeamRequest({
    required Uuid userId,
    required DateTime requestedAt,
    required int teamNum,
    required UserProfile profile,
  }) = _TeamRequest;

  factory TeamRequest.fromJson(Map<String, dynamic> json) =>
      _$TeamRequestFromJson(json);
}

class TeamRequestsRepository {
  final TeamRequestsService service;
  final CacheAll<Uuid, TeamRequest> _teamsCache;

  TeamRequestsRepository.supabase(SupabaseClient supabase)
      : this(TeamRequestsService(supabase));

  TeamRequestsRepository(this.service)
      : _teamsCache = CacheAll(
          expiration: const Duration(minutes: 30),
          origin: service.getRequest,
          originAll: service.getAllRequests,
          key: (request) => request.userId,
        );

  Future<TeamRequest?> getTeam({
    required String userId,
    bool forceOrigin = false,
  }) =>
      _teamsCache.get(
        key: userId,
        forceOrigin: forceOrigin,
      );

  Future<List<TeamRequest>> getAllRequests({
    bool forceOrigin = false,
  }) =>
      _teamsCache.getAll(
        forceOrigin: forceOrigin,
      );
}

class TeamRequestsService {
  final SupabaseClient supabase;

  TeamRequestsService(this.supabase);

  Future<TeamRequest?> getRequest(String userId) async {
    final data = await supabase
        .from('team_requests')
        .select('*, user_profiles:profile(*)')
        .eq('user_id', userId)
        .maybeSingle();
    return data?.parse(TeamRequest.fromJson);
  }

  Future<List<TeamRequest>> getAllRequests() async {
    final data = await supabase.from('team_requests').select('*, user_profiles:profile(*)');
    return data.parse(TeamRequest.fromJson);
  }
}
