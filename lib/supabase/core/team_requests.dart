import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  factory TeamRequest.fromJson(JsonObject json) => _$TeamRequestFromJson(json);
}

class TeamRequestsRepository {
  final TeamRequestsService _service;
  final CacheAll<Uuid, TeamRequest> _requestsCache;

  TeamRequestsRepository.supabase(SupabaseClient supabase)
      : this(TeamRequestsService(supabase));

  TeamRequestsRepository(this._service)
      : _requestsCache = CacheAll(
          expiration: const Duration(minutes: 30),
          origin: _service.getRequest,
          originAll: _service.getAllRequests,
          key: (request) => request.userId,
        );

  Future<TeamRequest?> getTeam({
    required String userId,
    bool forceOrigin = false,
  }) =>
      _requestsCache.get(key: userId, forceOrigin: forceOrigin);

  Future<List<TeamRequest>> getAllRequests({
    bool forceOrigin = false,
  }) =>
      _requestsCache.getAll(forceOrigin: forceOrigin);

  Future<void> requestToJoin({
    required int teamNum,
  }) =>
      _service.requestToJoin(teamNum);

  Future<void> deleteRequest({
    required Uuid userId,
  }) =>
      _service.deleteRequest(userId);
}

class TeamRequestsService {
  final SupabaseClient _supabase;

  TeamRequestsService(this._supabase);

  Future<TeamRequest?> getRequest(String userId) async {
    final data = await _supabase
        .from('team_requests')
        .select('*, profile:profiles(*)')
        .eq('user_id', userId)
        .maybeSingle();
    return data?.parse(TeamRequest.fromJson);
  }

  Future<List<TeamRequest>> getAllRequests() async {
    final data = await _supabase
        .from('team_requests')
        .select('*, profile:profiles(*)');
    return data.parse(TeamRequest.fromJson);
  }

  Future<void> requestToJoin(int teamNum) =>
      _supabase.from('team_requests').insert({'team_num': teamNum});

  Future<void> deleteRequest(Uuid userId) =>
      _supabase.from('team_requests').delete().eq('user_id', userId);
}
